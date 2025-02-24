import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:heroicons/heroicons.dart';

class JoinGroupInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onJoin;

  const JoinGroupInput({
    super.key,
    required this.controller,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15), // Shadow color with opacity
            spreadRadius: 1, // How far the shadow extends
            blurRadius: 8, // How blurry the shadow is
            offset: const Offset(0, 4), // Horizontal and vertical offset
          ),
        ],
      ),
      child: Row(
        children: [
          HeroIcon(
            HeroIcons.hashtag,
            size: 26,
            color:
                AppTheme.isDark(context)
                    ? AppTheme.grey300
                    : AppTheme.grey700, // Culoare personalizată
            style: HeroIconStyle.micro,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Enter code here",
                hintStyle: TextStyle(
                  fontSize: 24,
                  color:
                      AppTheme.isDark(context)
                          ? AppTheme.grey600
                          : AppTheme.grey400, //
                ),
                border: InputBorder.none, // Ascunde borderul default
              ),
              style: const TextStyle(
                fontSize: 24,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor, // Culoare personalizată
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Colțuri rotunjite
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            ),
            child: Text(
              "Join",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.backgroundColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
