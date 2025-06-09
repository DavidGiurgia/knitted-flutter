import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post/create_post.dart';
import 'package:zic_flutter/widgets/post_items/post_avatar.dart';

class PostInput extends ConsumerStatefulWidget {
  final String label;
  final String initialAudience;

  /// add a parameter for label

  const PostInput({super.key, this.label = "What's new?", this.initialAudience = 'friends'});

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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreatePost(initialAudience: widget.initialAudience),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey100,
            ),
          ),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: PostAvatar(post: null, user: user, readonly: false),
            ),
            const SizedBox(width: 10),
            Expanded(
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
                    widget.label,
                    style: TextStyle(
                      color: AppTheme.foregroundColor(
                        context,
                      ).withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildActionButton({required IconData icon, required String tab}) {
  //   return InkWell(
  //     splashColor: Colors.transparent, // Elimină efectul de stropire
  //     highlightColor: Colors.transparent,
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => CreatePost(initialOption: tab),
  //         ),
  //       );
  //     },
  //     child: Icon(icon, size: 28, color: AppTheme.foregroundColor(context).withValues(alpha: 0.6)),
  //   );
  // }
}
