import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/widgets/post_items/post_content.dart';

class PostItem extends ConsumerWidget {
  final Post post;
  final bool readonly;
  final bool isParentPost;

  const PostItem({super.key, required this.post, this.readonly = false,  this.isParentPost = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userFuture = ref.watch(_userProvider(post.userId));

    return userFuture.when(
      loading: () => _buildLoadingState(context),
      error: (error, stack) => Center(child: Text('Error loading user: $error')),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return Column(
          children: [
            PostContent(post: post, user: user, readonly: readonly, isParentPost: isParentPost),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final baseColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
    final highlightColor = isDark ? AppTheme.grey800 : AppTheme.grey100;
    final containerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 8.0, 8.0),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.white, radius: 20),
              ],
            ),
          ),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: containerColor,
            ),
          ),
        ],
      ),
    );
  }
}

final _userProvider = FutureProvider.family<User?, String>((ref, userId) async {
  try {
    return await UserService.fetchUserById(userId);
  } catch (e) {
    debugPrint("Error in _userProvider: $e");
    rethrow;
  }
});