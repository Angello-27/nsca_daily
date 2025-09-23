// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

import '../providers/auth.dart';
// import '../screens/account_remove_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/database_helper.dart';
import 'downloaded_course_list.dart';
import 'edit_password_screen.dart';
import 'edit_profile_screen.dart';
import 'package:http/http.dart' as http;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with TickerProviderStateMixin {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();
  dynamic courseAccessibility;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

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

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();

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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (iconColor ?? kPrimaryColor).withValues(
                          alpha: 0.1,
                        ),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kTextColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: kSecondaryColor.withValues(alpha: 0.6),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Auth>(context, listen: false).getUserInfo(),
      builder: (ctx, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: kPrimaryColor.withValues(alpha: 0.7),
            ),
          );
        } else {
          if (dataSnapshot.error != null) {
            //error
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
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text('There is no Internet connection'),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text('Please check your Internet connection'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const DownloadedCourseList();
                                },
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateColor.resolveWith(
                              _getTextColor,
                            ),
                          ),
                          icon: const Icon(Icons.download_done_rounded),
                          label: const Text(
                            'Play offline courses',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await Provider.of<Auth>(
                          context,
                          listen: false,
                        ).logout();
                        if (mounted) {
                          navigator.pushNamedAndRemoveUntil(
                            '/home',
                            (r) => false,
                          );
                        }
                      },
                    ),
                    const Center(child: Text('Error Occurred')),
                  ],
                );
          } else {
            return Consumer<Auth>(
              builder: (context, authData, child) {
                final user = authData.user;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header con gradiente y avatar mejorado
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            height: MediaQuery.of(context).size.height * .35,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  kPrimaryColor.withValues(alpha: 0.1),
                                  kBackgroundColor,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Avatar con animación de escala
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            kPrimaryColor.withValues(
                                              alpha: 0.2,
                                            ),
                                            kStarColor.withValues(alpha: 0.2),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: kPrimaryColor.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundImage: NetworkImage(
                                          user.image.toString(),
                                        ),
                                        backgroundColor: kLightBlueColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    '${user.firstName} ${user.lastName}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: kTextColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Manage your account settings',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: kSecondaryColor.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Cards modernas con animaciones
                      _buildModernCard(
                        title: 'View Profile',
                        icon: Icons.account_circle_outlined,
                        iconColor: kPrimaryColor,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(EditProfileScreen.routeName);
                        },
                      ),

                      _buildModernCard(
                        title: 'Change Password',
                        icon: Icons.lock_outline,
                        iconColor: kBlueColor,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(EditPasswordScreen.routeName);
                        },
                      ),

                      _buildModernCard(
                        title: 'Downloaded Courses',
                        icon: Icons.download_done_outlined,
                        iconColor: kGreenColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const DownloadedCourseList(),
                            ),
                          );
                        },
                      ),

                      // Botón de Logout con diseño especial
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  kRedColor.withValues(alpha: 0.1),
                                  kRedColor.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: kRedColor.withValues(alpha: 0.2),
                                width: 1,
                              ),
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
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: kRedColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.logout_outlined,
                                          color: kRedColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(
                                        child: Text(
                                          'Log Out',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: kRedColor,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: kRedColor.withValues(alpha: 0.6),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
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
      },
    );
  }
}
