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
  String? id;
  String userId;
  bool isReply;
  String? replyTo;
  String content;
  PostType type;
  bool anonymousPost;
  List<String> mentions;
  List<String> audience;
  final DateTime createdAt;
  final DateTime updatedAt;
  DateTime? expiresAt;

  Post({
    required this.id,
    required this.userId,
    this.isReply = false,
    this.replyTo,
    required this.content,
    required this.type,
    this.anonymousPost = false,
    this.mentions = const [],
    this.audience = const [],
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  // Convertire din JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    final idValue = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    switch (json['type']) {
      case 'link':
        return LinkPost.fromJson(json);
      case 'poll':
        return PollPost.fromJson(json);
      case 'media':
        return MediaPost.fromJson(json);
      default:
        return Post(
          id: idValue,
          userId: json['userId'],
          isReply: json['isReply'] ?? false,
          replyTo: json['replyTo'],
          content: json['content'],
          type: PostType.values.byName(json['type']),
          anonymousPost: json['anonymousPost'] ?? false,
          mentions: List<String>.from(json['mentions'] ?? []),
          audience: List<String>.from(json['audience'] ?? []),
          createdAt:
              DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
          updatedAt:
              DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
          expiresAt:
              json['expiresAt'] != null
                  ? DateTime.parse(json['expiresAt'])
                  : null,
        );
    }
  }

  // Convertire în JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'isReply': isReply,
      'replyTo': replyTo,
      'content': content,
      'type': type.name.toLowerCase(),
      'anonymousPost': anonymousPost,
      'mentions': mentions,
      'audience': audience,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Post{id: $id, userId: $userId, isReply: $isReply, replyTo: $replyTo, content: $content, type: $type, anonymousPost: $anonymousPost, mentions: $mentions, audience: $audience, createdAt: $createdAt, updatedAt: $updatedAt, expiresAt: $expiresAt}';
  }
}
