import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post/create_post.dart';
import 'package:zic_flutter/tabs/profile_screen.dart';

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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section
          Row(
            children: [
              // Avatar (Placeholder - Replace with actual Avatar logic)
              InkWell(
                enableFeedback: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
                child: AdvancedAvatar(
                  size: 46, // Dimensiune avatar
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
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(30.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePost(initialOption: "text"),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: const Text(
                      'Write something...',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionButton(
                  icon: HeroIcons.user,
                  label: 'Anonymous post',
                  tab: 'anonymous',
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: HeroIcons.photo,
                  label: 'Photo/Video',
                  tab: 'media',
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: HeroIcons.chartBar,
                  label: 'Poll',
                  tab: 'poll',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required HeroIcons icon,
    required String label,
    required String tab,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreatePost(initialOption: tab),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            HeroIcon(icon, size: 20, style: HeroIconStyle.micro),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
