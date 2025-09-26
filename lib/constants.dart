// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

// const String BASE_URL = 'https://www.nscaacademy.org';
const String BASE_URL = 'http://10.10.10.195/nsca-lms';

// Common colors (same for both themes)
const kPrimaryColor = Color(0xFFFFC600); // Yellow primary
const kRedColor = Color(0xFFEC5252);
const kBlueColor = Color(0xFF68B0FF);
const kGreenColor = Color(0xFF43CB65);
const kStarColor = Color(0xFFEFD358);
const kLightBlueColor = Color(0xFF4AA8D4);
const kGreenPurchaseColor = Color(0xFF2BD0A8);
const kDeepBlueColor = Color(0xFF594CF5);
const kTextBlueColor = Color(0xFF5594bf);
const kTimeColor = Color(0xFF366cc6);
const iLongArrowRightColor = Color(0xFF559595);

// Dark theme colors (default)
const kBackgroundColorDark = Color(0xFF171719); // Dark background
const kSecondaryColorDark = Color(0xFF313A46); // Alternative gray
const kTextColorDark = Color(0xFFFFFFFF); // White text
const kTextSecondaryColorDark = Color(0xFFB0B0B0); // Light gray text
const kCardColorDark = Color(0xFF1F1F1F); // Card background
const kBorderColorDark = Color(0xFF2A2A2A); // Border color
const kSelectItemColorDark = Color(0xFFFFFFFF);
const kDarkButtonBgDark = Color(0xFF273546);
const kToastTextColorDark = Color(0xFFEEEEEE);
const kTextLightColorDark = Color(0xFF000000);
const kTextLowBlackColorDark = Colors.black38;
const kTabBarBgDark = Color(0xFFEEEEEE);
const kDarkGreyColorDark = Color(0xFF757575);
const kTimeBackColorDark = Color(0xFFe3ebf5);
const kLessonBackColorDark = Color(0xFFf8e5d2);
const kFormInputColorDark = Color(0xFFc7c8ca);
const kNoteColorDark = Color(0xFFbfdde4);
const kLiveClassColorDark = Color(0xFFfff3cd);
const kSectionTileColorDark = Color(0xFFdddcdd);
const iCardColorDark = Color(0xFFF4F8F9);

// Light theme colors
const kBackgroundColorLight = Color(0xFFF5F5F5); // Light background
const kSecondaryColorLight = Color(0xFFE0E0E0); // Light gray
const kTextColorLight = Color(0xFF212121); // Dark text
const kTextSecondaryColorLight = Color(0xFF757575); // Medium gray text
const kCardColorLight = Color(0xFFFFFFFF); // White card background
const kBorderColorLight = Color(0xFFE0E0E0); // Light border
const kSelectItemColorLight = Color(0xFF212121);
const kDarkButtonBgLight = Color(0xFFF5F5F5);
const kToastTextColorLight = Color(0xFF212121);
const kTextLightColorLight = Color(0xFFFFFFFF);
const kTextLowBlackColorLight = Colors.white38;
const kTabBarBgLight = Color(0xFFF5F5F5);
const kDarkGreyColorLight = Color(0xFF9E9E9E);
const kTimeBackColorLight = Color(0xFFE3F2FD);
const kLessonBackColorLight = Color(0xFFFFF3E0);
const kFormInputColorLight = Color(0xFFE0E0E0);
const kNoteColorLight = Color(0xFFE1F5FE);
const kLiveClassColorLight = Color(0xFFFFF8E1);
const kSectionTileColorLight = Color(0xFFF5F5F5);
const iCardColorLight = Color(0xFFFAFAFA);

// Legacy constants for backward compatibility (using dark theme)
const kBackgroundColor = kBackgroundColorDark;
const kSecondaryColor = kSecondaryColorDark;
const kTextColor = kTextColorDark;
const kTextSecondaryColor = kTextSecondaryColorDark;
const kCardColor = kCardColorDark;
const kBorderColor = kBorderColorDark;
const kSelectItemColor = kSelectItemColorDark;
const kDarkButtonBg = kDarkButtonBgDark;
const kToastTextColor = kToastTextColorDark;
const kTextLightColor = kTextLightColorDark;
const kTextLowBlackColor = kTextLowBlackColorDark;
const kTabBarBg = kTabBarBgDark;
const kDarkGreyColor = kDarkGreyColorDark;
const kTimeBackColor = kTimeBackColorDark;
const kLessonBackColor = kLessonBackColorDark;
const kFormInputColor = kFormInputColorDark;
const kNoteColor = kNoteColorDark;
const kLiveClassColor = kLiveClassColorDark;
const kSectionTileColor = kSectionTileColorDark;
const iCardColor = iCardColorDark;

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

// Theme helper functions
class AppColors {
  static Color getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? kBackgroundColorDark : kBackgroundColorLight;
  }
  
  static Color getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? kTextColorDark : kTextColorLight;
  }
  
  static Color getTextSecondaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? kTextSecondaryColorDark : kTextSecondaryColorLight;
  }
  
  static Color getCardColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? kCardColorDark : kCardColorLight;
  }
  
  static Color getBorderColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? kBorderColorDark : kBorderColorLight;
  }
  
  static Color getSecondaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? kSecondaryColorDark : kSecondaryColorLight;
  }
}

enum CoursesPageData { Category, Filter, Search, All }
