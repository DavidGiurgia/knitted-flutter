import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/widgets/post_items/post_item.dart';

class FeedPostsList extends ConsumerWidget {
  final String userId;
  final bool Function(Post post)? filter;
  final int Function(Post a, Post b)? sort;

  const FeedPostsList({
    super.key, 
    required this.userId,
    this.filter,
    this.sort,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider(userId));

    return postsAsync.when(
      data: (posts) {
        // Apply filter if provided
        final filteredPosts = filter != null 
            ? posts.where(filter!).toList() 
            : posts;
        
        // Apply sort if provided, otherwise default to newest first
        filteredPosts.sort(sort ?? (a, b) => b.createdAt.compareTo(a.createdAt));

        if (filteredPosts.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) => PostItem(post: filteredPosts[index]),
          );
        } else {
          return _buildEmptyState(filter: filter);
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error loading posts: $error')),
    );
  }

  Widget _buildEmptyState({bool Function(Post post)? filter}) {
    String message;
    
    if (filter == null) {
      message = 'No posts available.';
    } else {
      // Customize empty state message based on filter type
      message = 'Nothing here yet.';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}