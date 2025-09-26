import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './auth_screen.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1) Aquí guardas la lista de resultados:
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();

  // 2) Suscripción a Stream<List<ConnectivityResult>>
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();

    // 3) 'onConnectivityChanged' emite List<ConnectivityResult>
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  // 4) Ahora devuelve una lista
  Future<void> initConnectivity() async {
    List<ConnectivityResult> results;
    try {
      results = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Error al comprobar conectividad: $e');
      return;
    }
    if (!mounted) return;
    _updateConnectionStatus(results);
  }

  // 5) Recibe la lista completa
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      _connectionStatus = results;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 6) Comprueba el primer elemento para ver si hay conexión
    final bool hasConnection =
        _connectionStatus.isNotEmpty &&
        _connectionStatus.first != ConnectivityResult.none;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(context),
          body: !hasConnection
              ? _buildNoConnectionView(context)
              : _buildLoginView(context),
        );
      },
    );
  }

  Widget _buildNoConnectionView(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.getBorderColor(context)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kRedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    "assets/images/login_forget.png",
                    height: MediaQuery.of(context).size.height * .12,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Please check your Internet connection and try again',
                  style: TextStyle(
                    fontSize: 16, 
                    color: AppColors.getTextSecondaryColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginView(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Header Section
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/login_forget.png',
                    height: MediaQuery.of(context).size.height * .12,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'NSCA Academy',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Access Your Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Please sign in to access your personalized content and continue your learning journey',
                  style: TextStyle(
                    fontSize: 16, 
                    color: AppColors.getTextSecondaryColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Sign In Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pushNamed(AuthScreen.routeName);
                },
                borderRadius: BorderRadius.circular(12),
                child: const Center(
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kTextColorLight,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Helpful text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account? ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextSecondaryColor(context),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/signup');
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Features Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.getBorderColor(context)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeatureItem(Icons.person, 'Personal'),
                _buildFeatureItem(Icons.lock, 'Secure'),
                _buildFeatureItem(Icons.school, 'Learning'),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.getTextSecondaryColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
