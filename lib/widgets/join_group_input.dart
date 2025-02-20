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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          HeroIcon(
            HeroIcons.hashtag,
            size: 24,
            color: AppTheme.isDark(context) ? Colors.white70 : Colors.black87, // Culoare personalizată
            style: HeroIconStyle.micro,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Enter code here",
                hintStyle: TextStyle(fontSize: 20, color: Color.fromARGB(255, 117, 117, 117)),
                border: InputBorder.none, // Ascunde borderul default
              ),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor, // Culoare personalizată
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Colțuri rotunjite
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "Join",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.backgroundColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}
