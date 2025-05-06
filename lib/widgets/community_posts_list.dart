import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/providers/community_posts_provider.dart';

class CommunityPostsList extends ConsumerWidget {
  final String communityId;

  const CommunityPostsList({super.key, required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider(communityId));

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(
            child: Text('No posts in this community yet'),
          );
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return ListTile(
              title: Text(post.content),
              // Adaugă mai multe detalii despre postare după nevoie
            );
          },
        );
      },
    );
  }
}