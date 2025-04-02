import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
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
                          "Your friends",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  _buildAudienceOption(
                    title: 'Friends',
                    description: 'Your friends on Knitted.',
                    icon: TablerIcons.users,
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
                    icon: TablerIcons.user_minus,
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
                    icon: TablerIcons.user_plus,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: const Text(
                      "Your communities",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
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
    required IconData icon,
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
            Icon(icon, size: 30, ),
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
}
