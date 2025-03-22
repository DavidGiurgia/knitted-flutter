import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/api/post_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/link.dart';
import 'package:zic_flutter/core/models/media_post.dart';
import 'package:zic_flutter/core/models/poll.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post/create_post_options_modal.dart';
import 'package:zic_flutter/screens/post/create_post/post_content_area.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';
import 'package:zic_flutter/screens/post/create_post/post_settings.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:validators/validators.dart';
import 'package:zic_flutter/widgets/switch.dart';

class CreatePost extends ConsumerStatefulWidget {
  final String initialOption;
  const CreatePost({super.key, this.initialOption = "text"});

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  final PostData _postData = PostData();
  bool showFloatingButton = true;
  bool anonymousPost = false;
  bool isValid = false;

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
    if (postData.textController.text.isEmpty) {
      return false;
    }

    switch (postData.selectedOption) {
      case 'link':
        return isURL(postData.urlController.text) &&
            postData.urlController.text.isNotEmpty;
      case 'poll':
        return postData.optionControllers.every(
          (controller) => controller.text.isNotEmpty,
        );
      case 'media':
        return postData.images.isNotEmpty;
      default:
        return true; // Pentru 'text' sau alte opțiuni, doar textul este necesar
    }
  }

  void _createPost() {
    _validatePost();
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }
    final user = ref.read(userProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in.')));
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
          userId: user.id,
          content: _postData.textController.text,
          type: PostType.link,
          url: _postData.urlController.text,
          anonymousPost: anonymousPost,
          audience: _postData.audienceList,
          mentions: [],
        );
        break;
      case 'poll':
        newPost = PollPost(
          userId: user.id,
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
          mentions: [],
        );
        break;
      case 'media':
        newPost = MediaPost(
          userId: user.id,
          content: _postData.textController.text,
          type: PostType.media,
          mediaUrls: _postData.images.map((file) => file.path).toList(),
          anonymousPost: anonymousPost,
          audience: _postData.audienceList,
          mentions: [],
        );
        break;
      default:
        newPost = Post(
          userId: user.id,
          content: _postData.textController.text,
          type: PostType.text,
          anonymousPost: anonymousPost,
          audience: _postData.audienceList,
          mentions: [],
        );
    }

    // Trimiterea postării
    postService
        .createPost(newPost)
        .then((_) {
          resetPost();
          if (mounted) {
            Navigator.pop(context);
          }
        })
        .catchError((error) {
          if (mounted) {
            debugPrint('Error creating post: $error');
            CustomToast.show(context, 'Error creating post: $error');
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider).value;
    if (user == null) {
      return Center(child: Text("Please login to create a post"));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("New post"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomButton(
              onPressed: isValid ? _createPost : () {},
              text: "Post",
              bgColor:
                  isValid
                      ? AppTheme.primaryColor
                      : AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey200,
              size: ButtonSize.small,
              isLoading: false,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Allow join code
          CustomSwitchTile(
            title: "Post anonymously",
            value: anonymousPost,
            onChanged: (value) => setState(() => anonymousPost = value),
            radius: 0,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PostSettings(postData: _postData, user: user),
                ),
              );
              setState(() {}); // aici incerc sa actualizez
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Row(
                children: [
                  SizedBox(
                    width: 58, // Dimensiune uniformă
                    height: 58,
                    child:
                        anonymousPost
                            ? Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      AppTheme.isDark(context)
                                          ? AppTheme.grey800
                                          : AppTheme.grey100,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 29,
                                backgroundColor: AppTheme.backgroundColor(
                                  context,
                                ),
                                child: HeroIcon(
                                  HeroIcons.user,
                                  style: HeroIconStyle.micro,
                                  color: AppTheme.foregroundColor(context),
                                  size: 45,
                                ),
                              ),
                            )
                            : AdvancedAvatar(
                              size: 58,
                              image: NetworkImage(user.avatarUrl),
                              autoTextSize: true,
                              name: user.fullname,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.isDark(context)
                                        ? AppTheme.grey200
                                        : AppTheme.grey800,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.isDark(context)
                                        ? AppTheme.grey800
                                        : AppTheme.grey200,
                                shape: BoxShape.circle,
                              ),
                            ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anonymousPost ? "Anonymous" : user.fullname,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _postData.selectedAudience == "friends"
                            ? "To your friends"
                            : "To some of your friends",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PostContentArea(
              postData: _postData, // Pass the PostData instance
              resetPost: resetPost,
              validatePost: _validatePost,
            ),
          ),
        ],
      ),
      floatingActionButton:
          showFloatingButton
              ? FloatingActionButton(
                onPressed: () {
                  _showModal(context); // Deschide modalul
                },
                foregroundColor: AppTheme.foregroundColor(context),
                backgroundColor: AppTheme.backgroundColor(context),
                elevation: 0, // Elimină elevația implicită
                highlightElevation: 0, // Elimină elevația la apăsare
                child: const Icon(Icons.add_rounded, size: 32),
              )
              : null,
    );
  }

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CreatePostModal(updateSelectedOption: updateSelectedOption);
      },
    );
  }
}
