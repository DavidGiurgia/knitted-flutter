import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post/post_content_area.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';

class PostInputArea extends ConsumerWidget {
  final PostData postData;
  final bool anonymousPost;
  final VoidCallback validatePost;
  final VoidCallback resetPost;
  final bool isReply;

  const PostInputArea({
    super.key,
    required this.postData,
    required this.anonymousPost,
    required this.validatePost,
    required this.resetPost,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref
            .read(userProvider)
            .valueOrNull; // Assuming you have a way to access current user
    if (user == null) {
      return const SizedBox.shrink(); // or handle the case when user is null
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: _buildUserAvatar(context, user),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anonymousPost ? "Anonymous" : user.fullname,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    TextField(
                      controller: postData.textController,
                      onChanged: (value) => validatePost(),
                      minLines: 1,
                      maxLines: null,
                      decoration:  InputDecoration(
                        hintText: isReply ? "Write your reply..." : "What's new?",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        isCollapsed: true, // This is the key property
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          PostContentArea(
            postData: postData, // Pass the PostData instance
            resetPost: resetPost,
            validatePost: validatePost,
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, User user) {
    if (anonymousPost) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color:
                AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey100,
          ),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.backgroundColor(context),
          child: Icon(
            TablerIcons.spy,
            size: 24,
            color: AppTheme.foregroundColor(context),
          ),
        ),
      );
    }

    return AdvancedAvatar(
      size: 40,
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
    );
  }
}
