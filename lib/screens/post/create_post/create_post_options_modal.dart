import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';

class CreatePostModal extends StatelessWidget {
  final Function(String) updateSelectedOption;

  const CreatePostModal({super.key, required this.updateSelectedOption});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModalOption(context, HeroIcons.link, "Link", "link"),
          _buildModalOption(context, HeroIcons.chartBar, "Poll", "poll"),
          _buildModalOption(context, HeroIcons.photo, "Photo/Video", "media"),
        ],
      ),
    );
  }

  Widget _buildModalOption(BuildContext context, HeroIcons icon, String label, String option) {
    return InkWell(
      onTap: () {
        updateSelectedOption(option);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Row(
          children: [
            HeroIcon(
              icon,
              color: AppTheme.foregroundColor(context),
              size: 32,
              style: HeroIconStyle.micro,
            ),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}