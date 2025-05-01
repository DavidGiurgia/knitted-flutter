import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
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
    final posts = ref.watch(creatorPostsProvider(userId));

    return TabBarView(
      controller: tabController,
      children: [
        // Posts Tab
        _PostsTabView(posts: posts, showMedia: false),
        // Media Tab
        _PostsTabView(posts: posts, showMedia: true),
        // Mentions Tab
         _PostsTabView(posts: posts, showMedia: true),
      ],
    );
  }
}

class _PostsTabView extends StatelessWidget {
  final AsyncValue<List<Post>> posts;
  final bool showMedia;

  const _PostsTabView({
    required this.posts,
    required this.showMedia,
  });

  @override
  Widget build(BuildContext context) {
    return posts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (posts) {
        // Filter posts based on showReplies and showMedia flags
        final filteredPosts = posts.where((post) {
          if (showMedia) {
            return post.type == PostType.media;
          } else {
            return !post.isReply; // show only posts, not replies
          }
        }).toList();

        filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (filteredPosts.isEmpty) {
          String message = "No posts yet";
          if (showMedia) {
            message = "No media posts yet";
          }
          return Center(child: Text(message));
        }

        return ListView.builder(
          itemCount: filteredPosts.length,
          itemBuilder: (context, index) => PostItem(post: filteredPosts[index]),
        );
      },
    );
  }
}
