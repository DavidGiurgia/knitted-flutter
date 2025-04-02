import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';
import 'package:zic_flutter/screens/post/create_post/post_settings.dart';

class AudienceSelector extends StatelessWidget {
  final PostData postData;
  final User user;

  const AudienceSelector({
    super.key,
    required this.postData,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostSettings(postData: postData, user: user),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor(context),
          border: Border(
            top: BorderSide(
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey200,
              width: 1,
            ),
            bottom: BorderSide(
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(TablerIcons.users),
            const SizedBox(width: 8),
            Text(
              postData.selectedAudience == "friends"
                  ? "To your friends"
                  : "To some of your friends",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
