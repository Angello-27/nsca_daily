import '../constants.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

class CommonFunctions {
  static void showErrorDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('An Error Occurred!'),
            content: Text(message, style: const TextStyle(color: Colors.red)),
            actions: <Widget>[
              MaterialButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  static void showSuccessToast(String message) {
    /*Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      // backgroundColor: Colors.blueGrey,
      // textColor: kToastTextColor,
      // fontSize: 16.0
    );*/
  }

  static void showWarningToast(String message) {
    /*Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color.fromARGB(255, 231, 122, 122),
      textColor: kToastTextColor,
      fontSize: 16.0,
    );*/
  }
}
