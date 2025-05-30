import 'dart:convert';
import 'dart:io';
import '../models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'shared_pref_helper.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _userId;
  final User _user = User(
    userId: '',
    firstName: '',
    lastName: '',
    email: '',
    role: '',
    validity: '',
    deviceVerification: '',
    token: '',
  );

  String? get token {
    if (_token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    if (_userId != null) {
      return _userId;
    }
    return null;
  }

  User get user {
    return _user;
  }

  Future<void> login(String email, String password) async {
    var url = '$BASE_URL/api/login?email=$email&password=$password';

    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['validity'] == 0) {
          _user.validity = responseData['validity'];
          _user.deviceVerification = responseData['device_verification'];
          // throw const HttpException('Wrong credentials');
        } else {
          _user.userId = responseData['user_id'];
          _user.firstName = responseData['first_name'];
          _user.lastName = responseData['last_name'];
          _user.email = responseData['email'];
          _user.role = responseData['role'];
          _user.validity = responseData['validity'];
          _user.deviceVerification = responseData['device_verification'];
          _user.token = responseData['token'];

          _token = responseData['token'];
          _userId = responseData['user_id'];

          await SharedPreferenceHelper().setAuthToken(token!);
          final prefs = await SharedPreferences.getInstance();
          final userData = json.encode({
            'token': _token,
            'user_id': _userId,
            'user': jsonEncode(_user),
          });
          prefs.setString('userData', userData);
        }
      } else {
        _user.validity = responseData['validity'];
        _user.deviceVerification = responseData['device_verification'];
        // throw const HttpException('Auth Failed');
      }

      // _token = responseData['token'];
      // _userId = responseData['user_id'];

      // final loadedUser = User(
      //   userId: responseData['user_id'],
      //   firstName: responseData['first_name'],
      //   lastName: responseData['last_name'],
      //   email: responseData['email'],
      //   role: responseData['role'],
      //   deviceVerification: responseData['device_verification'],
      // );

      // _user = loadedUser;

      notifyListeners();

      // debugPrintuserData);
    } catch (error) {
      rethrow;
    }
  }

  // Future<void> login(String email, String password) async {
  //   var url = '$BASE_URL/api/login?email=$email&password=$password';

  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     final responseData = json.decode(response.body);

  //     // debugPrint(rintresponseData['validity']);
  //     if (responseData['validity'] == 0) {
  //       throw const HttpException('Auth Failed');
  //     }
  //     _token = responseData['token'];
  //     _userId = responseData['user_id'];

  //     final loadedUser = User(
  //       userId: responseData['user_id'],
  //       firstName: responseData['first_name'],
  //       lastName: responseData['last_name'],
  //       email: responseData['email'],
  //       role: responseData['role'],
  //     );

  //     _user = loadedUser;

  //     notifyListeners();
  //     await SharedPreferenceHelper().setAuthToken(token!);
  //     final prefs = await SharedPreferences.getInstance();
  //     final userData = json.encode({
  //       'token': _token,
  //       'user_id': _userId,
  //       'user': jsonEncode(_user),
  //     });
  //     prefs.setString('userData', userData);
  //     // debugPrint(rintuserData);
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

  Future<void> getUserInfo() async {
    // final prefs = await SharedPreferences.getInstance();

    // var userData = (prefs.getString('userData') ?? '');
    // var response = json.decode(userData);
    // final authToken = response['token'];
    // debugPrint(rintresponse['user']);
    final authToken = await SharedPreferenceHelper().getAuthToken();
    var url = '$BASE_URL/api/userdata?auth_token=$authToken';
    try {
      if (authToken == null) {
        throw const HttpException('No Auth User');
      }
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);

      _user.firstName = responseData['first_name'];
      _user.lastName = responseData['last_name'];
      _user.email = responseData['email'];
      _user.image = responseData['image'];
      _user.facebook = responseData['facebook'];
      _user.twitter = responseData['twitter'];
      _user.linkedIn = responseData['linkedin'];
      _user.biography = responseData['biography'];
      // debugPrint(rint_user.image);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> userImageUpload(File image) async {
    final token = await SharedPreferenceHelper().getAuthToken();
    var url = '$BASE_URL/api/upload_user_image';
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.fields['auth_token'] = token!;

    request.files.add(
      http.MultipartFile(
        'file',
        image.readAsBytes().asStream(),
        image.lengthSync(),
        filename: basename(image.path),
      ),
    );

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((value) {
          final responseData = json.decode(value);
          if (responseData['status'] != 'success') {
            throw const HttpException('Upload Failed');
          }
          notifyListeners();
          // debugPrint(rintvalue);
        });
      }

      // final responseData = json.decode(response.body);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    // _user = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    prefs.clear();
  }

  Future<void> updateUserData(User user) async {
    final token = await SharedPreferenceHelper().getAuthToken();
    const url = '$BASE_URL/api/update_userdata';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'auth_token': token,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'email': user.email,
          'biography': user.biography,
          'twitter_link': user.twitter,
          'facebook_link': user.facebook,
          'linkedin_link': user.linkedIn,
        },
      );

      final responseData = json.decode(response.body);
      if (responseData['status'] == 'failed') {
        throw const HttpException('Update Failed');
      }

      _user.firstName = responseData['first_name'];
      _user.lastName = responseData['last_name'];
      _user.email = responseData['email'];
      _user.image = responseData['image'];
      _user.twitter = responseData['twitter'];
      _user.linkedIn = responseData['linkedin'];
      _user.biography = responseData['biography'];
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateUserPassword(
    String currentPassword,
    String newPassword,
  ) async {
    final token = await SharedPreferenceHelper().getAuthToken();
    const url = '$BASE_URL/api/update_password';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'auth_token': token,
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': newPassword,
        },
      );

      final responseData = json.decode(response.body);
      if (responseData['status'] == 'failed') {
        throw const HttpException('Password update Failed');
      }
    } catch (error) {
      rethrow;
    }
  }
}
