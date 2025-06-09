import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/providers/community_posts_provider.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/widgets/post_items/post_item.dart';

class FeedPostsList extends ConsumerWidget {
  final String userId;
  final String feedType;
  final bool communityBadge;

  const FeedPostsList({
    super.key,
    required this.userId,
    required this.feedType,
    this.communityBadge = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (feedType) {
      'latest' => _buildLatestFeed(ref),
      'friends' => _buildFriendsFeed(ref),
      _ => _buildCommunityFeed(ref, feedType),
    };
  }

  Widget _buildLatestFeed(WidgetRef ref) {
    final friendsPostsAsync = ref.watch(friendsPostsNotifier);
    final communityPostsAsync = ref.watch(joinedCommunitiesPostsProvider);

    return Consumer(
      builder: (context, ref, child) {
        // Așteptăm ambele surse de date
        return friendsPostsAsync.when(
          data: (friendsPosts) {
            return communityPostsAsync.when(
              data: (communityPosts) {
                // Combinăm postările și le sortăm cronologic
                final combinedPosts = [...friendsPosts, ...communityPosts];
                combinedPosts.sort(
                  (a, b) => b.createdAt.compareTo(a.createdAt),
                );

                if (combinedPosts.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: combinedPosts.length,
                    itemBuilder:
                        (context, index) => PostItem(
                          post: combinedPosts[index],
                          communityBadge:
                              true, // Arătăm badge-ul pentru toate postările în latest
                        ),
                  );
                } else {
                  return _buildEmptyState(feedType: 'latest');
                }
              },
              loading: () => _buildLoadingState(),
              error:
                  (error, _) => Center(
                    child: Text('Error loading community posts: $error'),
                  ),
            );
          },
          loading: () => _buildLoadingState(),
          error:
              (error, _) =>
                  Center(child: Text('Error loading user posts: $error')),
        );
      },
    );
  }

  Widget _buildFriendsFeed(WidgetRef ref) {
    final postsAsync = ref.watch(friendsPostsNotifier);

    return postsAsync.when(
      data: (posts) {
        if (posts.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder:
                (context, index) => PostItem(
                  post: posts[index],
                  communityBadge: false, // Nu arătăm badge-ul pentru prieteni
                ),
          );
        } else {
          return _buildEmptyState(feedType: 'friends');
        }
      },
      loading: () => _buildLoadingState(),
      error: (error, _) => Center(child: Text('Error loading posts: $error')),
    );
  }

  Widget _buildCommunityFeed(WidgetRef ref, String communityId) {
    final postsAsync = ref.watch(communityPostsProvider(communityId));

    return postsAsync.when(
      data: (posts) {
        if (posts.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder:
                (context, index) => PostItem(
                  post: posts[index],
                  communityBadge: false, // Arătăm badge-ul pentru comunitate
                ),
          );
        } else {
          return _buildEmptyState(feedType: 'community');
        }
      },
      loading: () => _buildLoadingState(),
      error:
          (error, _) =>
              Center(child: Text('Error loading community posts: $error')),
    );
  }

  Widget _buildEmptyState({required String feedType}) {
    final message = switch (feedType) {
      'latest' => 'No posts available. Start following people or communities!',
      'friends' => 'No posts from friends yet.',
      _ => 'No posts in this community yet. Be the first to post!',
    };

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.only(top: 12.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
