import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';

class CustomBorderedInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final String? label;
  final double fontSize;
  final Color? fillColor;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool autoFocus;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final EdgeInsetsGeometry? contentPadding;
  final bool readOnly;
  final Function()? onTap;

  const CustomBorderedInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.label,
    this.fontSize = 16.0,
    this.fillColor,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autoFocus = false,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.contentPadding,
    this.readOnly = false,
    this.onTap,
  });

  @override
  _CustomBorderedInputState createState() => _CustomBorderedInputState();
}

class _CustomBorderedInputState extends State<CustomBorderedInput> {
  bool _obscureText = true;
  bool _hasError = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
    
      style: TextStyle(
        fontSize: widget.fontSize,
        color: theme.colorScheme.onSurface,
      ),
    
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          fontSize: widget.fontSize,
          color: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: widget.fontSize,
          color: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        prefixIcon:
            widget.prefixIcon != null
                ? Icon(
                  widget.prefixIcon,
                  color:
                      _hasError
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                )
                : null,
        suffixIcon: _buildSuffixIcon(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                _hasError
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline.withOpacity(0.2),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                _hasError ? theme.colorScheme.error : AppTheme.foregroundColor(context),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        filled: true,
        fillColor: widget.fillColor ?? theme.colorScheme.surface,
        contentPadding:
            widget.contentPadding ??
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        errorText: _errorText,
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
        errorMaxLines: 2,
      ),
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
        // Clear error when user types
        if (_hasError) {
          setState(() {
            _hasError = false;
            _errorText = null;
          });
        }
      },
      onFieldSubmitted: widget.onSubmitted,
      autofocus: widget.autoFocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      validator: (value) {
        if (widget.validator != null) {
          final error = widget.validator!(value);
          setState(() {
            _hasError = error != null;
            _errorText = error;
          });
          return error;
        }
        return null;
      },
    );
  }

  Widget? _buildSuffixIcon() {
    final theme = Theme.of(context);

    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color:
              _hasError
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color:
            _hasError
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface.withOpacity(0.6),
      );
    }

    return null;
  }
}
