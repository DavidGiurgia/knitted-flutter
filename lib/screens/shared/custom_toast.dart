import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';

class CustomToast {
  static void show(
    BuildContext context,
    String message, {
    Color? color,
    Color? bgColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color ?? AppTheme.backgroundColor(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: bgColor ?? AppTheme.foregroundColor(context),
        duration: duration,
        behavior: SnackBarBehavior.floating, // Pentru a-l face floating
        margin: EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
