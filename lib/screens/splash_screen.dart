import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../constants.dart';
import '../screens/auth_screen_private.dart';
import 'package:flutter/material.dart';
import '../providers/shared_pref_helper.dart';
import 'tabs_screen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  dynamic courseAccessibility;

  @override
  void initState() {
    super.initState();
    _loadSystemSettings();
    _startDelay();
  }

  Future<void> _loadSystemSettings() async {
    try {
      final url = Uri.parse('$BASE_URL/api/system_settings');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      final data =
          (response.statusCode == 200) ? json.decode(response.body) : null;

      if (!mounted) return;
      setState(() {
        courseAccessibility = data != null ? data['course_accessibility'] : '';
      });
    } on SocketException {
      if (!mounted) return;
      setState(() => courseAccessibility = '');
    } on TimeoutException {
      if (!mounted) return;
      setState(() => courseAccessibility = '');
    } catch (_) {
      if (!mounted) return;
      setState(() => courseAccessibility = '');
    }
  }

  void _startDelay() {
    Future.delayed(const Duration(seconds: 3), () async {
      // Si ya no estamos montados, salimos
      if (!mounted) return;

      final token = await SharedPreferenceHelper().getAuthToken();

      if (!mounted) return;
      final next =
          (token != null && token.isNotEmpty) ||
                  courseAccessibility == 'publicly'
              ? const TabsScreen()
              : const AuthScreenPrivate();

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => next));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Image.asset(
          'assets/images/splash.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
