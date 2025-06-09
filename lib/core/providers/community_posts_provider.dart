import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/community_service.dart';
import 'package:zic_flutter/core/api/post_service.dart';
import 'package:zic_flutter/core/models/community.dart';
import 'package:zic_flutter/core/models/post.dart';

class CommunityPostsNotifier extends FamilyAsyncNotifier<List<Post>, String> {
  @override
  Future<List<Post>> build(String communityId) async {
    try {
      final posts = await PostService.getCommunityPosts(communityId);
      // Sortăm postările după data creării, de la cele mai recente la cele mai vechi
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    } catch (e, stackTrace) {
      return Future.error(e, stackTrace);
    }
  }
}

final communityPostsProvider =
    AsyncNotifierProviderFamily<CommunityPostsNotifier, List<Post>, String>(
      CommunityPostsNotifier.new,
    );

/////////////////////////////////////////////

class JoinedCommunitiesPostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    try {
      // 1. Obținem lista de comunități în care userul este membru
      final communities = await ref.watch(joinedCommunitiesProvider.future);
      
      // 2. Extragem doar ID-urile comunităților
      final communityIds = communities.map((c) => c.id).toList();
      
      // 3. Preluăm postările din fiecare comunitate (paralel)
      final allPosts = await Future.wait(
        communityIds.map((id) => PostService.getCommunityPosts(id)),
      );
      
      // 4. Aplatizăm și sortăm
      return allPosts.expand((posts) => posts).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e, stackTrace) {
      return Future.error(e, stackTrace);
    }
  }
}

final joinedCommunitiesPostsProvider = AsyncNotifierProvider<JoinedCommunitiesPostsNotifier, List<Post>>(
  JoinedCommunitiesPostsNotifier.new,
);

class JoinedCommunitiesNotifier extends AsyncNotifier<List<Community>> {
  @override
  Future<List<Community>> build() async {
    try {
      return await CommunityService.getUserCommunities();
    } catch (e, stackTrace) {
      return Future.error(e, stackTrace);
    }
  }
}

final joinedCommunitiesProvider = AsyncNotifierProvider<JoinedCommunitiesNotifier, List<Community>>(
  JoinedCommunitiesNotifier.new,
);