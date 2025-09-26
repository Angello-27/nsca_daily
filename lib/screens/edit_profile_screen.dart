// ignore_for_file: use_build_context_synchronously

import '../constants.dart';
import '../providers/auth.dart';
import '../providers/theme_provider.dart';
import '../widgets/user_image_picker.dart';
import '../models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final Map<String, String> _userData = {
    'first_name': '',
    'last_name': '',
    'email': '',
    'role': '',
    'validity': '',
    'device_verification': '',
    'token': '',
    'twitter': '',
    'facebook': '',
    'linkedin': '',
  };

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  InputDecoration getInputDecoration(String hintext, IconData iconData) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(
          color: AppColors.getBorderColor(context),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: kPrimaryColor, width: 2.5),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        borderRadius: BorderRadius.circular(16.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: kRedColor, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: kRedColor, width: 1.5),
      ),
      filled: true,
      prefixIcon: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kPrimaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(iconData, color: kPrimaryColor, size: 20),
      ),
      hintStyle: TextStyle(
        color: AppColors.getTextSecondaryColor(context),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintText: hintext,
      fillColor: AppColors.getBackgroundColor(context),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      errorStyle: const TextStyle(
        color: kRedColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

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
      final user = Provider.of<Auth>(context, listen: false).user;
      final updatedUser = User(
        userId: user.userId,
        firstName: _userData['first_name']!,
        lastName: _userData['last_name']!,
        email: user.email,
        role: user.role,
        validity: user.validity,
        deviceVerification: user.deviceVerification,
        token: user.token,
        image: user.image,
        facebook: _userData['facebook']!,
        twitter: _userData['twitter']!,
        linkedIn: _userData['linkedin']!,
        biography: user.biography,
      );

      await Provider.of<Auth>(
        context,
        listen: false,
      ).updateUserData(updatedUser);

      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: kGreenColor,
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $error'),
          backgroundColor: kRedColor,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
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
              'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
            ),
          ),
      body: FutureBuilder(
        future:
            Provider.of<Auth>(context, listen: false).loadUserDataFromCache(),
        builder: (ctx, cacheSnapshot) {
          if (cacheSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          } else {
            return Consumer<Auth>(
              builder: (context, authData, child) {
                final user = authData.user;

                // Check if we have basic user info (from cache)
                if (user.firstName == null || user.firstName!.isEmpty) {
                  // If no user info at all, show error
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No User Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please log in again',
                          style: TextStyle(
                            color: AppColors.getTextSecondaryColor(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => Navigator.pushReplacementNamed(
                                context,
                                '/auth',
                              ),
                          child: const Text('Go to Login'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // We have user info, show the edit profile screen and update in background
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // Update user data in background without blocking UI
                    authData.updateUserDataInBackground();
                  });
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Profile Picture Section
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
                              Text(
                                'Profile Picture',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getTextColor(context),
                                ),
                              ),
                              const SizedBox(height: 20),
                              UserImagePicker(image: user.image),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Personal Information Section
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
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.getTextColor(context),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // First Name
                                TextFormField(
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.getTextColor(context),
                                  ),
                                  initialValue: user.firstName,
                                  decoration: InputDecoration(
                                    labelText: 'First Name',
                                    labelStyle: TextStyle(
                                      color: AppColors.getTextSecondaryColor(context),
                                      fontSize: 14,
                                    ),
                                    hintText: 'Enter your first name',
                                    hintStyle: TextStyle(
                                      color: AppColors.getTextSecondaryColor(context),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.getBackgroundColor(context),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.getBorderColor(context),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.getBorderColor(context),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: kPrimaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'First name cannot be empty';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _userData['first_name'] = value.toString();
                                    _firstNameController.text = value as String;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Last Name
                                TextFormField(
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.getTextColor(context),
                                  ),
                                  initialValue: user.lastName,
                                  decoration: InputDecoration(
                                    labelText: 'Last Name',
                                    labelStyle: TextStyle(
                                      color: AppColors.getTextSecondaryColor(context),
                                      fontSize: 14,
                                    ),
                                    hintText: 'Enter your last name',
                                    hintStyle: TextStyle(
                                      color: AppColors.getTextSecondaryColor(context),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.getBackgroundColor(context),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.getBorderColor(context),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.getBorderColor(context),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: kPrimaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Last name cannot be empty';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _userData['last_name'] = value.toString();
                                    _lastNameController.text = value as String;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Social Links Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.getCardColor(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.getBorderColor(context)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Social Links',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getTextColor(context),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Facebook Link
                              TextFormField(
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.getTextColor(context),
                                ),
                                initialValue: user.facebook,
                                decoration: InputDecoration(
                                  labelText: 'Facebook',
                                  labelStyle: TextStyle(
                                    color: AppColors.getTextSecondaryColor(context),
                                    fontSize: 14,
                                  ),
                                  hintText: 'Enter your Facebook profile URL',
                                  hintStyle: TextStyle(
                                    color: AppColors.getTextSecondaryColor(context),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.getBackgroundColor(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.getBorderColor(context),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.getBorderColor(context),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: kPrimaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.next,
                                onSaved: (value) {
                                  _userData['facebook'] = value.toString();
                                },
                              ),

                              const SizedBox(height: 20),

                              // Twitter Link
                              TextFormField(
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.getTextColor(context),
                                ),
                                initialValue: user.twitter,
                                decoration: InputDecoration(
                                  labelText: 'Twitter',
                                  labelStyle: TextStyle(
                                    color: AppColors.getTextSecondaryColor(context),
                                    fontSize: 14,
                                  ),
                                  hintText: 'Enter your Twitter profile URL',
                                  hintStyle: TextStyle(
                                    color: AppColors.getTextSecondaryColor(context),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.getBackgroundColor(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.getBorderColor(context),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.getBorderColor(context),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: kPrimaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.next,
                                onSaved: (value) {
                                  _userData['twitter'] = value.toString();
                                },
                              ),

                              const SizedBox(height: 20),

                              // LinkedIn Link
                              TextFormField(
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.getTextColor(context),
                                ),
                                initialValue: user.linkedIn,
                                decoration: InputDecoration(
                                  labelText: 'LinkedIn',
                                  labelStyle: TextStyle(
                                    color: AppColors.getTextSecondaryColor(context),
                                    fontSize: 14,
                                  ),
                                  hintText: 'Enter your LinkedIn profile URL',
                                  hintStyle: TextStyle(
                                    color: AppColors.getTextSecondaryColor(context),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.getBackgroundColor(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.getBorderColor(context),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.getBorderColor(context),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: kPrimaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                onSaved: (value) {
                                  _userData['linkedin'] = value.toString();
                                },
                              ),
                            ],
                          ),
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
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: kTextColorLight,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                    : const Text(
                                      'Update Profile',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
        );
      },
    );
  }
}
