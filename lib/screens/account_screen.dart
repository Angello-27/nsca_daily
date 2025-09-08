// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

import '../providers/auth.dart';
// import '../screens/account_remove_screen.dart';
import '../widgets/account_list_tile.dart';
import '../widgets/custom_text.dart';
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

  @override
  void dispose() {
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
                      onPressed: () {
                        Provider.of<Auth>(context, listen: false).logout().then(
                          (_) => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (r) => false,
                          ),
                        );
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
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 60),
                        CircleAvatar(
                          radius: 55,
                          backgroundImage: NetworkImage(user.image.toString()),
                          backgroundColor: kLightBlueColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: CustomText(
                            text: '${user.firstName} ${user.lastName}',
                            colors: kTextColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 65,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0.1,
                              child: GestureDetector(
                                child: const AccountListTile(
                                  titleText: 'View Profile',
                                  icon: Icons.account_circle,
                                  actionType: 'edit',
                                ),
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(EditProfileScreen.routeName);
                                },
                              ),
                            ),
                          ),
                        ),

                        // SizedBox(
                        //   height: 65,
                        //   child: Padding(
                        //     padding: const EdgeInsets.only(left: 10, right: 10),
                        //     child: Card(
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       elevation: 0.1,
                        //       child: GestureDetector(
                        //         child: const AccountListTile(
                        //           titleText: 'Downloaded Course',
                        //           icon: Icons.file_download_outlined,
                        //           actionType: 'downloaded_course',
                        //         ),
                        //         onTap: () {
                        //           Navigator.of(context).pushNamed(
                        //               DownloadedCourseList.routeName);
                        //         },
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: 65,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0.1,
                              child: GestureDetector(
                                child: const AccountListTile(
                                  titleText: 'Change Password',
                                  icon: Icons.vpn_key,
                                  actionType: 'change_password',
                                ),
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(EditPasswordScreen.routeName);
                                },
                              ),
                            ),
                          ),
                        ),
                        /*SizedBox(
                          height: 65,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0.1,
                              child: GestureDetector(
                                child: const AccountListTile(
                                  titleText: 'Delete Your Account',
                                  icon: Icons.person_remove_outlined,
                                  actionType: 'account_delete',
                                ),
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AccountRemoveScreen.routeName);
                                },
                              ),
                            ),
                          ),
                        ),*/
                        SizedBox(
                          height: 65,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0.1,
                              child: GestureDetector(
                                child: AccountListTile(
                                  titleText: 'Log Out',
                                  icon: Icons.exit_to_app,
                                  actionType: 'logout',
                                  courseAccessibility: courseAccessibility,
                                ),
                                onTap: () {
                                  if (courseAccessibility == 'publicly') {
                                    Provider.of<Auth>(
                                      context,
                                      listen: false,
                                    ).logout().then(
                                      (_) => Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/home',
                                        (r) => false,
                                      ),
                                    );
                                  } else {
                                    Provider.of<Auth>(
                                      context,
                                      listen: false,
                                    ).logout().then(
                                      (_) => Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/auth-private',
                                        (r) => false,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
