import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:zic_flutter/core/app_theme.dart'; // Asigură-te că ai importat AppTheme

class GroupAvatar extends StatelessWidget {
  final List<String> avatars;

  final List<String> names;

  const GroupAvatar({super.key, required this.avatars, required this.names});

  @override
  Widget build(BuildContext context) {
    const double size = 48;
    const double overlap = 30;
    final List<Widget> avatarWidgets = [];

    for (int i = 0; i < avatars.length && i < 3; i++) {
      final avatarUrl = avatars[i];
      final name = names[i];
      Widget avatar;

      avatar = AdvancedAvatar(
        size: size,
        name: name, // Nume implicit sau poți folosi altă logică
        image: NetworkImage(avatarUrl),
        autoTextSize: true,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.isDark(context) ? AppTheme.grey200 : AppTheme.grey800,
        ),
        decoration: BoxDecoration(
          color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200,
          shape: BoxShape.circle,
         
        ),
      );

      avatarWidgets.add(Positioned(left: i * overlap, child: avatar));
    }

    return SizedBox(
      width: (avatarWidgets.length - 1) * overlap + size,
      height: size,
      child: Stack(clipBehavior: Clip.none, children: avatarWidgets),
    );
  }
}
