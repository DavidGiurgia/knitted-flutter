import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post/create_post.dart';
import 'package:zic_flutter/screens/post/replies_screen.dart';

class PostActions extends ConsumerStatefulWidget {
  final Post post;
  final bool isParentPost;
  const PostActions({super.key, required this.post, this.isParentPost = false});

  @override
  ConsumerState<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends ConsumerState<PostActions> {
  bool isSaved = false;
  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider).value;
    if (user == null) return const SizedBox.shrink();

    final repliesCount = ref
        .watch(postRepliesProvider(widget.post.id!))
        .when(
          data: (replies) => replies.length,
          loading: () => 0, // Show 0 while loading, or a different placeholder.
          error:
              (error, stackTrace) =>
                  0, // Show 0 on error, or handle it as you prefer.
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: Row(
              children: [
                Icon(
                  TablerIcons.arrow_back_up,
                  color: AppTheme.foregroundColor(context),
                  size: 20,
                ),
                Text(" Reply"),
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        CreatePost(isReply: true, replyTo: widget.post),
              ),
            );
          },
        ),

        // if (widget.post.anonymousPost && widget.post.userId != user.id)
        //   InkWell(
        //     borderRadius: BorderRadius.all(Radius.circular(30)),
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(
        //         vertical: 8.0,
        //         horizontal: 12.0,
        //       ),
        //       child: Row(
        //         children: [
        //           Icon(
        //             TablerIcons.hash,
        //             color: AppTheme.foregroundColor(context),
        //             size: 20,
        //           ),
        //           const Text(" Chat"),
        //         ],
        //       ),
        //     ),
        //     onTap: () {
        //       // Navigare către secțiunea de comentarii
        //     },
        //   ),
        InkWell(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: Row(
              children: [
                Icon(
                  TablerIcons.brand_line,
                  color: AppTheme.foregroundColor(context),
                  size: 20,
                ),
                Text(" $repliesCount"),
              ],
            ),
          ),
          onTap: () {
            if (widget.isParentPost) {
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RepliesScreen(parentPost: widget.post),
              ),
            );
          },
        ),
        //const Spacer(),
        InkWell(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: Row(
              children: [
                Icon(
                  isSaved ? TablerIcons.bookmark_filled : TablerIcons.bookmark,
                  color: AppTheme.foregroundColor(context),
                  size: 20,
                ),
                //Text(isSaved ? " Saved":" Save"),
              ],
            ),
          ),
          onTap: () {
            setState(() {
              isSaved = !isSaved;
            });
          },
        ),
      ],
    );
  }
}
