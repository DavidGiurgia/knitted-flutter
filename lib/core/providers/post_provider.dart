import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/post_service.dart';
import 'package:zic_flutter/core/models/post.dart';

// Change from FamilyAsyncNotifier to AsyncNotifier
class FriendsPostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final posts = await PostService.getUserPosts();
    //filter isFromCommunity posts
    posts.removeWhere((post) => post.isFromCommunity);
    // Sort posts by createdAt in descending order
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  Future<void> refreshPosts() async {
    state = const AsyncLoading(); // Set to loading state
    state = await AsyncValue.guard(
      () => PostService.getUserPosts(),
    ); // Fetch and update
  }
}

final friendsPostsNotifier = AsyncNotifierProvider<FriendsPostsNotifier, List<Post>>(
  FriendsPostsNotifier.new,
);

class CreatorPostsNotifier extends FamilyAsyncNotifier<List<Post>, String> {
  @override
  Future<List<Post>> build(String userId) async {
    try {
      final posts = await PostService.getCreatorPosts(userId);
      return posts;
    } catch (e, stackTrace) {
      return Future.error(e, stackTrace);
    }
  }
}

final creatorPostsProvider =
    AsyncNotifierProviderFamily<CreatorPostsNotifier, List<Post>, String>(
      CreatorPostsNotifier.new,
    );

class PostRepliesNotifier extends FamilyAsyncNotifier<List<Post>, String> {
  @override
  Future<List<Post>> build(String postId) async {
    try {
      final replies = await PostService.getPostReplies(postId);
      return replies;
    } catch (e, stackTrace) {
      return Future.error(e, stackTrace);
    }
  }
}

final postRepliesProvider =
    AsyncNotifierProviderFamily<PostRepliesNotifier, List<Post>, String>(
      PostRepliesNotifier.new,
    );

final postByIdProvider = FutureProvider.family<Post?, String>((
  ref,
  postId,
) async {
  if (postId.isEmpty) {
    return null;
  }
  return await PostService.getPostById(postId);
});


//final userPosts = ref.watch(userPostsProvider(userId));

//final creatorPosts = ref.watch(creatorPostsProvider(creatorId));

//final replies = ref.watch(postRepliesProvider(postId));

//final postAsync = ref.watch(postByIdProvider(postId));