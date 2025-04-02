import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/widgets/post_items/post_item.dart';

class FeedPostsList extends ConsumerWidget {
  final String userId;

  const FeedPostsList({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider(userId));

    return postsAsync.when(
      data: (posts) {
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (posts.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) => PostItem(post: posts[index]),
          );
        } else {
          return _buildEmptyState();
        }
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error loading posts: $error')),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Center(
        child: Text(
          'Start following people and see their posts here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
