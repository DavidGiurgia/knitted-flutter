import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/community.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/community_provider.dart';
import 'package:zic_flutter/screens/post/replies_screen.dart';
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
  final bool communityBadge;
  final bool divider;


  const PostContent({
    super.key,
    required this.post,
    required this.user,
    this.profileLink = true,
    this.actionButtons = true,
    this.isParentPost = false,
    this.communityBadge = false,
    this.divider = true,

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
              padding: const EdgeInsets.fromLTRB(12, 14, 2, 0),
              child: PostAvatar(post: post, user: user, readonly: !profileLink),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(context, ref),

                  GestureDetector(
                    onTap: () {
                      if (isParentPost) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RepliesScreen(parentPost: post),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child:
                          post.content.isNotEmpty
                              ? Text(
                                post.content,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.foregroundColor(
                                    context,
                                  ).withValues(alpha: 0.9),
                                  // height:
                                  // 1.5, // Increase line height for better readability
                                  letterSpacing:
                                      0.2, // Slightly increased letter spacing
                                ),
                                textAlign:
                                    TextAlign
                                        .start, // Ensure text aligns cleanly
                                overflow: TextOverflow.clip,
                              )
                              : const SizedBox.shrink()
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
            padding: const EdgeInsets.only(left: 52.0, right: 12),
            child: PostActions(post: post, isParentPost: isParentPost),
          ),
        const SizedBox(height: 2),
        if(divider)
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, WidgetRef ref) {
    // Dacă post.isFromCommunity și communityId nu e null...
    if (communityBadge && post.isFromCommunity && post.communityId != null) {
      final communityAsync = ref.watch(
        communityByIdProvider(post.communityId!),
      );
      return communityAsync.when(
        data: (community) => _buildUserInfoRow(context, community: community),
        loading: () => _buildUserInfoRow(context),
        error: (e, st) => _buildUserInfoRow(context),
      );
    } else {
      return _buildUserInfoRow(context);
    }
  }

  Widget _buildUserInfoRow(BuildContext context, {Community? community}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, right: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!post.anonymousPost)
            Flexible(
              child: InkWell(
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
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          if (post.anonymousPost)
            Flexible(
              child: Text(
                "Anonymous",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
          if (community != null)
            Flexible(
              child: GestureDetector(
                onTap:
                    () => {
                      //go to community
                    },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 10),
                    Icon(
                      TablerIcons.users_group,
                      size: 18,
                      color: AppTheme.foregroundColor(
                        context,
                      ).withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        community.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: AppTheme.foregroundColor(
                            context,
                          ).withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Flexible(
            child: Text(
              "  ${formatTimestampCompact(post.createdAt)}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.foregroundColor(context).withValues(alpha: 0.5),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
