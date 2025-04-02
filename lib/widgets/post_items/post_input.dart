import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post/create_post.dart';
import 'package:zic_flutter/widgets/post_items/post_avatar.dart';

class PostInput extends ConsumerStatefulWidget {
  const PostInput({super.key});

  @override
  ConsumerState<PostInput> createState() => _PostInputState();
}

class _PostInputState extends ConsumerState<PostInput> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;
    if (user == null) {
      return SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostAvatar(post: null, user: user),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  splashColor:
                      Colors.transparent, // Elimină efectul de stropire
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(30.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePost(initialOption: "text"),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullname,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "What's new?",
                        style: TextStyle(
                          color:
                              AppTheme.isDark(context)
                                  ? AppTheme.grey700
                                  : AppTheme.grey300,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Row(
              children: [
                _buildActionButton(icon: TablerIcons.spy, tab: 'anonymous'),
                const SizedBox(width: 16),
                _buildActionButton(icon: TablerIcons.library_photo, tab: 'media'),
                const SizedBox(width: 14),
                _buildActionButton(icon: TablerIcons.camera, tab: 'media'),
                const SizedBox(width: 14),
                _buildActionButton(icon: TablerIcons.link, tab: 'link'),
                const SizedBox(width: 14),
                _buildActionButton(icon: TablerIcons.list_numbers, tab: 'poll'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String tab}) {
    return InkWell(
      splashColor: Colors.transparent, // Elimină efectul de stropire
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreatePost(initialOption: tab),
          ),
        );
      },
      child: Icon(
        icon,
        size: 28,
        color: AppTheme.isDark(context) ? AppTheme.grey700 : AppTheme.grey300,
      ),
    );
  }
}
