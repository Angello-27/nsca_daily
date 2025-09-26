// ignore_for_file: use_build_context_synchronously

import '../models/common_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../providers/auth.dart';
import '../providers/theme_provider.dart';
import 'auth_screen.dart';
import 'device_verifcation.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}


class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool hidePassword = true;
  bool hideRepeatPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
  String _phoneType = 'Mobile';
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _repeatEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _submit() async {
    if (!globalFormKey.currentState!.validate()) {
      return;
    }
    
    if (!_acceptTerms) {
      CommonFunctions.showErrorDialog('You must accept the privacy policy to continue', context);
      return;
    }
    
    globalFormKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });
    
    try {
      await Provider.of<Auth>(context, listen: false).registerAndLogin(
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _passwordController.text,
        _phoneController.text,
        _phoneType,
      );

      final userDetails = Provider.of<Auth>(context, listen: false).user;

      if (userDetails.validity == 1) {
        if (userDetails.deviceVerification == 'needed-verification') {
          Navigator.of(context).pushNamed(
            DeviceVerificationScreen.routeName,
            arguments: {
              'email': userDetails.email,
              'token': userDetails.token,
            },
          );
          CommonFunctions.showSuccessToast('Registration successful! Please verify your device.');
        } else {
          // Registration and login successful, navigate to home
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
          CommonFunctions.showSuccessToast(
            'Welcome, ${userDetails.firstName} ${userDetails.lastName}!',
          );
        }
      } else {
        // Registration failed - handle specific error types
        String errorMessage = _getErrorMessage(userDetails.deviceVerification, userDetails.validationErrors);
        CommonFunctions.showErrorDialog(errorMessage, context);
      }
    } catch (error) {
      CommonFunctions.showErrorDialog('Could not register! Please try again.', context);
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  /// Get user-friendly error message based on server response
  String _getErrorMessage(String? deviceVerification, String? validationErrors) {
    switch (deviceVerification) {
      case 'email-already-exists':
        return 'This email address is already registered. Please use a different email or try signing in instead.';
      case 'validation-error':
        // Show specific validation errors from server
        if (validationErrors != null && validationErrors.isNotEmpty) {
          return validationErrors;
        }
        return 'Please check your information and make sure all fields are filled correctly.';
      case 'registration-failed':
        return 'Registration failed due to a server error. Please try again later.';
      case 'needed-verification':
        return 'Registration successful! Please verify your device to complete the process.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  /// Open privacy policy URL in browser
  Future<void> _openPrivacyPolicy() async {
    const String privacyPolicyUrl = '$BASE_URL/home/privacy_policy';
    final Uri url = Uri.parse(privacyPolicyUrl);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        CommonFunctions.showErrorDialog('Could not open privacy policy page', context);
      }
    } catch (e) {
      CommonFunctions.showErrorDialog('Could not open privacy policy page', context);
    }
  }

  InputDecoration getInputDecoration(String hintext, IconData iconData, {bool isPassword = false}) {
    return InputDecoration(
      labelText: hintext,
      labelStyle: TextStyle(
        color: AppColors.getTextSecondaryColor(context),
        fontSize: 14,
      ),
      hintText: 'Enter your $hintext',
      hintStyle: TextStyle(
        color: AppColors.getTextSecondaryColor(context),
      ),
      filled: true,
      fillColor: AppColors.getBackgroundColor(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.getBorderColor(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.getBorderColor(context)),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(context),
          appBar: AppBar(
            key: scaffoldKey,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.getTextColor(context)),
            backgroundColor: AppColors.getCardColor(context),
            title: Text(
              'Create Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
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
                      'assets/images/do_login.png',
                      height: 40,
                      width: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NSCA Chaplain Certification',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your free account to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sign Up Form Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.getBorderColor(context)),
              ),
              child: Form(
                key: globalFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // First Name Field
                    TextFormField(
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextColor(context),
                      ),
                      decoration: getInputDecoration(
                        'First Name',
                        Icons.person,
                      ),
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _firstNameController.text = value as String;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Last Name Field
                    TextFormField(
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextColor(context),
                      ),
                      decoration: getInputDecoration(
                        'Last Name',
                        Icons.person,
                      ),
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _lastNameController.text = value as String;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Email Field
                    TextFormField(
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextColor(context),
                      ),
                      decoration: getInputDecoration(
                        'Email Address',
                        Icons.email_outlined,
                      ),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _emailController.text = value as String;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Repeat Email Field
                    TextFormField(
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextColor(context),
                      ),
                      decoration: getInputDecoration(
                        'Repeat Email',
                        Icons.email_outlined,
                      ),
                      controller: _repeatEmailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please repeat your email';
                        }
                        if (value != _emailController.text) {
                          return 'Emails do not match';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _repeatEmailController.text = value as String;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    TextFormField(
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextColor(context),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: AppColors.getTextSecondaryColor(context),
                          fontSize: 14,
                        ),
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          color: AppColors.getTextSecondaryColor(context),
                        ),
                        filled: true,
                        fillColor: AppColors.getBackgroundColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
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
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.getTextSecondaryColor(context),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      controller: _passwordController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                      obscureText: hidePassword,
                      onSaved: (value) {
                        _passwordController.text = value as String;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Repeat Password Field
                    TextFormField(
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextColor(context),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Repeat Password',
                        labelStyle: TextStyle(
                          color: AppColors.getTextSecondaryColor(context),
                          fontSize: 14,
                        ),
                        hintText: 'Repeat your password',
                        hintStyle: TextStyle(
                          color: AppColors.getTextSecondaryColor(context),
                        ),
                        filled: true,
                        fillColor: AppColors.getBackgroundColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
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
                            setState(() {
                              hideRepeatPassword = !hideRepeatPassword;
                            });
                          },
                          icon: Icon(
                            hideRepeatPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.getTextSecondaryColor(context),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      controller: _repeatPasswordController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please repeat your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      obscureText: hideRepeatPassword,
                      onSaved: (value) {
                        _repeatPasswordController.text = value as String;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Phone Field with Type Dropdown
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.getTextColor(context),
                            ),
                            decoration: getInputDecoration(
                              'Phone Number',
                              Icons.phone,
                            ),
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _phoneController.text = value as String;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            initialValue: _phoneType,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Type',
                              labelStyle: TextStyle(
                                color: AppColors.getTextSecondaryColor(context),
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: AppColors.getBackgroundColor(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                            ),
                            items: ['Mobile', 'Home', 'Work', 'Other']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14, color: AppColors.getTextColor(context)),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _phoneType = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Privacy Policy Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          activeColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.getTextSecondaryColor(context),
                              ),
                              children: [
                                const TextSpan(text: 'By creating an account, you agree to our '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _openPrivacyPolicy,
                                    child: const Text(
                                      'NSCA Privacy Policy',
                                      style: TextStyle(
                                        color: kPrimaryColor,
                                        decoration: TextDecoration.underline,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: kTextColorLight,
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
                                  color: kTextColorLight,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Sign Up',
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
            
            // Sign In Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.getBorderColor(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: AppColors.getTextSecondaryColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
                    },
                    child: const Text(
                      'Sign In',
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
      },
    );
  }
}
