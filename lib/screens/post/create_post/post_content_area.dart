import 'package:flutter/material.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';
import 'package:zic_flutter/screens/post/create_post/post_media_content.dart';
import 'package:zic_flutter/screens/post/create_post/post_link_content.dart';
import 'package:zic_flutter/screens/post/create_post/post_poll_content.dart';

class PostContentArea extends StatelessWidget {
  final PostData postData; // Use PostData
  final VoidCallback resetPost;
  final VoidCallback validatePost;

  const PostContentArea({
    super.key,
    required this.postData, // Use PostData
    required this.resetPost,
    required this.validatePost,
  });

  @override
  Widget build(BuildContext context) {
    switch (postData.selectedOption) {
      case 'link':
        return Padding(
          padding: const EdgeInsets.only(left: 50.0),
          child: PostLinkContent(
            resetPost: resetPost,
            postData: postData,
            validatePost: validatePost,
          ),
        );
      case 'poll':
        return Padding(
          padding: const EdgeInsets.only(left: 50.0),
          child: PostPollContent(
            resetPost: resetPost,
            postData: postData,
            validatePost: validatePost,
          ),
        );
      case 'media':
        return PostMediaContent(
          resetPost: resetPost,
          postData: postData,
          validatePost: validatePost,
        );
      default:
        return SizedBox.shrink();
    }
  }
}
