// ignore_for_file: use_build_context_synchronously

import '../models/common_functions.dart';
import '../providers/course_forum.dart';
import '../widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class AskQuestionWidget extends StatefulWidget {
  static const routeName = '/ask-question';
  final int courseId;
  const AskQuestionWidget({super.key, required this.courseId});

  @override
  State<AskQuestionWidget> createState() => _AskQuestionWidgetState();
}

class _AskQuestionWidgetState extends State<AskQuestionWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  bool _isLoading = false;
  dynamic title;
  dynamic description;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<CourseForum>(
        context,
        listen: false,
      ).addForumQuestion(widget.courseId, title, description);
      CommonFunctions.showSuccessToast('User updated Successfully');
      Navigator.of(context).pop();
    } catch (error) {
      // debugPrint(error);
      const errorMsg = 'Update failed!';
      CommonFunctions.showErrorDialog(errorMsg, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  InputDecoration getInputDecoration(String hintext, IconData iconData) {
    return InputDecoration(
      enabledBorder: kDefaultInputBorder,
      focusedBorder: kDefaultFocusInputBorder,
      focusedErrorBorder: kDefaultFocusErrorBorder,
      errorBorder: kDefaultFocusErrorBorder,
      filled: true,
      hintStyle: const TextStyle(color: kFormInputColor),
      hintText: hintext,
      fillColor: Colors.white70,
      prefixIcon: Icon(iconData, color: kFormInputColor),
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const CustomText(
          text: 'Ask your question',
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: kSecondaryColor, //change your color here
        ),
        backgroundColor: kBackgroundColor,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.cancel_outlined,
              color: kSecondaryColor,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                        child: Text(
                          'Title of summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      style: const TextStyle(fontSize: 16),
                      decoration: getInputDecoration(
                        'Title of summary',
                        Icons.title,
                      ),
                      keyboardType: TextInputType.text,
                      onSaved: (value) {
                        setState(() {
                          title = value.toString();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                        child: Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      style: const TextStyle(fontSize: 16),
                      decoration: getInputDecoration('Details', Icons.edit),
                      keyboardType: TextInputType.text,
                      maxLines: 10,
                      onSaved: (value) {
                        setState(() {
                          description = value.toString();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child:
                          _isLoading
                              ? Center(
                                child: CircularProgressIndicator(
                                  color: kPrimaryColor.withOpacity(0.7),
                                ),
                              )
                              : MaterialButton(
                                onPressed: _submit,
                                color: kPrimaryColor,
                                textColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                splashColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  side: const BorderSide(color: kPrimaryColor),
                                ),
                                child: const Text(
                                  'Publish',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
