import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/screens/shared/user_profile_screen.dart';
import 'package:zic_flutter/utils/utils.dart';
import 'package:zic_flutter/widgets/post_items/post_actions.dart';
import 'post_avatar.dart';
import 'post_type_specific_content.dart';

class PostContent extends ConsumerWidget {
  final Post post;
  final User user;
  final bool profileLink;
  final bool actionButtons;
  final bool isParentPost;

  const PostContent({
    super.key,
    required this.post,
    required this.user,
    this.profileLink = true,
    this.actionButtons = true,
    this.isParentPost = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 2, 0),
              child: PostAvatar(post: post, user: user, readonly: !profileLink),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(context, ref),

                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child:
                        post.content.isNotEmpty
                            ? Text(
                              post.content,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.foregroundColor(context),
                              ),
                            )
                            : Text(
                              "Your friend",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.grey500,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),

        PostTypeSpecificContent(post: post),
        const SizedBox(height: 2),
        if (actionButtons)
          Padding(
            padding: const EdgeInsets.only(left: 64.0, right: 12),
            child: PostActions(post: post, isParentPost: isParentPost),
          ),
        const SizedBox(height: 8),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Row(
            children: [
              if (!post.anonymousPost)
                InkWell(
                  enableFeedback: false,
                  onTap: () {
                    if (!profileLink) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(user: user),
                      ),
                    );
                  },
                  child: Text(
                    user.fullname,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              if (post.anonymousPost)
                Text(
                  "Anonymous",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),

              Text(
                " ${formatTimestampCompact(post.createdAt)}",
                style: TextStyle(
                  color:
                      AppTheme.isDark(context)
                          ? AppTheme.grey700
                          : AppTheme.grey300,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        
      ],
    );
  }
}
