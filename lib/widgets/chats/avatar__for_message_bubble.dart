import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:zic_flutter/core/app_theme.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String? fullName;
  final bool showAvatar;
  final bool shouldHaveSpace;


  const AvatarWidget({
    super.key,
    this.avatarUrl,
    this.fullName,
    required this.showAvatar,
    required this.shouldHaveSpace,
  });

  @override
  Widget build(BuildContext context) {
    if(shouldHaveSpace){
      return const SizedBox(width: 32);
    }
    if (!showAvatar) {
      return const SizedBox.shrink();
    }

    return AdvancedAvatar(
      size: 32,
      image: NetworkImage(avatarUrl!),
      autoTextSize: true,
      name: fullName!,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: AppTheme.isDark(context) ? AppTheme.grey200 : AppTheme.grey800,
      ),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200,
        shape: BoxShape.circle,
      ),
    );
  }
}
