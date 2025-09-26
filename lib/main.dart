import 'dart:io';
import 'package:nsca_daily/providers/daily_report.dart';

import './providers/bundles.dart';
import './providers/course_forum.dart';
import './providers/theme_provider.dart';
import './screens/account_remove_screen.dart';
import './screens/auth_screen_private.dart';
import './screens/edit_password_screen.dart';
import './screens/edit_profile_screen.dart';
import './screens/sub_category_screen.dart';
import './screens/verification_screen.dart';
import 'package:logging/logging.dart';
import 'providers/auth.dart';
import 'providers/courses.dart';
import 'providers/http_overrides.dart';
import 'providers/misc_provider.dart';
import 'providers/my_bundles.dart';
import 'providers/my_courses.dart';
import 'screens/bundle_details_screen.dart';
import 'screens/bundle_list_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/device_verifcation.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/my_bundle_courses_list_screen.dart';
import 'screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'providers/categories.dart';
import 'screens/auth_screen.dart';
import 'screens/course_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tabs_screen.dart';
import 'screens/chaplaincy_screen.dart';

void main() {
  Logger.root.onRecord.listen((LogRecord rec) {
    debugPrint(
      '${rec.loggerName}>${rec.level.name}: ${rec.time}: ${rec.message}',
    );
  });
  HttpOverrides.global = PostHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProvider(create: (ctx) => Categories()),
        ChangeNotifierProxyProvider<Auth, Courses>(
          create: (ctx) => Courses([], []),
          update:
              (ctx, auth, prevoiusCourses) => Courses(
                prevoiusCourses == null ? [] : prevoiusCourses.items,
                prevoiusCourses == null ? [] : prevoiusCourses.topItems,
              ),
        ),
        ChangeNotifierProxyProvider<Auth, MyCourses>(
          create: (ctx) => MyCourses([], []),
          update:
              (ctx, auth, previousMyCourses) => MyCourses(
                previousMyCourses == null ? [] : previousMyCourses.items,
                previousMyCourses == null ? [] : previousMyCourses.sectionItems,
              ),
        ),
        ChangeNotifierProvider(create: (ctx) => Languages()),
        ChangeNotifierProvider(create: (ctx) => Bundles()),
        ChangeNotifierProvider(create: (ctx) => MyBundles()),
        ChangeNotifierProvider(create: (ctx) => CourseForum()),
        ChangeNotifierProvider(create: (_) => DailyReportProvider()),
      ],
      child: Consumer2<ThemeProvider, Auth>(
        builder: (ctx, themeProvider, auth, _) => MaterialApp(
          // title: 'Cloud Computing Courses and Cyber Security Courses',
          title: 'Academy App',
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            fontFamily: 'google_sans',
            brightness: Brightness.light,
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor,
              secondary: kPrimaryColor,
              surface: kCardColorLight,
              onSurface: kTextColorLight,
              onPrimary: kTextColorLight,
            ),
            scaffoldBackgroundColor: kBackgroundColorLight,
            appBarTheme: const AppBarTheme(
              backgroundColor: kCardColorLight,
              foregroundColor: kTextColorLight,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: kCardColorLight,
              selectedItemColor: kPrimaryColor,
              unselectedItemColor: kTextSecondaryColorLight,
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: 'google_sans',
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryColor,
              secondary: kPrimaryColor,
              surface: kCardColorDark,
              onSurface: kTextColorDark,
              onPrimary: kTextColorDark,
            ),
            scaffoldBackgroundColor: kBackgroundColorDark,
            appBarTheme: const AppBarTheme(
              backgroundColor: kCardColorDark,
              foregroundColor: kTextColorDark,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: kCardColorDark,
              selectedItemColor: kPrimaryColor,
              unselectedItemColor: kTextSecondaryColorDark,
            ),
          ),
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(),
              routes: {
                '/home': (ctx) => const TabsScreen(),
                AuthScreen.routeName: (ctx) => const AuthScreen(),
                AuthScreenPrivate.routeName: (ctx) => const AuthScreenPrivate(),
                SignUpScreen.routeName: (ctx) => const SignUpScreen(),
                ForgotPassword.routeName: (ctx) => const ForgotPassword(),
                CoursesScreen.routeName: (ctx) => const CoursesScreen(),
                CourseDetailScreen.routeName:
                    (ctx) => const CourseDetailScreen(),
                EditPasswordScreen.routeName:
                    (ctx) => const EditPasswordScreen(),
                EditProfileScreen.routeName: (ctx) => const EditProfileScreen(),
                VerificationScreen.routeName:
                    (ctx) => const VerificationScreen(),
                AccountRemoveScreen.routeName:
                    (ctx) => const AccountRemoveScreen(),
                SubCategoryScreen.routeName: (ctx) => const SubCategoryScreen(),
                BundleListScreen.routeName: (ctx) => const BundleListScreen(),
                BundleDetailsScreen.routeName:
                    (ctx) => const BundleDetailsScreen(),
                MyBundleCoursesListScreen.routeName:
                    (ctx) => const MyBundleCoursesListScreen(),
                DeviceVerificationScreen.routeName:
                    (context) => const DeviceVerificationScreen(),
                ChaplaincyScreen.routeName:
                    (ctx) => const ChaplaincyScreen(),
              },
            ),
      ),
    );
  }
}
