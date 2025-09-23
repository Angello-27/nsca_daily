// ignore_for_file: use_build_context_synchronously

import '../models/common_functions.dart';
import '../models/update_user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'auth_screen.dart';
import 'verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

Future<UpdateUserModel> signUp(
  String firstName,
  String lastName,
  String email,
  String password,
  String phone,
  String phoneType,
) async {
  const String apiUrl = "$BASE_URL/api/signup";

  final response = await http.post(
    Uri.parse(apiUrl),
    body: {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'type-phone': phoneType,
    },
  );

  if (response.statusCode == 200) {
    final String responseString = response.body;

    return updateUserModelFromJson(responseString);
  } else {
    throw Exception('Failed to load data');
  }
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
      final UpdateUserModel user = await signUp(
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _passwordController.text,
        _phoneController.text,
        _phoneType,
      );

      if (user.emailVerification == 'enable') {
        if (user.message ==
            "You have already signed up. Please check your inbox to verify your email address") {
          Navigator.of(context).pushNamed(
            VerificationScreen.routeName,
            arguments: _emailController.text,
          );
          CommonFunctions.showSuccessToast(user.message.toString());
        } else {
          Navigator.of(context).pushNamed(
            VerificationScreen.routeName,
            arguments: _emailController.text,
          );
          CommonFunctions.showSuccessToast(user.message.toString());
        }
      } else {
        Navigator.of(context).pushNamed(AuthScreen.routeName);
        CommonFunctions.showSuccessToast('Signup Successful');
      }
    } catch (error) {
      const errorMsg = 'Could not register!';
      // debugPrint(error);
      CommonFunctions.showErrorDialog(errorMsg, context);
    }
    setState(() {
      _isLoading = false;
    });
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
          'Create Account',
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
                    'NSCA Chaplain Certification',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: kTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your free account to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: kTextSecondaryColor,
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
                      'Account Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // First Name Field
                    TextFormField(
                      style: const TextStyle(
                        fontSize: 16,
                        color: kTextColor,
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: kTextColor,
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: kTextColor,
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: kTextColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Repeat Password',
                        labelStyle: const TextStyle(
                          color: kTextSecondaryColor,
                          fontSize: 14,
                        ),
                        hintText: 'Repeat your password',
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
                            setState(() {
                              hideRepeatPassword = !hideRepeatPassword;
                            });
                          },
                          icon: Icon(
                            hideRepeatPassword
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
                            style: const TextStyle(
                              fontSize: 16,
                              color: kTextColor,
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
                              labelStyle: const TextStyle(
                                color: kTextSecondaryColor,
                                fontSize: 14,
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                            ),
                            items: ['Mobile', 'Home', 'Work', 'Other']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14, color: kTextColor),
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
                              style: const TextStyle(
                                fontSize: 14,
                                color: kTextSecondaryColor,
                              ),
                              children: [
                                const TextSpan(text: 'By creating an account, you agree to our '),
                                TextSpan(
                                  text: 'NSCA Privacy Policy',
                                  style: const TextStyle(
                                    color: kPrimaryColor,
                                    decoration: TextDecoration.underline,
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
                color: kCardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: kTextSecondaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(AuthScreen.routeName);
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
  }
}
