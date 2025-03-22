import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/screens/friends/friends_exception_list.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';
import 'package:zic_flutter/widgets/button.dart';

class PostSettings extends StatefulWidget {
  final PostData postData; // Primește instanța PostData
  final User user;
  const PostSettings({super.key, required this.postData, required this.user});

  @override
  State<PostSettings> createState() => _PostSettingsState();
}

class _PostSettingsState extends State<PostSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post settings")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Who can see your post?",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Your post will show up in Feed, on your profile and in search results.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Choose audience",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  _buildAudienceOption(
                    title: 'Friends',
                    description: 'Your friends on Knitted.',
                    icon: HeroIcons.users,
                    isSelected: widget.postData.selectedAudience == 'friends',
                    onTap: () {
                      setState(() {
                        widget.postData.selectedAudience = 'friends';
                      });
                    },
                  ),
                  _buildAudienceOption(
                    title: 'Friends except...',
                    description: "Don't show to some friends.",
                    icon: HeroIcons.userMinus,
                    isSelected:
                        widget.postData.selectedAudience == 'friends_except',
                    onTap: () async {
                      setState(() {
                        widget.postData.selectedAudience = 'friends_except';
                      });
                      final List<String>? selectedIds = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SelectFriendsList(
                                isExceptionList: true,
                                initialSelectedIds:
                                    widget.postData.audienceList,
                              ),
                        ),
                      );
                      if (selectedIds != null) {
                        setState(() {
                          widget.postData.audienceList =
                              selectedIds; // Actualizează lista cu datele primite
                        });
                      }
                    },

                    showArrow: true,
                  ),
                  _buildAudienceOption(
                    title: 'Specific friends',
                    description: 'Only show to some friends.',
                    icon: HeroIcons.userPlus,
                    isSelected:
                        widget.postData.selectedAudience == 'specific_friends',
                    onTap: () async {
                      setState(() {
                        widget.postData.selectedAudience = 'specific_friends';
                      });
                      final List<String>? selectedIds = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SelectFriendsList(
                                isExceptionList: false,
                                initialSelectedIds:
                                    widget.postData.audienceList,
                              ),
                        ),
                      );
                      if (selectedIds != null) {
                        setState(() {
                          widget.postData.audienceList =
                              selectedIds; // Actualizează lista cu datele primite
                        });
                      }
                    },
                    showArrow: true,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Comments on your post",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Any of selected audience wil be able to comment or reply on your post",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Comments control",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  _buildCommentControlOption(
                    title: 'Everyone',
                    description: 'Anyone can comment on this post.',
                    icon: HeroIcons.chatBubbleLeftRight,
                    isSelected: widget.postData.commentControl == 'everyone',
                    onTap: () {
                      setState(() {
                        widget.postData.commentControl = 'everyone';
                      });
                    },
                  ),
                  // const SizedBox(height: 8),
                  // _buildCommentControlOption(
                  //   title: 'Private replies only',
                  //   description:
                  //       'Allow private replies. Anonymous replies allowed if the post is anonymous.',
                  //   icon: HeroIcons.chatBubbleLeftEllipsis,
                  //   isSelected: widget.postData.commentControl == 'private',
                  //   onTap: () {
                  //     setState(() {
                  //       widget.postData.commentControl = 'private';
                  //     });
                  //   },
                  // ),
                  const SizedBox(height: 8),
                  _buildCommentControlOption(
                    title: 'No one',
                    description: 'Comments are disabled for this post.',
                    icon: HeroIcons.noSymbol,
                    isSelected: widget.postData.commentControl == 'no_one',
                    onTap: () {
                      setState(() {
                        widget.postData.commentControl = 'no_one';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: double.infinity,
              child: CustomButton(
                size: ButtonSize.small,
                bgColor: AppTheme.primaryColor,
                isFullWidth: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                text: 'Done',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceOption({
    required String title,
    required String description,
    required HeroIcons icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppTheme.primaryColor,
              ),
            if (!isSelected)
              const Icon(
                Icons.radio_button_unchecked_rounded,
                color: Colors.grey,
              ),
            const SizedBox(width: 16),
            HeroIcon(icon, size: 30, style: HeroIconStyle.micro),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(description, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (showArrow) const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentControlOption({
    required String title,
    required String description,
    required HeroIcons icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            HeroIcon(icon, size: 24, style: HeroIconStyle.mini),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(description, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (isSelected)
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppTheme.primaryColor,
              ),
            if (!isSelected)
              const Icon(
                Icons.radio_button_unchecked_rounded,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
