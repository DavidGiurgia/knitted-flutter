import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/post_service.dart';
import 'package:zic_flutter/core/models/post.dart';

class UserPostsNotifier extends FamilyAsyncNotifier<List<Post>, String> {
  @override
  Future<List<Post>> build(String userId) async {
    try {
      final posts = await PostService().getUserPosts(userId);
      return posts;
    } catch (e, stackTrace) {
      return Future.error(e, stackTrace);
    }
  }
}

final userPostsProvider = AsyncNotifierProviderFamily<UserPostsNotifier, List<Post>, String>(
  UserPostsNotifier.new,
);

class CreatorPostsNotifier extends FamilyAsyncNotifier<List<Post>, String> {
  @override
  Future<List<Post>> build(String userId) async {
    try {
      final posts = await PostService().getCreatorPosts(userId);
      return posts;
    } catch (e, stackTrace) {
      return Future.error(e, stackTrace);
    }
  }
}

final creatorPostsProvider = AsyncNotifierProviderFamily<CreatorPostsNotifier, List<Post>, String>(
  CreatorPostsNotifier.new,
);

class PostRepliesNotifier extends FamilyAsyncNotifier<List<Post>, String> {
  @override
  Future<List<Post>> build(String postId) async {
    try {
      final replies = await PostService().getPostReplies(postId);
      return replies;
    } catch (e, stackTrace) {
      return Future.error(e, stackTrace);
    }
  }
}

final postRepliesProvider = AsyncNotifierProviderFamily<PostRepliesNotifier, List<Post>, String>(
  PostRepliesNotifier.new,
);


//final userPosts = ref.watch(userPostsProvider(userId));

//final creatorPosts = ref.watch(creatorPostsProvider(creatorId));

//final replies = ref.watch(postRepliesProvider(postId));

