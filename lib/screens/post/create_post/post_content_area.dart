import 'package:flutter/material.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';
import 'package:zic_flutter/screens/post/create_post/post_image_content.dart';
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
        return PostLinkContent(
          resetPost: resetPost,
          postData: postData,
          validatePost: validatePost,
        );
      case 'poll':
        return PostPollContent(
          resetPost: resetPost,
          postData: postData,
          validatePost: validatePost,
        );
      case 'media':
        return PostImageContent(
          resetPost: resetPost,
          postData: postData,
          validatePost: validatePost,
        );
      default:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: postData.textController,
            onChanged: (value) {
              validatePost(); // Adaugă această linie
            },
            decoration: const InputDecoration(
              hintText: "What's happening?",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 20),
            maxLines: null,
            expands: true,
          ),
        );
    }
  }
}
