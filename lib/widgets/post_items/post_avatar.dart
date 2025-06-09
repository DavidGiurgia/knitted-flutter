import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/screens/shared/user_profile_screen.dart';

class PostAvatar extends StatelessWidget {
  final Post? post;
  final User user;
  final bool readonly;

  const PostAvatar({
    super.key,
    this.post,
    required this.user,
    this.readonly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child:
          (post != null && post!.anonymousPost)
              ? _buildAnonymousAvatar(context)
              : _buildUserAvatar(context),
    );
  }

  Widget _buildAnonymousAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey100,
        ),
      ),
      child: CircleAvatar(
        radius: 19,
        backgroundColor: AppTheme.backgroundColor(context),
        child: Icon(
           TablerIcons.spy,
          color: AppTheme.foregroundColor(context),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent, // Elimină efectul de stropire
      highlightColor: Colors.transparent,
      onTap: () {
        if (readonly) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(user: user),
          ),
        );
      },
      child: AdvancedAvatar(
        size: 38,
        image: NetworkImage(user.avatarUrl),
        autoTextSize: true,
        name: user.fullname,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.isDark(context) ? AppTheme.grey200 : AppTheme.grey800,
        ),
        decoration: BoxDecoration(
          color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
