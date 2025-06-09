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
    final String avatarUrl = user.avatarUrl.isNotEmpty ? user.avatarUrl : '';
    return ListTile(
      dense: true, // Reduce înălțimea implicită
      visualDensity: VisualDensity.compact, // Aduce elementele mai aproape
      titleAlignment: ListTileTitleAlignment.center,
      contentPadding: EdgeInsets.only( left: 16,  ),
      leading: AdvancedAvatar(
        size: 38,
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
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
