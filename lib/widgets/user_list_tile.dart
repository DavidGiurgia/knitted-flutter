import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';

class UserListTile extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final Widget? actionWidget;

  const UserListTile({
    super.key,
    required this.user,
    required this.onTap,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    final String avatarUrl =
        user.avatarUrl.isNotEmpty
            ? user.avatarUrl
            : 'https://example.com/default-avatar.png';
    return ListTile(
      titleAlignment: ListTileTitleAlignment.center,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: AdvancedAvatar(
        size: 52,
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
      subtitle: Text(
        user.fullname,
        style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
      ),
      trailing: actionWidget,
      onTap: onTap,
    );
  }
}
