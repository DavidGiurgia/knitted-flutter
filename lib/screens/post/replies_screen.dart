import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/screens/post/create_post/create_post.dart';
import 'package:zic_flutter/widgets/post_items/post_item.dart';

class RepliesScreen extends ConsumerWidget {
  final Post parentPost;
  const RepliesScreen({super.key, required this.parentPost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (parentPost.id == null) {
      return const Center(child: Text('Invalid post ID'));
    }
    final postsAsync = ref.watch(postRepliesProvider(parentPost.id!));

    return Scaffold(
      appBar: AppBar(title: Text("Replies"), actions: [],),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostItem(post: parentPost, isParentPost: true),
          const Padding(padding: EdgeInsets.all(12), child: Text("Replies", style: TextStyle(fontSize: 16),)),
          Expanded(
            child: postsAsync.when(
              data: (posts) {
                posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                if (posts.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: posts.length,
                    itemBuilder:
                        (context, index) => PostItem(post: posts[index]),
                  );
                } else {
                  return _buildEmptyState();
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, _) =>
                      Center(child: Text('Error loading replies: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePost(
                isReply: true,
                replyTo: parentPost,
              ),
            ),
          );
        },
        child: const Icon(TablerIcons.arrow_back_up),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 12.0),
      child: Center(
        child: Text(
          'No replies yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
