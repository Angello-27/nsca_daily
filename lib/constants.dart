// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

const String BASE_URL = 'https://www.nscaacademy.org';
// const String BASE_URL = 'http://10.10.10.195/nsca-lms';

// list of colors that we use in our app
const kBackgroundColor = Color(0xFF171719); // Dark background
const kPrimaryColor = Color(0xFFFFC600); // Yellow primary
const kSecondaryColor = Color(0xFF313A46); // Alternative gray
const kTextColor = Color(0xFFFFFFFF); // White text
const kTextSecondaryColor = Color(0xFFB0B0B0); // Light gray text
const kCardColor = Color(0xFF1F1F1F); // Card background
const kBorderColor = Color(0xFF2A2A2A); // Border color
const kRedColor = Color(0xFFEC5252);
const kBlueColor = Color(0xFF68B0FF);
const kGreenColor = Color(0xFF43CB65);
const kStarColor = Color(0xFFEFD358);
const kLightBlueColor = Color(0xFF4AA8D4);
const kSelectItemColor = Color(0xFFFFFFFF);
const kDarkButtonBg = Color(0xFF273546);
const kGreenPurchaseColor = Color(0xFF2BD0A8);
const kToastTextColor = Color(0xFFEEEEEE);
const kTextLightColor = Color(0xFF000000);
const kTextLowBlackColor = Colors.black38;
const kDeepBlueColor = Color(0xFF594CF5);
const kTabBarBg = Color(0xFFEEEEEE);
const kDarkGreyColor = Color(0xFF757575);
const kTextBlueColor = Color(0xFF5594bf);
const kTimeColor = Color(0xFF366cc6);
const kTimeBackColor = Color(0xFFe3ebf5);
const kLessonBackColor = Color(0xFFf8e5d2);
const kFormInputColor = Color(0xFFc7c8ca);
const kNoteColor = Color(0xFFbfdde4);
const kLiveClassColor = Color(0xFFfff3cd);
const kSectionTileColor = Color(0xFFdddcdd);
const iCardColor = Color(0xFFF4F8F9);
const iLongArrowRightColor = Color(0xFF559595);

const kDefaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12.0)),
  borderSide: BorderSide(color: kTimeBackColor, width: 1),
);

const kDefaultFocusInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12.0)),
  borderSide: BorderSide(color: kStarColor, width: 2),
);
const kDefaultFocusErrorBorder = OutlineInputBorder(
  borderSide: BorderSide(color: kRedColor),
  borderRadius: BorderRadius.all(Radius.circular(12.0)),
);

// our default Shadow
const kDefaultShadow = BoxShadow(
  offset: Offset(20, 10),
  blurRadius: 20,
  color: Colors.black12, // Black color with 12% opacity
);

enum CoursesPageData { Category, Filter, Search, All }
