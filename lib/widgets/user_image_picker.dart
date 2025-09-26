// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import '../models/common_functions.dart';
import '../providers/auth.dart';
import '../providers/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants.dart';
import 'custom_text.dart';

class UserImagePicker extends StatefulWidget {
  final String? image;
  const UserImagePicker({super.key, this.image});

  @override
  // ignore: library_private_types_in_public_api
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _image;
  final picker = ImagePicker();
  var _isLoading = false;
  dynamic image;

  void _pickImage() async {
    // Verificar permisos antes de acceder a la galería
    // Para Android 13+ usar READ_MEDIA_IMAGES, para versiones anteriores usar storage
    PermissionStatus permission;
    if (Platform.isAndroid) {
      // Para Android 13+ (API 33+) usar photos, para versiones anteriores usar storage
      // Android 11 (API 30), Android 12 (API 31) necesitan storage
      // Android 13+ (API 33+) usa photos (READ_MEDIA_IMAGES)
      permission = await Permission.storage.request();
    } else {
      // Para iOS usar photos
      permission = await Permission.photos.request();
    }
    
    if (permission.isGranted) {
      image = await SharedPreferenceHelper().getUserImage();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      // Check if user actually selected an image (didn't cancel)
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else if (permission.isDenied) {
      // Mostrar mensaje explicativo
      _showPermissionDialog(
        'Storage Permissions',
        'This app needs access to your device storage to select profile photos. Please allow access in settings.',
      );
    } else if (permission.isPermanentlyDenied) {
      // Abrir configuración de la app
      _showPermissionDialog(
        'Permissions Required',
        'Storage permissions have been permanently denied. Please go to Settings > Apps > NSCA Daily > Permissions and allow storage access.',
        showSettingsButton: true,
      );
    }
  }

  void _pickImageFromCamera() async {
    // Verificar permisos de cámara
    final permission = await Permission.camera.request();
    
    if (permission.isGranted) {
      image = await SharedPreferenceHelper().getUserImage();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      
      // Check if user actually selected an image (didn't cancel)
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else if (permission.isDenied) {
      // Mostrar mensaje explicativo
      _showPermissionDialog(
        'Camera Permissions',
        'This app needs access to your camera to take profile photos. Please allow access in settings.',
      );
    } else if (permission.isPermanentlyDenied) {
      // Abrir configuración de la app
      _showPermissionDialog(
        'Permissions Required',
        'Camera permissions have been permanently denied. Please go to Settings > Apps > NSCA Daily > Permissions and allow camera access.',
        showSettingsButton: true,
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: kPrimaryColor),
                title: const Text('Select from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: kPrimaryColor),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPermissionDialog(String title, String message, {bool showSettingsButton = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (showSettingsButton)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Settings'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitImage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Log user in
      await Provider.of<Auth>(context, listen: false).userImageUpload(_image!);
      CommonFunctions.showSuccessToast('Image uploaded Successfully');
      final token = await SharedPreferenceHelper().getAuthToken();
      var link = '$BASE_URL/api/userdata?auth_token=$token';
      final res = await http.get(Uri.parse(link));
      final resData = json.decode(res.body);
      await SharedPreferenceHelper().setUserImage(resData['image'].toString());
    } on HttpException {
      // debugPrint(error);
      var errorMsg = 'Upload failed.';

      CommonFunctions.showErrorDialog(errorMsg, context);
    } catch (error) {
      // debugPrint(error);
      const errorMsg = 'Upload failed.';
      CommonFunctions.showErrorDialog(errorMsg, context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<Auth>(context, listen: false).user;
    return Column(
      children: <Widget>[
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _image != null
                  ? FileImage(_image!)
                  : (widget.image != null && widget.image!.isNotEmpty)
                      ? NetworkImage(widget.image!)
                      : null,
              backgroundColor: kLightBlueColor,
              child: Stack(
                children: [
                  // Show person icon if no image is available
                  if (_image == null && (widget.image == null || widget.image!.isEmpty))
                    const Center(
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: kTextColor,
                      ),
                    ),
                  // Camera button overlay
                  Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: 45,
                      width: 45,
                      child: FittedBox(
                        child: FloatingActionButton(
                          elevation: 1,
                          onPressed: _showImageSourceDialog,
                          tooltip: 'Choose Image',
                          backgroundColor: Colors.white,
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundColor: kPrimaryColor,
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_image != null)
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor.withValues(alpha: 0.7),
                ),
              )
              : ElevatedButton.icon(
                onPressed: _submitImage,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  backgroundColor: kPrimaryColor,
                ),
                icon: const Icon(Icons.file_upload, color: Colors.white),
                label: const CustomText(
                  text: 'Upload Image',
                  fontSize: 14,
                  colors: Colors.white,
                ),
              ),
      ],
    );
  }
}
