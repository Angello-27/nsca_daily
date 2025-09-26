// ignore_for_file: use_build_context_synchronously

import '../models/common_functions.dart';
import '../models/update_user_model.dart';
import '../providers/theme_provider.dart';
import '../screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  static const routeName = '/reset';
  const ForgotPassword({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

Future<UpdateUserModel> resendCode(String email) async {
  const String apiUrl = "$BASE_URL/api/forgot_password";

  final response = await http.post(Uri.parse(apiUrl), body: {'email': email});

  if (response.statusCode == 200) {
    final String responseString = response.body;

    return updateUserModelFromJson(responseString);
  } else {
    throw Exception('Failed to load data');
  }
}

class _ForgotPasswordState extends State<ForgotPassword> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  var _isLoading = false;
  final _emailController = TextEditingController();

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final UpdateUserModel user = await resendCode(_emailController.text);

      if (user.status == 200) {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
        CommonFunctions.showSuccessToast(user.message.toString());
      } else {
        CommonFunctions.showErrorDialog(user.message.toString(), context);
      }
    } catch (error) {
      const errorMsg = 'Error Occurred';
      CommonFunctions.showErrorDialog(errorMsg, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  InputDecoration getInputDecoration(String hintext, IconData iconData) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.getBorderColor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.getBorderColor(context)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kRedColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kRedColor),
      ),
      filled: true,
      prefixIcon: Icon(iconData, color: AppColors.getTextSecondaryColor(context)),
      hintStyle: TextStyle(color: AppColors.getTextSecondaryColor(context), fontSize: 14),
      hintText: hintext,
      fillColor: AppColors.getCardColor(context),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
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
          ),
      body: SingleChildScrollView(
        child: Padding(
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
                        height: MediaQuery.of(context).size.height * .12,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Reset Your Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your email address and we\'ll send you a link to reset your password',
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

              // Form Section
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
                        'Email Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        style: TextStyle(fontSize: 16, color: AppColors.getTextColor(context)),
                        decoration: getInputDecoration(
                          'Enter your email address',
                          Icons.email_outlined,
                        ),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (input) =>
                            !RegExp(
                              r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
                            ).hasMatch(input!)
                                ? "Please enter a valid email address"
                                : null,
                        onSaved: (value) {
                          _emailController.text = value as String;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: kPrimaryColor,
                                  backgroundColor: AppColors.getCardColor(context),
                                ),
                              )
                            : MaterialButton(
                                elevation: 0,
                                color: kPrimaryColor,
                                onPressed: _submit,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Send Reset Link',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: kTextColorLight,
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

              // Back to Sign In
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
                      'Remember your password? ',
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
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
            ],
          ),
        ),
      ),
        );
      },
    );
  }
}
