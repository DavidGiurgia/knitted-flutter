import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:zic_flutter/core/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String? coverUrl;
  final String? avatarUrl;
  final String? fullName;
  final VoidCallback onEditCover;
  final VoidCallback onEditAvatar;

  const ProfileHeader({
    super.key,
    this.coverUrl,
    this.avatarUrl,
    this.fullName,
    required this.onEditCover,
    required this.onEditAvatar,
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
            image:
                coverUrl != null
                    ? DecorationImage(
                      image: NetworkImage(coverUrl!),
                      fit: BoxFit.cover,
                    )
                    : null,
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
                color: AppTheme.backgroundColor(context),  // Bordura albă între avatar și cover
                shape: BoxShape.circle,
              ),
              child: AdvancedAvatar(
                size: 96, // Dimensiune avatar
                image: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                
                name: fullName, // Inițiale fallback
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
