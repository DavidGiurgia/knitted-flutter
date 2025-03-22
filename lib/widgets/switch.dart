import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final double radius;
  final HeroIcon? icon;

  const CustomSwitchTile({
    super.key,
    required this.title,
    this.description,
    required this.value,
    required this.onChanged,
    this.activeColor = AppTheme.primaryColor,
    this.radius = 12,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            AppTheme.isDark(context)
                ? const Color.fromARGB(92, 33, 33, 33)
                : Colors.grey[50],
        // border: Border.all(
        //   color: Theme.of(context).brightness == Brightness.dark
        //       ? Colors.grey.shade800
        //       : Colors.grey.shade300,
        // ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              icon ?? const SizedBox.shrink(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: activeColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                description!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }
}
