// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import '../models/common_functions.dart';
import '../providers/auth.dart';
import '../providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class EditPasswordScreen extends StatefulWidget {
  static const routeName = '/edit-password';
  const EditPasswordScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  bool hidePassword = true;
  var _isLoading = false;
  final Map<String, String> _passwordData = {
    'oldPassword': '',
    'newPassword': '',
  };
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }
    _formKey.currentState!.save();
    
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false).updateUserPassword(
        _passwordData['oldPassword'].toString(),
        _passwordData['newPassword'].toString(),
      );

      HapticFeedback.heavyImpact();
      CommonFunctions.showSuccessToast('Password updated Successfully');
      Navigator.of(context).pop();
    } on HttpException {
      HapticFeedback.heavyImpact();
      var errorMsg = 'Password Update failed';
      CommonFunctions.showErrorDialog(errorMsg, context);
    } catch (error) {
      HapticFeedback.heavyImpact();
      const errorMsg = 'Password Update failed!';
      CommonFunctions.showErrorDialog(errorMsg, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  InputDecoration getInputDecoration(String hintext, IconData iconData) {
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
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            hidePassword = !hidePassword;
          });
        },
        color: AppColors.getTextSecondaryColor(context),
        icon: Icon(
          hidePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
        ),
      ),
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
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.getTextColor(context)),
            backgroundColor: AppColors.getCardColor(context),
            title: Text(
              'Change Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
            ),
          ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            )
          : SingleChildScrollView(
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
                          child: const Icon(
                            Icons.lock_outline,
                            color: kPrimaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Update Password',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Change your account password',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.getTextSecondaryColor(context),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Password Form Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.getBorderColor(context)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Current Password
                          TextFormField(
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.getTextColor(context),
                            ),
                            decoration: getInputDecoration(
                              'Current Password',
                              Icons.vpn_key,
                            ),
                            obscureText: hidePassword,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Current password cannot be empty';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _passwordData['oldPassword'] = value.toString();
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // New Password
                          TextFormField(
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.getTextColor(context),
                            ),
                            decoration: getInputDecoration(
                              'New Password',
                              Icons.vpn_key,
                            ),
                            obscureText: hidePassword,
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty || value.length < 4) {
                                return 'Password must be at least 4 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _passwordData['newPassword'] = value.toString();
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Confirm Password
                          TextFormField(
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.getTextColor(context),
                            ),
                            decoration: getInputDecoration(
                              'Confirm Password',
                              Icons.vpn_key,
                            ),
                            obscureText: hidePassword,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Update Button
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
                                      'Update Password',
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
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
        );
      },
    );
  }
}
