import 'package:flutter_riverpod/flutter_riverpod.dart';

final communityPostsProvider = FutureProvider.family<List<Post>, String>((ref, communityId) async {
  // Implementare API pentru a obține postările comunității
  // Exemplu: return ref.read(postServiceProvider).getCommunityPosts(communityId);
  return [];
});

class Post {
  final String id;
  final String content;
  final String communityId;

  Post({required this.id, required this.content, required this.communityId});
}