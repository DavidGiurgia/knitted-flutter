import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart'; // Folosit pentru HeroIcons
import 'package:zic_flutter/core/app_theme.dart';

enum ButtonType { solid, light, bordered }

enum ButtonSize { xs, small, medium, large }

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
  final bool isLoading;
  final HeroIconStyle? iconStyle;

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
    this.isLoading = false,
    this.iconStyle = HeroIconStyle.outline,
  });

  @override
  Widget build(BuildContext context) {
    //if loading
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

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
                ? HeroIcon(
                  heroIcon!,
                  size: _getFontSize(),
                  color: bgColor ?? AppTheme.foregroundColor(context),
                  style: iconStyle,
                )
                : Icon(
                  icon,
                  size: _getFontSize(),
                  color: bgColor ?? AppTheme.foregroundColor(context),
                ),
      );
    }

    // Dimensiuni buton
    double height = _getHeight();
    double fontSize = _getFontSize();

    // Culoare și stil
    final Color primaryColor = bgColor ?? AppTheme.foregroundColor(context);
    final Color textColor =
        type == ButtonType.solid
            ? AppTheme.backgroundColor(context)
            : primaryColor;
    final Color borderColor = primaryColor;
    final Color? backgroundColor =
        type == ButtonType.solid ? bgColor : Colors.transparent;

    // Construiește conținutul butonului
    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null || heroIcon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child:
                heroIcon != null
                    ? HeroIcon(
                      heroIcon!,
                      size: fontSize,
                      color: textColor,
                      style: HeroIconStyle.mini,
                    )
                    : Icon(icon, size: fontSize + 4, color: textColor),
          ),
        if (text != null)
          Flexible(
            child: Text(
              text!,
              style: TextStyle(fontSize: fontSize, color: textColor),
              overflow: TextOverflow.ellipsis, // Evită overflow-ul
            ),
          ),
      ],
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
            padding: EdgeInsets.symmetric(horizontal: size == ButtonSize.xs ? 6 : 16),
          ),
          child: buttonContent,
        );
        break;

      case ButtonType.bordered:
        button = OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: borderColor.withValues(alpha: 0.2), width: 1.5),
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: EdgeInsets.symmetric(horizontal: size == ButtonSize.xs ? 6 : 16),
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
            padding: EdgeInsets.symmetric(horizontal: size == ButtonSize.xs ? 6 : 16),
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
      case ButtonSize.xs:
        return 36;
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
      case ButtonSize.xs:
        return 14;
      case ButtonSize.small:
        return 16;
      case ButtonSize.large:
        return 24;
      case ButtonSize.medium:
        return 20;
    }
  }
}