import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart'; // Folosit pentru HeroIcons
import 'package:zic_flutter/core/app_theme.dart';

enum ButtonType { solid, light, bordered }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final Color? bgColor;
  final bool isFullWidth;
  final bool isIconOnly;
  final IconData? icon;
  final HeroIcons? heroIcon;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.onPressed,
    this.text,
    this.type = ButtonType.solid,
    this.size = ButtonSize.medium,
    this.bgColor,
    this.isFullWidth = false,
    this.isIconOnly = false,
    this.icon,
    this.heroIcon,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    // Dacă este icon-only, returnează direct un IconButton
    if (isIconOnly) {
      return IconButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        icon:
            heroIcon != null
                ? HeroIcon(heroIcon!, size: _getFontSize())
                : Icon(icon, size: _getFontSize()),
      );
    }

    // Dimensiuni buton
    double height = _getHeight();
    double fontSize = _getFontSize();

    // Culoare și stil
    final Color primaryColor = bgColor ?? (AppTheme.isDark(context) ? AppTheme.grey200 : AppTheme.grey800);
    final Color textColor =
        type == ButtonType.solid ? Colors.white : primaryColor;
    final Color borderColor = primaryColor;
    final Color backgroundColor =
        type == ButtonType.solid ? primaryColor : Colors.transparent;

    // Construiește conținutul butonului
    Widget buttonContent = Text(
      text ?? "",
      style: TextStyle(fontSize: fontSize),
    );

    // Returnează butonul potrivit tipului
    Widget button;
    switch (type) {
      case ButtonType.solid:
        button = ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24),
          ),
          child: buttonContent,
        );
        break;

      case ButtonType.bordered:
        button = OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: borderColor, width: 1.5),
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24),
          ),
          child: buttonContent,
        );
        break;

      case ButtonType.light:
        button = TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonContent,
        );
        break;
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: button,
    );
  }

  // Metode pentru a obține dimensiunea în funcție de ButtonSize
  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.large:
        return 56;
      case ButtonSize.medium:
        return 48;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.large:
        return 24;
      case ButtonSize.medium:
        return 20;
    }
  }
}
