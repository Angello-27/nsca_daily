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
    image = await SharedPreferenceHelper().getUserImage();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
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
              backgroundImage:
                  _image != null
                      ? FileImage(_image!)
                      : NetworkImage(widget.image.toString()) as ImageProvider,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: 45,
                      width: 45,
                      child: FittedBox(
                        child: FloatingActionButton(
                          elevation: 1,
                          onPressed: _pickImage,
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
                  color: kPrimaryColor.withOpacity(0.7),
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
