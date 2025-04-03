import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/post_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/link.dart';
import 'package:zic_flutter/core/models/media_post.dart';
import 'package:zic_flutter/core/models/poll.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/core/services/cloudinaryService.dart';
import 'package:zic_flutter/screens/post/audience_selector.dart';
import 'package:zic_flutter/screens/post/create_post/action_buttons.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';
import 'package:zic_flutter/screens/post/create_post/post_input_area.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:validators/validators.dart';
import 'package:zic_flutter/widgets/post_items/post_item.dart';
import 'package:zic_flutter/widgets/switch.dart';

class CreatePost extends ConsumerStatefulWidget {
  final String initialOption;
  final bool isReply; // New parameter
  final Post? replyTo;
  const CreatePost({
    super.key,
    this.initialOption = "text",
    this.isReply = false,
    this.replyTo,
  });

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  final PostData _postData = PostData();
  bool showFloatingButton = true;
  bool anonymousPost = false;
  bool isValid = false;
  String? validationMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialOption == "anonymous") {
      anonymousPost = true;
    } else if (widget.initialOption != "text") {
      showFloatingButton = false;

      _postData.selectedOption =
          widget.initialOption; // Set initial option from widget
    }
  }

  void updateSelectedOption(String option) {
    setState(() {
      _postData.selectedOption = option;
      showFloatingButton = false;
    });
    _validatePost();
  }

  void resetPost() {
    setState(() {
      _postData.reset();
      showFloatingButton = true;
      isValid = false;
    });
  }

  void _validatePost() {
    setState(() {
      isValid = _validatePostData(_postData);
    });
  }

  bool _validatePostData(PostData postData) {
    switch (postData.selectedOption) {
      case 'text':
        if (postData.textController.text.isEmpty) {
          validationMessage = "Post content is required.";
          return false;
        }
        break;
      case 'link':
        if (!isURL(postData.urlController.text)) {
          validationMessage = "Please enter a valid URL.";
          return false;
        }
        if (postData.urlController.text.isEmpty) {
          validationMessage = "URL is required.";
          return false;
        }
        break;
      case 'poll':
        if (postData.textController.text.isEmpty) {
          validationMessage = "Poll question is required.";
          return false;
        }
        if (postData.optionControllers.any(
          (controller) => controller.text.isEmpty,
        )) {
          validationMessage = "All poll options must be filled.";
          return false;
        }
        break;
      case 'media':
        if (postData.images.isEmpty) {
          validationMessage = "Please select at least one image.";
          return false;
        }
        break;
      default:
        validationMessage = null;
        return true;
    }
    validationMessage = null;
    return true;
  }

  Future<void> _createPost() async {
    _validatePost();
    if (!isValid) {
      CustomToast.show(
        context,
        validationMessage ?? 'Please fill in all required fields.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final user = ref.read(userProvider).value;
    if (user == null) {
      CustomToast.show(context, 'Please login to create a post');
      return;
    }
    PostService postService = PostService();
    Post newPost;

    if (_postData.selectedAudience == 'friends') {
      final userFriends = ref.read(friendsProvider(null)).value;
      if (userFriends == null) return;
      _postData.audienceList = userFriends.map((friend) => friend.id).toList();
    }

    // Crearea postării pe baza opțiunii selectate
    switch (_postData.selectedOption) {
      case 'link':
        newPost = LinkPost(
          id: '',
          userId: user.id,
          isReply: widget.isReply,
          replyTo: widget.replyTo?.id,
          content: _postData.textController.text,
          type: PostType.link,
          url: _postData.urlController.text,
          anonymousPost: anonymousPost,
          audience: _postData.audienceList,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          mentions: [],
        );
        break;
      case 'poll':
        newPost = PollPost(
          id: '',
          userId: user.id,
          isReply: widget.isReply,
          replyTo: widget.replyTo?.id,
          content: _postData.textController.text,
          type: PostType.poll,
          options:
              _postData.optionControllers
                  .map(
                    (controller) => PollOption(text: controller.text, votes: 0),
                  )
                  .toList(),
          anonymousPost: anonymousPost,
          audience: _postData.audienceList,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          mentions: [],
        );
        break;
      case 'media':
        List<MediaItem> mediaItems = [];
        for (File file in _postData.images) {
          var response = await CloudinaryService.uploadFile(file);
          if (response != null) {
            mediaItems.add(
              MediaItem(
                url: response['fileUrl'],
                publicId: response['publicId'],
              ),
            );
          } else {
            CustomToast.show(context, 'Failed to upload media file.');
            return;
          }
        }
        newPost = MediaPost(
          id: '',
          userId: user.id,
          isReply: widget.isReply,
          replyTo: widget.replyTo?.id,
          content: _postData.textController.text,
          type: PostType.media,
          media: mediaItems,
          anonymousPost: anonymousPost,
          audience: _postData.audienceList,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          mentions: [],
        );
        break;
      default:
        newPost = Post(
          id: '',
          userId: user.id,
          isReply: widget.isReply,
          replyTo: widget.replyTo?.id,
          content: _postData.textController.text,
          type: PostType.text,
          anonymousPost: anonymousPost,
          audience: _postData.audienceList,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          mentions: [],
        );
    }

    try {
      postService.createPost(newPost);
      resetPost();
      if (mounted) {
        ref.invalidate(userPostsProvider);
        if(widget.isReply){
          ref.invalidate(postRepliesProvider);
        }
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        CustomToast.show(context, 'Error creating post: $error');
      }
    } finally {
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final user = ref.read(userProvider).value;
    if (user == null) {
      return Center(child: Text("Please login to create a post"));
    }
    if (widget.isReply && widget.replyTo == null) {
      return Center(child: Text("Please select a post to reply to"));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReply ? "Reply" : "New post"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomButton(
              onPressed: _createPost,
              text: "Post",
              bgColor:
                  isValid
                      ? AppTheme.primaryColor
                      : AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey200,
              size: ButtonSize.small,
              isLoading: isLoading,
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
                  if (_postData.selectedAudience != 'friends' && !widget.isReply || widget.replyTo?.anonymousPost == true)
                    CustomSwitchTile(
                      title: "${widget.isReply ? "Reply" : "Post"} anonymously",
                      value: anonymousPost,
                      onChanged:
                          (value) => setState(() => anonymousPost = value),
                      radius: 0,
                    ),

                  if (widget.isReply && widget.replyTo != null)
                    PostItem(post: widget.replyTo!, readonly: true),

                  PostInputArea(
                    postData: _postData,
                    anonymousPost: anonymousPost,
                    validatePost: _validatePost,
                    isReply: widget.isReply,
                    resetPost: resetPost,
                  ),
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
                if (!widget.isReply)
                  AudienceSelector(postData: _postData, user: user),

                // Action buttons
                ActionButtons(
                  postData: _postData,
                  updateSelectedOption: updateSelectedOption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
