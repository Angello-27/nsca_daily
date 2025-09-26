// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

import '../providers/auth.dart';
import '../providers/theme_provider.dart';
// import '../screens/account_remove_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/database_helper.dart';
import 'edit_password_screen.dart';
import 'edit_profile_screen.dart';
import 'package:http/http.dart' as http;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();
  dynamic courseAccessibility;

  systemSettings() async {
    var url = "$BASE_URL/api/system_settings";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        courseAccessibility = data['course_accessibility'];
      });
    } else {
      setState(() {
        courseAccessibility = '';
      });
    }
  }

  List<int> courseArr = [];

  Future<List<Map<String, dynamic>>?> getVideos() async {
    List<Map<String, dynamic>> listMap = await DatabaseHelper.instance
        .queryAllRows('video_list');
    setState(() {
      for (var map in listMap) {
        File checkPath = File("${map['path']}/${map['title']}");
        if (checkPath.existsSync()) {
          courseArr.add(map['course_id']);
        } else {
          DatabaseHelper.instance.removeVideo(map['id']);
        }
      }
    });
    return null;
  }

  Future<List<Map<String, dynamic>>?> getCourse() async {
    List<Map<String, dynamic>> listMap = await DatabaseHelper.instance
        .queryAllRows('course_list');

    for (var map in listMap) {
      if (!courseArr.contains(map['course_id'])) {
        await DatabaseHelper.instance.removeCourse(map['course_id']);
        await DatabaseHelper.instance.removeCourseSection(map['course_id']);
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();

    // onConnectivityChanged emite List<ConnectivityResult>
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  // 2) InitConnectivity sin casteos extraños:
  Future<void> initConnectivity() async {
    List<ConnectivityResult> results;
    try {
      // Ahora devuelve una lista
      results = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Error al comprobar conectividad: $e');
      return;
    }
    if (!mounted) return;
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      _connectionStatus = results;
    });
  }

  Color _getTextColor(Set<WidgetState> states) =>
      states.any(
            <WidgetState>{
              WidgetState.pressed,
              WidgetState.hovered,
              WidgetState.focused,
            }.contains,
          )
          ? Colors.green
          : kPrimaryColor;

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.getBorderColor(context)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (iconColor ?? kPrimaryColor).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor ?? kPrimaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.getTextSecondaryColor(context),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return FutureBuilder(
          future: Provider.of<Auth>(context, listen: false).loadUserDataFromCache(),
          builder: (ctx, cacheSnapshot) {
            if (cacheSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor.withValues(alpha: 0.7),
                ),
              );
            } else {
              return Consumer<Auth>(
                builder: (context, authData, child) {
                  final user = authData.user;
                  
                  // Check if we have basic user info (from cache or registration)
                  if (user.firstName == null || user.firstName!.isEmpty) {
                    // If no user info at all, show error
                    return _connectionStatus.contains(ConnectivityResult.none)
                        ? Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * .15,
                              ),
                              Image.asset(
                                "assets/images/no_connection.png",
                                height: MediaQuery.of(context).size.height * .35,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'There is no Internet connection',
                                  style: TextStyle(
                                    color: AppColors.getTextColor(context),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Please check your Internet connection',
                                  style: TextStyle(
                                    color: AppColors.getTextSecondaryColor(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: kRedColor, size: 64),
                              const SizedBox(height: 16),
                              Text(
                                'No User Data', 
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextColor(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please log in again', 
                                style: TextStyle(
                                  color: AppColors.getTextSecondaryColor(context),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: kTextColorLight,
                                ),
                                child: const Text('Go to Login'),
                              ),
                            ],
                          ),
                        );
                  } else {
                    // We have user info, show the account screen and update in background
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Update user data in background without blocking UI
                      authData.updateUserDataInBackground();
                    });
                    
                    return _buildAccountContent(user);
                  }
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildAccountContent(user) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Profile Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.getBorderColor(context)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.image != null && user.image!.isNotEmpty
                          ? NetworkImage(user.image.toString())
                          : null,
                      backgroundColor: kLightBlueColor,
                      child: user.image == null || user.image!.isEmpty
                          ? Text(
                              '${user.firstName?.substring(0, 1) ?? ''}${user.lastName?.substring(0, 1) ?? ''}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextColor(context),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${user.firstName ?? ''} ${user.lastName ?? ''}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your account settings',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextSecondaryColor(context),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Account Options
              _buildModernCard(
                title: 'View Profile',
                icon: Icons.account_circle_outlined,
                iconColor: kPrimaryColor,
                onTap: () {
                  Navigator.of(context).pushNamed(EditProfileScreen.routeName);
                },
              ),

              _buildModernCard(
                title: 'Change Password',
                icon: Icons.lock_outline,
                iconColor: kBlueColor,
                onTap: () {
                  Navigator.of(context).pushNamed(EditPasswordScreen.routeName);
                },
              ),

              // Logout Button
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.getBorderColor(context)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      final navigator = Navigator.of(context);
                      await Provider.of<Auth>(
                        context,
                        listen: false,
                      ).logout();
                      if (mounted) {
                        if (courseAccessibility == 'publicly') {
                          navigator.pushNamedAndRemoveUntil(
                            '/home',
                            (r) => false,
                          );
                        } else {
                          navigator.pushNamedAndRemoveUntil(
                            '/auth-private',
                            (r) => false,
                          );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kRedColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout_outlined,
                              color: kRedColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kRedColor,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.getTextSecondaryColor(context),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
