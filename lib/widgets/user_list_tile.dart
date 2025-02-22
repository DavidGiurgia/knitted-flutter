import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/widgets/button.dart';

class UserListTile extends StatelessWidget {
  final User user;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final bool showRemoveButton;

  const UserListTile({
    super.key,
    required this.user,
    required this.onRemove,
    required this.onTap,
    this.showRemoveButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final String avatarUrl = user.avatarUrl;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: AdvancedAvatar(
        size: 46,
        image: NetworkImage(avatarUrl),
        autoTextSize: true,
        name: user.fullname,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.isDark(context) ? AppTheme.grey200 : AppTheme.grey800,
        ),
        decoration: BoxDecoration(
          color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        user.username,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(user.fullname, style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
      trailing: showRemoveButton
          ? CustomButton(
              heroIcon: HeroIcons.xMark,
              onPressed: onRemove,
              isIconOnly: true,
              size: ButtonSize.small,
            )
          : null,
      onTap: onTap,
    );
  }
}