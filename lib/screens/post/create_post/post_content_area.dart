import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/screens/post/create_post/post_create_state.dart';
import 'package:zic_flutter/screens/post/create_post/post_media_content.dart';
import 'package:zic_flutter/screens/post/create_post/post_link_content.dart';
import 'package:zic_flutter/screens/post/create_post/post_poll_content.dart';

class PostContentArea extends ConsumerWidget {

  const PostContentArea({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
     // Observă starea notifier-ului pentru a obține selectedPostType
    final postCreationState = ref.watch(postCreationNotifierProvider);

    switch (postCreationState.selectedPostType) {
      case 'link':
        return Padding(
          padding: const EdgeInsets.only(left: 50.0),
          child: PostLinkContent(),
        );
      case 'poll':
        return Padding(
          padding: const EdgeInsets.only(left: 50.0),
          child: PostPollContent(),
        );
      case 'media':
        return PostMediaContent( );
      default:
        return SizedBox.shrink();
    }
  }
}
