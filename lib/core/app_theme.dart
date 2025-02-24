import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF6700); // Culoarea principală

  // Nuanțe de gri de la alb la negru
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE2E4E9);
  static const Color grey300 = Color(0xFFDBDBDB);
  static const Color grey400 = Color(0xFFB6B6B6);
  static const Color grey500 = Color(0xFF8C8C8C);
  static const Color grey600 = Color(0xFF6B7280);
  static const Color grey700 = Color(0xFF4B4B4B);
  static const Color grey800 = Color(0xFF262626);
  static const Color grey900 = Color(0xFF111111);
  static const Color grey950 = Color(0xFF0A0A0A);

  // Background color depending on theme
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? grey950
        : Colors.white;
  }

  static Color foregroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? grey100 : grey900;
  }

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: grey100,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: Color(0xFF3B4E68), // 🔹 aici vreau culoarea #3B4E68
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: grey900,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: grey900,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: Color(0xFF253141), // 🔹 aici vreau culoarea #253141
      surface: Colors.black,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: grey100,
    ),
  );
}
