import 'package:flutter/material.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/widgets/post_items/post_media.dart';
import 'package:zic_flutter/widgets/post_items/post_poll.dart';
import 'post_link_preview.dart';

class PostTypeSpecificContent extends StatelessWidget {
  final Post post;

  const PostTypeSpecificContent({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    try {
      switch (post.type) {
        case PostType.link:
          return Padding(
            padding: const EdgeInsets.fromLTRB(64.0, 0, 12, 0),
            child: PostLinkPreview(post: post),
          );
        case PostType.poll:
          return Padding(
            padding: const EdgeInsets.fromLTRB(64.0, 0, 12, 0),
            child: PostPoll(post: post),
          );
        case PostType.media:
          return PostMedia(post: post);
        default:
          return const SizedBox.shrink();
      }
    } catch (e) {
      debugPrint("Error building post content: $e");
      return Text(
        "Error displaying post content",
        style: TextStyle(color: Colors.red),
      );
    }
  }
}
