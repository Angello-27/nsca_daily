// ignore_for_file: use_build_context_synchronously

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

  systemSettings() async {
    try {
      final url = Uri.parse('$BASE_URL/api/system_settings');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => courseAccessibility = data['course_accessibility']);
      } else {
        setState(() => courseAccessibility = '');
        debugPrint('Error ${response.statusCode} en system_settings');
      }
    } on SocketException catch (e) {
      setState(() => courseAccessibility = '');
      debugPrint('Sin conexión o fallo DNS: $e');
    } on TimeoutException catch (e) {
      setState(() => courseAccessibility = '');
      debugPrint('Timeout al conectar: $e');
    } catch (e) {
      setState(() => courseAccessibility = '');
      debugPrint('Otro error en systemSettings: $e');
    }
  }

  @override
  void initState() {
    donLogin();
    systemSettings();
    super.initState();
  }

  void donLogin() {
    String? token;
    Future.delayed(const Duration(seconds: 3), () async {
      token = await SharedPreferenceHelper().getAuthToken();
      if (token != null && token!.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TabsScreen()),
        );
      } else {
        if (courseAccessibility == 'publicly') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TabsScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthScreenPrivate()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Image.asset('assets/images/splash.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}
