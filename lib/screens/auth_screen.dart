// ignore_for_file: use_build_context_synchronously

import '../constants.dart';
import '../models/common_functions.dart';
import '../providers/auth.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/signup_screen.dart';
import '../widgets/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import 'device_verifcation.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  const AuthScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, String> _authData = {'email': '', 'password': ''};

  bool hidePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late User userDetails;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Color getColor(Set<WidgetState> states) {
    const Set<WidgetState> interactiveStates = <WidgetState>{
      WidgetState.pressed,
      WidgetState.hovered,
      WidgetState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return kPrimaryColor;
    }
    return kSecondaryColor;
  }

  InputDecoration getInputDecoration(String hintext, IconData iconData, {bool isPassword = false}) {
    return InputDecoration(
      labelText: hintext,
      labelStyle: const TextStyle(
        color: kTextSecondaryColor,
        fontSize: 14,
      ),
      hintText: 'Enter your $hintext',
      hintStyle: const TextStyle(
        color: kTextSecondaryColor,
      ),
      filled: true,
      fillColor: kBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kRedColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kRedColor, width: 2),
      ),
      prefixIcon: Icon(iconData, color: kPrimaryColor),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  Future<void> _submit() async {
    if (!globalFormKey.currentState!.validate()) {
      // Add haptic feedback for validation error
      HapticFeedback.lightImpact();
      return;
    }
    globalFormKey.currentState!.save();

    // Add haptic feedback for button press
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Auth>(context, listen: false)
          .login(_authData['email'].toString(), _authData['password'].toString())
          .then((_) {
            setState(() {
              _isLoading = false;
              userDetails = Provider.of<Auth>(context, listen: false).user;
            });
          });

      if (userDetails.validity == 1) {
        if (userDetails.deviceVerification == 'needed-verification') {
          Navigator.of(context).pushNamed(
            DeviceVerificationScreen.routeName,
            arguments: {
              'email': userDetails.email,
              'token': userDetails.token,
            },
          );
          CommonFunctions.showSuccessToast(
            userDetails.deviceVerification!.capitalize(),
          );
        } else {
          // Success haptic feedback
          HapticFeedback.heavyImpact();
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
          CommonFunctions.showSuccessToast(
            'Welcome, ${userDetails.firstName} ${userDetails.lastName}',
          );
        }
      } else {
        // Error haptic feedback
        HapticFeedback.heavyImpact();
        CommonFunctions.showErrorDialog(
          userDetails.deviceVerification!.capitalize(),
          context,
        );
      }
    } catch (error) {
      // Error haptic feedback
      HapticFeedback.heavyImpact();
      CommonFunctions.showErrorDialog(
        'Login failed. Please try again.',
        context,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        key: scaffoldKey,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextColor),
        backgroundColor: kBackgroundColor,
        title: const Text(
          'Public Login',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor),
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
                      'assets/images/do_login.png',
                      height: 40,
                      width: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue your learning journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: kTextSecondaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Login Form Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor),
              ),
              child: Form(
                key: globalFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Login Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Email Field
                    TextFormField(
                      style: const TextStyle(
                        fontSize: 16,
                        color: kTextColor,
                      ),
                      decoration: getInputDecoration(
                        'Email Address',
                        Icons.email_outlined,
                      ),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (input) =>
                          !RegExp(
                                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
                              ).hasMatch(input!)
                              ? "Please enter a valid email address"
                              : null,
                      onSaved: (value) {
                        _authData['email'] = value.toString();
                        _emailController.text = value as String;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    TextFormField(
                      style: const TextStyle(
                        fontSize: 16,
                        color: kTextColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                          color: kTextSecondaryColor,
                          fontSize: 14,
                        ),
                        hintText: 'Enter your password',
                        hintStyle: const TextStyle(
                          color: kTextSecondaryColor,
                        ),
                        filled: true,
                        fillColor: kBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kRedColor),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kRedColor, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.lock_outlined, color: kPrimaryColor),
                        suffixIcon: IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: kTextSecondaryColor,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      onSaved: (input) {
                        _authData['password'] = input.toString();
                        _passwordController.text = input as String;
                      },
                      validator: (input) =>
                          input!.length < 3
                              ? "Password must be at least 3 characters"
                              : null,
                      obscureText: hidePassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Remember Me and Forgot Password
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: kTextColor,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pushNamed(ForgotPassword.routeName);
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: kBackgroundColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: kBackgroundColor,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sign Up Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: kTextSecondaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pushReplacementNamed(SignUpScreen.routeName);
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
