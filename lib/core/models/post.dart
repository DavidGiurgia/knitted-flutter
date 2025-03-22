// Enum pentru tipurile de postări
import 'package:zic_flutter/core/models/link.dart';
import 'package:zic_flutter/core/models/media_post.dart';
import 'package:zic_flutter/core/models/poll.dart';

enum PostType { text, link, poll, media }

final postTypeMap = {
  'text': PostType.text,
  'link': PostType.link,
  'poll': PostType.poll,
  'media': PostType.media,
};

class Post {
  String userId;
  String content;
  PostType type;
  bool anonymousPost;
  List<String> mentions;
  List<String> audience;
  DateTime? expiresAt;

  Post({
    required this.userId,
    required this.content,
    required this.type,
    this.anonymousPost = false,
    this.mentions = const [],
    this.audience = const [],
    this.expiresAt,
  });

  // Convertire din JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
    case 'link':
      return LinkPost.fromJson(json);
    case 'poll':
      return PollPost.fromJson(json);
    case 'media':
      return MediaPost.fromJson(json);
    default:
      return Post(
        userId: json['userId'],
        content: json['content'],
        type: PostType.values.byName(json['type']),
        anonymousPost: json['anonymousPost'] ?? false,
        mentions: List<String>.from(json['mentions'] ?? []),
        audience: List<String>.from(json['audience'] ?? []),
        expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      );
  }
  }

  // Convertire în JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'content': content,
      'type': type.name.toLowerCase(),
      'anonymousPost': anonymousPost,
      'mentions': mentions,
      'audience': audience,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}
