import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/screens/post/replies_screen.dart';
import 'package:zic_flutter/widgets/post_items/post_content.dart';

class PostItem extends ConsumerWidget {
  final Post post;
  final bool profileLink;
  final bool actionButtons;
  final bool isParentPost;
  final bool withParentLink;
  final bool communityBadge;
  final bool divider;

  const PostItem({
    super.key,
    required this.post,
    this.profileLink = true,
    this.actionButtons = true,
    this.isParentPost = false,
    this.withParentLink = false,
    this.communityBadge = false,
    this.divider = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userFuture = ref.watch(_userProvider(post.userId));
    final parentPostAsync =
        post.isReply && post.replyTo != null
            ? ref.watch(postByIdProvider(post.replyTo!))
            : null;

    return userFuture.when(
      loading: () => _buildLoadingState(context),
      error:
          (error, stack) => Center(child: Text('Error loading user: $error')),
      //data: (data) => _buildLoadingState(context),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (withParentLink && post.isReply && post.replyTo != null)
              parentPostAsync != null
                  ? parentPostAsync.when(
                    loading:
                        () => Padding(
                          padding: const EdgeInsets.only(top: 8, left: 30),
                          child: Row(
                            children: [
                              Icon(
                                TablerIcons.arrow_back_up,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Reply to...",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                    error:
                        (err, st) => Padding(
                          padding: const EdgeInsets.only(top: 8, left: 20),
                          child: Row(
                            children: [
                              Icon(
                                TablerIcons.arrow_up,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Reply to unavailable post",
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.clip,
                              ),
                            ],
                          ),
                        ),
                    data:
                        (parentPost) =>
                            parentPost == null
                                ? SizedBox.shrink()
                                : InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => RepliesScreen(
                                              parentPost: parentPost,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      left: 30,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          TablerIcons.arrow_back_up,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            overflow: TextOverflow.ellipsis,
                                            "Reply to ${parentPost.content.isEmpty ? "a ${parentPost.type.name} post" : parentPost.content}",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                  )
                  : SizedBox.shrink(),

            PostContent(
              post: post,
              user: user,
              profileLink: profileLink,
              actionButtons: actionButtons,
              isParentPost: isParentPost,
              communityBadge: communityBadge,
              divider: divider,
            ),
          ],
        );
      }, //
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final baseColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
    final highlightColor = isDark ? AppTheme.grey800 : AppTheme.grey100;
    final containerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar circle
            const CircleAvatar(backgroundColor: Colors.white, radius: 18),
            const SizedBox(width: 10),
            // Text placeholders (3 lines)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First line (wider - simulates username + timestamp)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Second line (medium width - simulates post text)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 18,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Third line (narrower - simulates shorter text line)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 18,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _userProvider = FutureProvider.family<User?, String>((ref, userId) async {
  try {
    return await UserService.fetchUserById(userId);
  } catch (e) {
    debugPrint("Error in _userProvider: $e");
    rethrow;
  }
});
