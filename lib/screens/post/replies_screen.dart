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

  Future<void> _refreshReplies(WidgetRef ref, String parentPostId) async {
    ref.invalidate(postRepliesProvider(parentPostId));
    await ref.read(postRepliesProvider(parentPostId).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (parentPost.id == null) {
      return Center(
        child: Text("Post not found.", style: TextStyle(color: Colors.grey)),
      );
    }
    final postsAsync = ref.watch(postRepliesProvider(parentPost.id!));

    return Scaffold(
      appBar: AppBar(title: Text("Replies"), actions: []),
      body: RefreshIndicator(
        onRefresh: () => _refreshReplies(ref, parentPost.id!),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostItem(post: parentPost, isParentPost: true),

                    postsAsync.when(
                      data: (posts) {
                        posts.sort(
                          (a, b) => b.createdAt.compareTo(a.createdAt),
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "${posts.length} replies",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            if (posts.isNotEmpty)
                              ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  ...posts.map((post) => PostItem(post: post)),
                                  const SizedBox(
                                    height: 80,
                                  ), // Invisible space at the end
                                ],
                              ),
                          ],
                        );
                      },
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, _) => Center(
                            child: Text('Error loading replies: $error'),
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CreatePost(isReply: true, replyTo: parentPost),
            ),
          );
        },
        child: const Icon(TablerIcons.arrow_back_up),
      ),
    );
  }
}
