import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/api/post_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post/create_post.dart';
import 'package:zic_flutter/screens/post/replies_screen.dart';

class PostActions extends ConsumerStatefulWidget {
  final Post post;
  final bool isParentPost;
  const PostActions({super.key, required this.post, this.isParentPost = false});

  @override
  ConsumerState<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends ConsumerState<PostActions> {
  bool isSaved = false;
  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider).value;
    if (user == null) return const SizedBox.shrink();

    final repliesCount = ref
        .watch(postRepliesProvider(widget.post.id!))
        .when(
          data: (replies) => replies.length,
          loading: () => 0, // Show 0 while loading, or a different placeholder.
          error:
              (error, stackTrace) =>
                  0, // Show 0 on error, or handle it as you prefer.
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              TablerIcons.arrow_back_up,
              color: AppTheme.foregroundColor(context).withValues(alpha: 0.8),
              size: 20,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        CreatePost(isReply: true, replyTo: widget.post),
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  TablerIcons.brand_line,
                  color: AppTheme.foregroundColor(
                    context,
                  ).withValues(alpha: 0.8),
                  size: 20,
                ),
                Text(
                  " $repliesCount",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.foregroundColor(
                      context,
                    ).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            if (widget.isParentPost) {
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RepliesScreen(parentPost: widget.post),
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              isSaved ? TablerIcons.bookmark_filled : TablerIcons.bookmark,
              color: AppTheme.foregroundColor(context).withValues(alpha: 0.8),
              size: 20,
            ),
          ),
          onTap: () {
            setState(() {
              isSaved = !isSaved;
            });
          },
        ),
        const SizedBox(width: 20),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              TablerIcons.dots,
              color: AppTheme.foregroundColor(context).withValues(alpha: 0.8),
              size: 20,
            ),
          ),
          onTap: () => _showPostOptions(context, ref),
        ),
      ],
    );
  }

  void _showPostOptions(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(userProvider).value;
    if (currentUser == null) return;

    final bool isCurentUserPost = widget.post.userId == currentUser.id;
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
            if (isCurentUserPost && widget.post.anonymousPost)
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
                  _revealIdentity();
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
                    TablerIcons.pencil,
                    color: AppTheme.foregroundColor(context),
                    size: 26,
                  ),
                ),
                title: Text(
                  'Edit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editPost();
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
                    TablerIcons.trash,
                    color: AppTheme.foregroundColor(context),
                    size: 26,
                  ),
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _deletePost();
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
                    TablerIcons.user_minus,
                    color: AppTheme.foregroundColor(context),
                    size: 26,
                  ),
                ),
                title: const Text('Unfriend'),

                onTap: () {
                  Navigator.pop(context);
                  // _unfriendUser();
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
                    TablerIcons.forbid,
                    color: Colors.red,
                    size: 26,
                  ),
                ),
                title: const Text('Block', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _reportPost();
                },
              ),
            const SizedBox(height: 8),
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
                    TablerIcons.alert_square_rounded,
                    color: Colors.red,
                    size: 26,
                  ),
                ),
                title: const Text(
                  'Report',
                  style: TextStyle(color: Colors.red),
                ),
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

  Future<void> _revealIdentity() async {
    await PostService.revealIdentity(widget.post.id!);
    ref.invalidate(creatorPostsProvider);
  }

  Future<void> _deletePost() async {
    debugPrint('deleting post ${widget.post.id}');
    await PostService.deletePost(widget.post.id!);
    ref.invalidate(creatorPostsProvider);
  }

  void _editPost() {
    // navigate to edit post screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePost(
          postToEdit: widget.post,
        ),
      ),
    );
  }

  void _reportPost() {
    // Implement report post functionality
    debugPrint('Reporting post ${widget.post.id}');
    // You might want to add this to a provider or call an API
  }
}
