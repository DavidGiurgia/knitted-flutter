import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onEditCover;
  final VoidCallback onEditAvatar;
  final User? user;

  const ProfileHeader({
    super.key,
    required this.onEditCover,
    required this.onEditAvatar,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Permite avatarului să depășească cover-ul
      alignment: Alignment.center,
      children: [
        // Cover Image
        Container(
          width: double.infinity,
          height: 160, // Înălțimea Cover Image
          decoration: BoxDecoration(
            color:
                AppTheme.isDark(context)
                    ? AppTheme.grey800
                    : AppTheme.grey200, // Placeholder
            image: DecorationImage(
              image: NetworkImage(user!.coverUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Buton de edit pentru cover
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: onEditCover,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),

        // Avatar (suprapus peste cover)
        Positioned(
          bottom: -30, // Suprapunere peste cover
          left: 40,
          child: GestureDetector(
            onTap: onEditAvatar,
            child: Container(
              padding: const EdgeInsets.all(4), // Bordura albă
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor(
                  context,
                ), // Bordura albă între avatar și cover
                shape: BoxShape.circle,
              ),
              child: AdvancedAvatar(
                size: 96, // Dimensiune avatar
                image: NetworkImage(user!.avatarUrl),

                autoTextSize: true,
                name: user?.fullname ?? "UK", // Inițiale fallback
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      AppTheme.isDark(context)
                          ? AppTheme.grey200
                          : AppTheme.grey800,
                ),
                decoration: BoxDecoration(
                  color:
                      AppTheme.isDark(context)
                          ? AppTheme.grey800
                          : AppTheme.grey200, // Background fallback
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
