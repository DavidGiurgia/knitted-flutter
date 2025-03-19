
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post/create_post_options_modal.dart';
import 'package:zic_flutter/screens/post/create_post/post_content_area.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:validators/validators.dart';
import 'package:zic_flutter/widgets/switch.dart';



class CreatePost extends ConsumerStatefulWidget {
  const CreatePost({super.key});

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  final PostData _postData = PostData();
  bool showFloatingButton = true;
  bool postAnonymously = false;
  bool isValid = false;

  void updateSelectedOption(String option) {
    setState(() {
      _postData.selectedOption = option;
      showFloatingButton = false;
    });
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
      switch (_postData.selectedOption) {
        case 'link':
          isValid =
              isURL(_postData.urlController.text) &&
              _postData.textController.text.isNotEmpty;
          break;
        case 'poll':
          isValid =
              _postData.textController.text.isNotEmpty &&
              _postData.optionControllers.every(
                (controller) => controller.text.isNotEmpty,
              );
          break;
        case 'media':
          isValid =
              _postData.textController.text.isNotEmpty &&
              _postData.images.isNotEmpty;
          break;
        default:
          isValid = _postData.textController.text.isNotEmpty;
          break;
      }
    });
  }

  void _createPost() {
    _validatePost();
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    // Logic to create the post based on selectedOption
    if (_postData.selectedOption == "link") {
      print(
        "Link post created with text: ${_postData.textController.text} and url: ${_postData.urlController.text}",
      );
    } else {
      print("Post created with text: ${_postData.textController.text}");
    }

    resetPost();
    // Add your post creation logic here
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
              bgColor: isValid ? AppTheme.primaryColor : Colors.grey,
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
            value: postAnonymously,
            onChanged: (value) => setState(() => postAnonymously = value),
            radius: 0,
          ),
          InkWell(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Row(
                children: [
                  if (!postAnonymously)
                    AdvancedAvatar(
                      size: 58, // Dimensiune avatar
                      image: NetworkImage(user.avatarUrl),

                      autoTextSize: true,
                      name: user.fullname, // Inițiale fallback
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
                                : AppTheme.grey200, // Background fallback
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (postAnonymously)
                    Container(
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
                        backgroundColor: AppTheme.backgroundColor(context),
                        child: HeroIcon(
                          HeroIcons.user,
                          style: HeroIconStyle.micro,
                          color: AppTheme.foregroundColor(context),
                          size: 45,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postAnonymously ? "Anonymous" : user.fullname,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text("To everyone"),
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
              isValid: isValid,
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
