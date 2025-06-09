import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/audience_selector.dart';
import 'package:zic_flutter/screens/post/create_post/action_buttons.dart';
import 'package:zic_flutter/screens/post/create_post/post_create_state.dart';
import 'package:zic_flutter/screens/post/create_post/post_input_area.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/post_items/post_item.dart';
import 'package:zic_flutter/widgets/switch.dart';

class CreatePost extends ConsumerStatefulWidget {
  // Revertit la ConsumerStatefulWidget
  final String initialAudience;
  final bool isReply;
  final Post? replyTo;
  final Post? postToEdit;

  const CreatePost({
    super.key,
    this.initialAudience = "friends",
    this.isReply = false,
    this.postToEdit,
    this.replyTo,
  });

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inițializează o singură dată!
    if (!_initialized) {
      ref
          .read(postCreationNotifierProvider.notifier)
          .initialize(
            postToEdit: widget.postToEdit,
            initialAudience: widget.initialAudience,
          );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    // Cheamă disposeControllers pe notifier!
    ref.read(postCreationNotifierProvider.notifier).disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postCreationState = ref.watch(postCreationNotifierProvider);
    final notifier = ref.read(postCreationNotifierProvider.notifier);

    final user = ref.read(userProvider).value;

    // Handle loading state for initial community fetch
    if (postCreationState.isLoading &&
        postCreationState.selectedCommunity == null &&
        widget.initialAudience != 'friends') {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to create a post")),
      );
    }
    if (widget.isReply && widget.replyTo == null) {
      return const Scaffold(
        body: Center(child: Text("Please select a post to reply to")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isReply
              ? "Reply"
              : widget.postToEdit == null
              ? "New post"
              : "Edit post",
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomButton(
              onPressed:
                  postCreationState.isValid && !postCreationState.isLoading
                      ? () async {
                        if (widget.postToEdit != null) {
                          await notifier.updatePost(
                            context: context, // Pass context for toast
                            postId: widget.postToEdit!.id!, // !!!
                          );
                        } else {
                          await notifier.createPost(
                            context: context, // Pass context for toast
                            isReply: widget.isReply,
                            replyTo: widget.replyTo,
                          );
                        }
                        // Pop the screen only if the operation was successful
                        // and no validation message is present after the operation.
                        // The notifier's methods should handle setting isValid/validationMessage.
                        if (!postCreationState.isLoading &&
                            postCreationState.isValid) {
                          if (context.mounted) Navigator.pop(context);
                        }
                      }
                      : () {},
              text:
                  widget.isReply
                      ? "Reply"
                      : widget.postToEdit == null
                      ? "Post"
                      : "Update",
              bgColor:
                  postCreationState.isValid
                      ? AppTheme.foregroundColor(context)
                      : AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey200,
              size: ButtonSize.small,
              isLoading: postCreationState.isLoading,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: widget.isReply ? 50.0 : 100.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (postCreationState.selectedAudience != 'friends' ||
                      (widget.isReply && widget.replyTo?.anonymousPost == true))
                    CustomSwitchTile(
                      title: "${widget.isReply ? "Reply" : "Post"} anonymously",
                      value: postCreationState.anonymousPost,
                      onChanged: (value) {
                        notifier.updateField('anonymousPost', value);
                      },
                      radius: 0,
                    ),

                  if (widget.isReply && widget.replyTo != null)
                    PostItem(
                      post: widget.replyTo!,
                      actionButtons: false,
                      divider: false,
                    ),

                  PostInputArea(isReply: widget.isReply),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Audience button
                if (!widget.isReply && widget.postToEdit == null)
                  AudienceSelector(),

                // Action buttons
                ActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
