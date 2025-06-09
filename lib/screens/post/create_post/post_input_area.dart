import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post/post_content_area.dart';
import 'package:zic_flutter/screens/post/create_post/post_create_state.dart';
import 'package:zic_flutter/widgets/post_items/post_avatar.dart';

class PostInputArea extends ConsumerWidget {
  final bool isReply;

  const PostInputArea({super.key, required this.isReply});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postCreationState = ref.watch(postCreationNotifierProvider);
    final notifier = ref.read(postCreationNotifierProvider.notifier);

    final user =
        ref
            .read(userProvider)
            .valueOrNull; // Assuming you have a way to access current user
    if (user == null) {
      return const SizedBox.shrink(); // or handle the case when user is null
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostAvatar(
                user: user,
                readonly: true,
                post: Post.empty(
                  anonymousPost: postCreationState.anonymousPost,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      postCreationState.anonymousPost
                          ? "Anonymous"
                          : user.fullname,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    TextField(
                      controller: postCreationState.textController,
                      focusNode:
                          postCreationState
                              .textFocusNode, // Conectează FocusNode
                      autofocus: true,
                      onChanged: (value) {
                        notifier.updateText(value);
                      },
                      minLines: 1,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText:
                            isReply ? "Write your reply..." : "What's new?",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        isCollapsed: true, // This is the key property
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          PostContentArea(),
        ],
      ),
    );
  }
}
