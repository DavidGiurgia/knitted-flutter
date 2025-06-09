import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validators/validators.dart';
import 'package:zic_flutter/core/api/community_service.dart';
import 'package:zic_flutter/core/api/post_service.dart';
import 'package:zic_flutter/core/models/community.dart';
import 'package:zic_flutter/core/models/link.dart';
import 'package:zic_flutter/core/models/media_post.dart';
import 'package:zic_flutter/core/models/poll.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/core/services/cloudinaryService.dart';
import 'package:zic_flutter/screens/post/create_post/post_create_state.dart'; // Importă noua stare
import 'package:zic_flutter/screens/shared/custom_toast.dart';

class PostCreationNotifier extends StateNotifier<PostCreationState> {
  final Ref _ref;

  PostCreationNotifier(this._ref) : super(PostCreationState.initial());

  /// Cheamă asta la initState din widget!
  void initialize({
    Post? postToEdit,
    String initialAudience = "friends",
  }) async {
    // Resetează complet starea și dispune tot
    _disposeControllers();
    state = PostCreationState.initial();

    if (postToEdit != null) {
      // Setezi starea pentru editare
      await _setFromExistingPost(postToEdit, initialAudience);
    } else {
      // Setezi starea pentru creare nouă
      state = state.copyWith(
        selectedAudience: initialAudience,
        anonymousPost: false,
      );
      // Dacă nu e "friends", încarcă detaliile comunității
      if (initialAudience != "friends") {
        fetchCommunityDetails(initialAudience);
      }
    }
  }

  Future<void> _setFromExistingPost(Post post, String audience) async {
    // (creezi controllere noi, populate cu datele post-ului)
    final textController = TextEditingController(text: post.content);
    final focusNode = FocusNode();
    TextEditingController urlController = TextEditingController();
    List<TextEditingController> optionControllers = [];
    List<File> images = [];

    String postType = post.type.name;
    bool anonymous = post.anonymousPost;

    if (post is LinkPost) {
      urlController.text = post.url;
    } else if (post is PollPost) {
      optionControllers =
          post.options.map((o) => TextEditingController(text: o.text)).toList();
      while (optionControllers.length < 2) {
        optionControllers.add(TextEditingController());
      }
    }
    // Pentru media: aici ar trebui să preîncarci imaginile dacă îți trebuie.

    String audienceId =
        post.isFromCommunity && post.communityId != null
            ? post.communityId!
            : audience;

    state = state.copyWith(
      textController: textController,
      textFocusNode: focusNode,
      urlController: urlController,
      optionControllers:
          optionControllers.isEmpty
              ? [TextEditingController(), TextEditingController()]
              : optionControllers,
      images: images,
      selectedPostType: postType,
      selectedAudience: audienceId,
      anonymousPost: anonymous,
      isLoading: false,
      validationMessage: null,
      isValid: false,
    );
    if (post.isFromCommunity && post.communityId != null) {
      await fetchCommunityDetails(post.communityId!);
    }
  }

