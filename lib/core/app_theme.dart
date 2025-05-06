import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor.withOpacity(0.8),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: grey900,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: grey950,
    appBarTheme: AppBarTheme(
      backgroundColor: grey950,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor.withOpacity(0.8),
      surface: Colors.black,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
    ),
  );
}

// Riverpod Provider for ThemeMode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  final String _prefKey = 'app_theme';

  Future<void> toggleTheme() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _saveTheme();
    _updateSystemChrome();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _saveTheme();
    _updateSystemChrome();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_prefKey);
    if (themeString != null) {
      state =
          themeString == 'dark'
              ? ThemeMode.dark
              : themeString == 'light'
              ? ThemeMode.light
              : ThemeMode.system;
    }
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = state.toString().split('.').last;
    await prefs.setString(_prefKey, themeString);
  }

  ThemeData getThemeData() {
    switch (state) {
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.light:
        return AppTheme.lightTheme;
      default:
        return ThemeData(); //return empty
    }
  }

  void _updateSystemChrome() {
    final isDark = state == ThemeMode.dark || 
        (state == ThemeMode.system && 
         WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
    
    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppTheme.grey950,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.white,
            ),
    );
  }
}
