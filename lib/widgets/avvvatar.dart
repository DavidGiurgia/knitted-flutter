import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/utils/avatar_colors.dart'; // Asigură-te că ai importat AppTheme

class CustomAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color textColor;
  final TextStyle? textStyle;
  final Color borderColor;
  final double borderWidth;
  final bool withRing;

  const CustomAvatar({
    Key? key,
    required this.name,
    this.size = 50.0,
    this.textColor = Colors.white,
    this.textStyle,
    this.borderColor = Colors.transparent,
    this.borderWidth = 2.0,
    this.withRing = false,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
     final Color backgroundColor = AvatarColors.getBackgroundColor(name);
    final Color textColor = AvatarColors.getTextColor(name);

    return AdvancedAvatar(
      size: size,
      name: name,
      autoTextSize: true,
      style:
          textStyle ??
          TextStyle(
            color: textColor,
            fontSize: size / 2.5,
            fontWeight: FontWeight.bold,
          ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border:
            withRing
                ? Border.all(color: AppTheme.primaryColor, width: borderWidth)
                : null,
      ),
    );
  }
}
