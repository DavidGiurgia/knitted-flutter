import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';

class CustomBorderedInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final bool isPassword;
  final String? label;
  final double fontSize;
  final Color? fillColor;

  const CustomBorderedInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.isPassword = false,
    this.label,
    this.fontSize = 16.0,
    this.fillColor,
  });

  @override
  _CustomBorderedInputState createState() => _CustomBorderedInputState();
}

class _CustomBorderedInputState extends State<CustomBorderedInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      style: TextStyle(fontSize: widget.fontSize),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: widget.fontSize,
          color: Colors.grey.shade500,
        ),
        labelStyle: TextStyle(
          fontSize: widget.fontSize,
          color: Colors.grey.shade500,
        ),

        //floatingLabelBehavior: FloatingLabelBehavior.,
        prefixIcon:
            widget.icon != null
                ? Icon(widget.icon, color: Colors.grey.shade600)
                : null,
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: widget.fillColor ?? Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 24,
        ),
      ),
    );
  }
}