  void requestTextFocus() {
    // Asigură-te că widget-ul este încă montat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.textFocusNode.hasFocus) return;
      state.textFocusNode.requestFocus();
    });
  }

  void updateField(String fieldName, dynamic value) {
    switch (fieldName) {
      case 'text':
        state.textController.text = value as String;
        break;
      case 'url':
        state.urlController.text = value as String;
        break;
      case 'selectedPostType':
        updatePostType(value as String);
        return;
      case 'selectedAudience':
        state = state.copyWith(selectedAudience: value);
        break;
      case 'anonymousPost':
        state = state.copyWith(anonymousPost: value);
        break;
      case 'selectedCommunity':
        state = state.copyWith(selectedCommunity: value);
        break;
      case 'isLoading':
        state = state.copyWith(isLoading: value);
        break;
      case 'isValid':
        state = state.copyWith(isValid: value);
        break;
      case 'validationMessage':
        state = state.copyWith(validationMessage: value);
        break;
      default:
        debugPrint('Unknown field: $fieldName');
    }
    validatePost();
  }

  // In PostCreationNotifier
  void selectCommunityAudience(Community community) {
    state = state.copyWith(
      selectedAudience: community.id,
      selectedCommunity: community,
      anonymousPost: false,
    );
    validatePost();
  }

  void selectFriendsAudience() {
    state = state.copyWith(
      selectedAudience: 'friends',
      selectedCommunity: null,
      anonymousPost: false,
    );
    validatePost();
  }

  void updatePostType(String newType) {
    // Dispose controllers/clear lists for old content before switching type
    if (state.selectedPostType == 'poll') {
      for (var controller in state.optionControllers) {
        controller.dispose();
      }
    } else if (state.selectedPostType == 'link') {
      state.urlController.dispose(); // Dispose the old URL controller
    }
    // No explicit dispose needed for File objects, GC handles them when list cleared.

    // Reset contents based on the new type
    TextEditingController newUrlController =
        TextEditingController(); // Always create a new one, dispose if not used

    List<TextEditingController> newOptionControllers =
        []; // Always create empty, then fill if poll
    List<File> newImages = []; // Always create empty, then fill if media

    if (newType == 'poll') {
      newOptionControllers = [TextEditingController(), TextEditingController()];
    } else if (newType == 'media') {
      // If moving to media, you might keep existing images if you want to allow adding more
      //newImages = List.from(state.images);
    } else if (newType == 'link') {
      newUrlController = TextEditingController();
    }

    state = state.copyWith(
      selectedPostType: newType,
      urlController: newUrlController,
      optionControllers: newOptionControllers,
      images: newImages,
      // Keep textController as is, as it's common across types
      isValid: false, // Reset validity
      validationMessage: null, // Clear validation messages on type change
    );
    validatePost(); // Re-validate after type change
  }

  /// Adds a new poll option. Ensures immutability and adds a new controller.
  void addPollOption() {
    if (state.optionControllers.length >= 4) {
      return;
    }
    // Create a NEW list with existing controllers + the new one
    final newControllers = List<TextEditingController>.from(
      state.optionControllers,
    )..add(TextEditingController());
    state = state.copyWith(optionControllers: newControllers);
    validatePost();
  }

  /// Removes a poll option at the given index. Disposes the removed controller.
  void removePollOption(int index) {
    if (state.optionControllers.length <= 2) {
      return;
    }
    if (index >= 0 && index < state.optionControllers.length) {
      // Dispose the controller being removed to prevent memory leaks
      final removedController = state.optionControllers[index];
      removedController.dispose();

      // Create a NEW list by removing the item
      final newControllers = List<TextEditingController>.from(
        state.optionControllers,
      )..removeAt(index);
      state = state.copyWith(optionControllers: newControllers);
      validatePost();
    }
  }

  /// Adds new image files to the media post.
  void addImages(List<File> newFiles) {
    if (state.images.length + newFiles.length > 4) {
      return;
    }
    // Create a NEW list by adding new files to existing ones
    final updatedImages = List<File>.from(state.images)..addAll(newFiles);
    state = state.copyWith(images: updatedImages);
    validatePost();
  }

  /// Removes an image from the media post.
  void removeImage(int index) {
    if (index >= 0 && index < state.images.length) {
      // No explicit dispose needed for File objects.
      // Create a NEW list by removing the item
      final updatedImages = List<File>.from(state.images)..removeAt(index);
      state = state.copyWith(images: updatedImages);
      validatePost();
    }
  }

  Future<void> fetchCommunityDetails(String communityId) async {
    state = state.copyWith(isLoading: true, validationMessage: null);
    try {
      final community = await CommunityService.getCommunityById(communityId);
      state = state.copyWith(
        selectedCommunity: community,
        selectedAudience: communityId, // Set audience to community ID
        isLoading: false,
        validationMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        validationMessage: 'Failed to load community details.',
        isValid: false,
        isLoading: false,
      );
    }
  }

  void validatePost() {
    String? message;
    bool currentIsValid = true;

    if (state.selectedAudience == 'friends' && state.anonymousPost) {
      message = "You cannot post anonymously to your friends.";
      currentIsValid = false;
    } else {
      switch (state.selectedPostType) {
        case 'text':
          currentIsValid = state.textController.text.trim().isNotEmpty;
          message = currentIsValid ? null : "Post content is required.";
          break;
        case 'link':
          if (state.urlController.text.trim().isEmpty) {
            message = "URL is required.";
            currentIsValid = false;
          } else if (!isURL(state.urlController.text)) {
            message = "Please enter a valid URL.";
            currentIsValid = false;
          }
          break;
        case 'poll':
          if (state.textController.text.trim().isEmpty) {
            message = "Poll question is required.";
            currentIsValid = false;
          } else if (state.optionControllers.length < 2) {
            message = "At least two poll options are required.";
            currentIsValid = false;
          } else if (state.optionControllers.any(
            (controller) => controller.text.trim().isEmpty,
          )) {
            message = "All poll options must be filled.";
            currentIsValid = false;
          }
          break;
        case 'media':
          if (state.images.isEmpty) {
            message = "Please select at least one image.";
            currentIsValid = false;
          }
          break;
        default:
          message = null;
          currentIsValid = true;
      }
    }

    // Actualizează starea doar dacă isValid sau validationMessage s-au schimbat
    if (currentIsValid != state.isValid || message != state.validationMessage) {
      state = state.copyWith(
        isValid: currentIsValid,
        validationMessage: message,
      );
    }
  }

  void updateText(String newText) {
    final textController = state.textController;
    final previousSelection = textController.selection;

    textController.text = newText;

    // Păstrează poziția cursorului dacă este validă
    if (previousSelection.start <= newText.length) {
      textController.selection = previousSelection;
    } else {
      textController.selection = TextSelection.collapsed(
        offset: newText.length,
      );
    }

    validatePost();
  }

  Future<void> createPost({
    required BuildContext context,
    bool isReply = false,
    Post? replyTo,
  }) async {
    validatePost(); // Validează înainte de a încerca crearea
    if (!state.isValid) {
      CustomToast.show(
        context,
        state.validationMessage ?? 'Please fill in all required fields.',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      validationMessage: null,
    ); // Curăță mesajul de validare la începerea operației

    final user = _ref.read(userProvider).value;
    if (user == null) {
      CustomToast.show(context, 'Please login to create a post');
      state = state.copyWith(isLoading: false);
      return;
    }

    Post newPost;
    try {
      switch (state.selectedPostType) {
        case 'link':
          newPost = LinkPost(
            id: '',
            userId: user.id,
            isReply: isReply,
            replyTo: replyTo?.id,
            isFromCommunity: state.selectedAudience != "friends",
            communityId: state.selectedCommunity?.id,
            content: state.textController.text.trim(),
            type: PostType.link,
            url: state.urlController.text.trim(),
            anonymousPost: state.anonymousPost,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            mentions: [],
          );
          break;
        case 'poll':
          newPost = PollPost(
            id: '',
            userId: user.id,
            isReply: isReply,
            replyTo: replyTo?.id,
            isFromCommunity: state.selectedAudience != "friends",
            communityId: state.selectedCommunity?.id,
            content: state.textController.text.trim(),
            type: PostType.poll,
            options:
                state.optionControllers
                    .map(
                      (controller) =>
                          PollOption(text: controller.text.trim(), votes: 0),
                    )
                    .toList(),
            anonymousPost: state.anonymousPost,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            mentions: [],
          );
          break;
        case 'media':
          List<MediaItem> mediaItems = [];
          for (File file in state.images) {
            var response = await CloudinaryService.uploadFile(file);
            if (response != null) {
              mediaItems.add(
                MediaItem(
                  url: response['fileUrl'],
                  publicId: response['publicId'],
                ),
              );
            } else {
              state = state.copyWith(
                isLoading: false,
                validationMessage: 'Failed to upload media file.',
                isValid: false,
              );
              CustomToast.show(context, 'Failed to upload media file.');
              return;
            }
          }
          newPost = MediaPost(
            id: '',
            userId: user.id,
            isReply: isReply,
            replyTo: replyTo?.id,
            isFromCommunity: state.selectedAudience != "friends",
            communityId: state.selectedCommunity?.id,
            content: state.textController.text.trim(),
            type: PostType.media,
            media: mediaItems,
            anonymousPost: state.anonymousPost,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            mentions: [],
          );
          break;
        default: // Text post
          newPost = Post(
            id: '',
            userId: user.id,
            isReply: isReply,
            replyTo: replyTo?.id,
            isFromCommunity: state.selectedAudience != "friends",
            communityId: state.selectedCommunity?.id,
            content: state.textController.text.trim(),
            type: PostType.text,
            anonymousPost: state.anonymousPost,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            mentions: [],
          );
      }

      await PostService.createPost(newPost);
      _ref.invalidate(friendsPostsNotifier);
      if (isReply && replyTo != null) {
        _ref.invalidate(postRepliesProvider(replyTo.id!));
      }

      resetPostData();
    } catch (error) {
      print('Error creating post: $error');
      state = state.copyWith(
        isLoading: false,
        validationMessage: 'Error creating post: $error',
        isValid: false,
      );
      CustomToast.show(context, 'Error creating post: $error');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updatePost({
    required BuildContext context,
    required String postId,
  }) async {
    validatePost();
    if (!state.isValid) {
      CustomToast.show(
        context,
        state.validationMessage ?? 'Please fill in all required fields.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, validationMessage: null);
    final existingPost = await PostService.getPostById(
      postId,
    ); // Fetch existing post to preserve unchangeable fields

    Post updatedPost;
    try {
      switch (state.selectedPostType) {
        case 'link':
          updatedPost = LinkPost(
            id: postId,
            userId: existingPost.userId,
            isReply: existingPost.isReply,
            replyTo: existingPost.replyTo,
            isFromCommunity: state.selectedAudience != "friends",
            communityId: state.selectedCommunity?.id,
            content: state.textController.text.trim(),
            type: PostType.link,
            url: state.urlController.text.trim(),
            anonymousPost: state.anonymousPost,
            createdAt: existingPost.createdAt,
            updatedAt: DateTime.now(),
            mentions: existingPost.mentions,
          );
          break;
        case 'poll':
          updatedPost = PollPost(
            id: postId,
            userId: existingPost.userId,
            isReply: existingPost.isReply,
            replyTo: existingPost.replyTo,
            isFromCommunity: state.selectedAudience != "friends",
            communityId: state.selectedCommunity?.id,
            content: state.textController.text.trim(),
            type: PostType.poll,
            options:
                state.optionControllers
                    .map(
                      (controller) =>
                          PollOption(text: controller.text.trim(), votes: 0),
                    ) // Votes might need to be preserved if editing options
                    .toList(),
            anonymousPost: state.anonymousPost,
            createdAt: existingPost.createdAt,
            updatedAt: DateTime.now(),
            mentions: existingPost.mentions,
          );
          break;
        case 'media':
          List<MediaItem> mediaItems = [];
          // Aici este partea complexă: trebuie să gestionezi media existentă și media nouă.
          // O soluție simplificată ar fi să reîncarci toate imaginile.
          // O soluție robustă ar urmări ce imagini sunt noi vs. cele vechi.
          for (File file in state.images) {
            // Presupunem că File-urile sunt imagini noi care trebuie încărcate
            // Dacă ai URL-uri de la imagini existente, ar trebui să le adaugi direct în mediaItems
            var response = await CloudinaryService.uploadFile(file);
            if (response != null) {
              mediaItems.add(
                MediaItem(
                  url: response['fileUrl'],
                  publicId: response['publicId'],
                ),
              );
            } else {
              state = state.copyWith(
                isLoading: false,
                validationMessage: 'Failed to upload new media file.',
                isValid: false,
              );
              CustomToast.show(context, 'Failed to upload new media file.');
              return;
            }
          }
          // Dacă existingPost avea media, ar trebui să o adaugi aici, filtrând duplicările.
          // Pentru simplitate, aici doar înlocuim cu imaginile noi selectate.
          updatedPost = MediaPost(
            id: postId,
            userId: existingPost.userId,
            isReply: existingPost.isReply,
            replyTo: existingPost.replyTo,
            isFromCommunity: state.selectedAudience != "friends",
            communityId: state.selectedCommunity?.id,
            content: state.textController.text.trim(),
            type: PostType.media,
            media: mediaItems, // Aceasta va înlocui media existentă.
            anonymousPost: state.anonymousPost,
            createdAt: existingPost.createdAt,
            updatedAt: DateTime.now(),
            mentions: existingPost.mentions,
          );
          break;
        default: // Text post
          updatedPost = Post(
            id: postId,
            userId: existingPost.userId,
            isReply: existingPost.isReply,
            replyTo: existingPost.replyTo,
            isFromCommunity: state.selectedAudience != "friends",
            communityId: state.selectedCommunity?.id,
            content: state.textController.text.trim(),
            type: PostType.text,
            anonymousPost: state.anonymousPost,
            createdAt: existingPost.createdAt,
            updatedAt: DateTime.now(),
            mentions: existingPost.mentions,
          );
      }

      await PostService.updatePost(updatedPost.id!, updatedPost);
      _ref.invalidate(
        friendsPostsNotifier,
      ); // Invalidează lista de postări a prietenilor
      if (existingPost.isReply && existingPost.replyTo != null) {
        _ref.invalidate(
          postRepliesProvider(existingPost.replyTo!),
        ); // Invalidează răspunsurile
      }

      state = state.copyWith(
        isLoading: false,
        validationMessage: null,
        isValid: true,
      );
      // Navigarea înapoi se va face din UI
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        validationMessage: 'Error updating post: $error',
        isValid: false,
      );
      CustomToast.show(context, 'Error updating post: $error');
    }
  }

  void resetPostData() {
    // Dispune toate resursele existente
    state.dispose();

    // Creează o stare complet nouă
    state = PostCreationState(
      textController: TextEditingController(),
      textFocusNode: FocusNode(),
      urlController: TextEditingController(),
      optionControllers: [TextEditingController(), TextEditingController()],
      images: [],
      selectedPostType: 'text',
      selectedAudience: 'friends',
      anonymousPost: false,
      isLoading: false,
      validationMessage: null,
      isValid: false,
      selectedCommunity: null,
    );
  }

  /// Cheamă asta la dispose din widget!
  void disposeControllers() => _disposeControllers();

  void _disposeControllers() {
    state.textController.dispose();
    state.textFocusNode.dispose();
    state.urlController.dispose();
    for (var c in state.optionControllers) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
}
