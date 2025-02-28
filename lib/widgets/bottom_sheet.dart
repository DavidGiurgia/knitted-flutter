import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/widgets/bottom_sheet_option.dart';

class SheetOption {
  final String title;
  final String subtitle;
  final HeroIcons icon;
  final Color iconColor;
  final VoidCallback onTap;

  SheetOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });
}

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final List<SheetOption> options;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.foregroundColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: AppTheme.isDark(context) ? AppTheme.grey700 : AppTheme.grey200,
          ),
          const SizedBox(height: 12),
          // Options
          ...options.map((option) => buildSheetOption(
                context,
                title: option.title,
                subtitle: option.subtitle,
                icon: option.icon,
                iconColor: option.iconColor,
                onTap: option.onTap,
              )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}