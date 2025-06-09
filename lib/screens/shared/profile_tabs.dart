import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/widgets/post_items/post_item.dart';

class ProfileTabs extends ConsumerWidget {
  final String userId;
  final TabController tabController;

  const ProfileTabs({
    super.key,
    required this.userId,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      controller: tabController,
      children: [
        _PostsTabView(userId: userId, showMedia: false, showReplies: false),
        // Media Tab
        _PostsTabView(userId: userId, showMedia: true, showReplies: false),
        // Replies Tab
        _PostsTabView(userId: userId, showMedia: false, showReplies: true),
      ],
    );
  }
}

class _PostsTabView extends ConsumerWidget {
  final String userId;
  final bool showMedia;
  final bool showReplies;

  const _PostsTabView({
    required this.userId,
    required this.showMedia,
    required this.showReplies,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(creatorPostsProvider(userId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(friendsProvider(null));
        ref.invalidate(userProvider);
        ref.invalidate(creatorPostsProvider(userId));
      },
      child: posts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (posts) {
          posts = posts.where((post) => !post.isFromCommunity).toList();
          // Filter posts based on showMedia and showReplies flags
          final filteredPosts =
              posts.where((post) {
                if (showMedia) {
                  return post.type == PostType.media && !post.isReply;
                } else if (showReplies) {
                  return post.isReply;
                } else {
                  return !post
                      .isReply; // Show only original posts in "Posts" tab
                }
              }).toList();

          filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (filteredPosts.isEmpty) {
            String message = "No posts yet";
            if (showMedia) {
              message = "No media posts yet";
            } else if (showReplies) {
              message = "No replies yet.";
            }
            return ListView(children: [const SizedBox(height: 120,), Center(child: Text(message))]);
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: filteredPosts.length,
            itemBuilder:
                (context, index) => PostItem(
                  post: filteredPosts[index],
                  profileLink: false,
                  withParentLink: true,
                ),
          );
        },
      ),
    );
  }
}
