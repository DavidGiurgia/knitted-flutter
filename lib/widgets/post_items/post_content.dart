import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/shared/user_profile_screen.dart';
import 'package:zic_flutter/utils/utils.dart';
import 'package:zic_flutter/widgets/post_items/post_actions.dart';
import 'post_avatar.dart';
import 'post_type_specific_content.dart';

class PostContent extends ConsumerWidget {
  final Post post;
  final User user;
  final bool readonly;
  final bool isParentPost;

  const PostContent({
    super.key,
    required this.post,
    required this.user,
    this.readonly = false,
    this.isParentPost = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 2, 0),
              child: PostAvatar(
                post: post,
                user: user,
                readonly: readonly || isParentPost,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(context, ref),
                  
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child:
                        post.content.isNotEmpty
                            ? Text(
                              post.content,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.foregroundColor(context),
                              ),
                            )
                            : Text(
                              post.anonymousPost
                                  ? "From [group.name]"
                                  : "@${user.username}",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.grey500,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),

        PostTypeSpecificContent(post: post),
        const SizedBox(height: 8),
        if (!readonly)
          Padding(
            padding: const EdgeInsets.only(left: 64.0, right: 12),
            child: PostActions(post: post, isParentPost: isParentPost),
          ),
        const SizedBox(height: 8),
        Divider(
          height: 1,
          thickness: 1,
          color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200,
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Row(
            children: [
              if (!post.anonymousPost)
                InkWell(
                  enableFeedback: false,
                  onTap: () {
                    if (readonly) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(user: user),
                      ),
                    );
                  },
                  child: Text(
                    user.fullname,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              if (post.anonymousPost)
                Text(
                  "Anonymous",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),

              if (!readonly)
                Text(
                  " ${formatTimestampCompact(post.createdAt)}",
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
        const Spacer(),
        if (!readonly && !isParentPost)
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            onTap: () => _showPostOptions(context, ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Icon(
                Icons.more_horiz_rounded,
                size: 24,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }

  void _showPostOptions(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(userProvider).value;
    if (currentUser == null) return;

    final bool isCurentUserPost = post.userId == currentUser.id;
    showModalBottomSheet(
      backgroundColor:
          AppTheme.isDark(context) ? AppTheme.grey900 : Colors.white,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            if (isCurentUserPost && post.anonymousPost)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 0,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.visibility_rounded,
                    color: AppTheme.foregroundColor(context),
                    size: 26,
                  ),
                ),
                title: Text(
                  'Reveal identity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                subtitle: Text('Make your name visible on this post'),
                onTap: () {
                  Navigator.pop(context);
                  //_editPost();
                },
              ),
            if (isCurentUserPost)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 0,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: AppTheme.foregroundColor(context),
                    size: 26,
                  ),
                ),
                title: Text(
                  'Edit post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  //_editPost();
                },
              ),
            if (isCurentUserPost)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 0,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: AppTheme.foregroundColor(context),
                    size: 26,
                  ),
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  //_deletePost();
                },
              ),
            if (!isCurentUserPost)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 0,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppTheme.foregroundColor(context),
                    size: 26,
                  ),
                ),
                title: Text(
                  'Hide',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _hidePost();
                },
              ),
            if (!isCurentUserPost)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 0,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_remove_rounded,
                    color: AppTheme.foregroundColor(context),
                    size: 26,
                  ),
                ),
                title: const Text('Unfriend'),
                subtitle: Text(
                  'Remove ${post.anonymousPost ? "this user" : '@${user.username} from friends'}',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmUnfriend(context);
                },
              ),
            if (!isCurentUserPost)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 0,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.report_rounded,
                    color: Colors.red,
                    size: 26,
                  ),
                ),
                title: const Text(
                  'Report',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('This post is inappropriate'),
                onTap: () {
                  Navigator.pop(context);
                  _reportPost();
                },
              ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  // Add these helper methods to the PostContent class:
  void _hidePost() {
    // Implement hide post functionality
    debugPrint('Hiding post ${post.id}');
    // You might want to add this to a provider or call an API
  }

  void _reportPost() {
    // Implement report post functionality
    debugPrint('Reporting post ${post.id}');
    // You might want to add this to a provider or call an API
  }

  void _confirmUnfriend(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Unfriend User'),
            content: Text(
              'Are you sure you want to remove @${user.username} from your friends?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement unfriend functionality
                  debugPrint('Unfriending user ${user.id}');
                  // You might want to add this to a provider or call an API
                },
                child: const Text(
                  'Unfriend',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
