import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';

class CustomToast {
  static void show(
    BuildContext context,
    String message, {
    Color? color,
    Color? bgColor,
    double position = 0.15,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).size.height * position,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: (bgColor ?? AppTheme.foregroundColor(context)).withValues(alpha: 0.5), // Fundal subtil
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                message,
                style: TextStyle(
                  color: color ?? AppTheme.backgroundColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}