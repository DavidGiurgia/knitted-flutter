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
  bool isFromCommunity;
  String? communityId;
  String content;
  PostType type;
  bool anonymousPost;
  List<String> mentions;
  final DateTime createdAt;
  final DateTime updatedAt;
  DateTime? expiresAt;

  Post({
    required this.id,
    required this.userId,
    this.isReply = false,
    this.replyTo,
    this.isFromCommunity = false,
    this.communityId,
    required this.content,
    required this.type,
    this.anonymousPost = false,
    this.mentions = const [],
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
          isFromCommunity: json['isFromCommunity'] ?? false,
          communityId: json['communityId'],
          content: json['content'],
          type: PostType.values.byName(json['type']),
          anonymousPost: json['anonymousPost'] ?? false,
          mentions: List<String>.from(json['mentions'] ?? []),
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

  Map<String, dynamic> toCreateJson() {
    return {
      'isReply': isReply,
      'replyTo': replyTo,
      'isFromCommunity': isFromCommunity,
      'communityId': communityId,
      'content': content,
      'type': type.name.toLowerCase(),
      'anonymousPost': anonymousPost,
      'mentions': mentions,
    };
  }

  // Convertire în JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'isReply': isReply,
      'replyTo': replyTo,
      'isFromCommunity': isFromCommunity,
      'communityId': communityId,
      'content': content,
      'type': type.name.toLowerCase(),
      'anonymousPost': anonymousPost,
      'mentions': mentions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  //copyWith
  Post copyWith({
    String? id,
    String? userId,
    bool? isReply,
    String? replyTo,
    bool? isFromCommunity,
    String? communityId,
    String? content,
    PostType? type,
    bool? anonymousPost,
    List<String>? mentions,
    List<String>? audience,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isReply: isReply ?? this.isReply,
      replyTo: replyTo ?? this.replyTo,
      isFromCommunity: isFromCommunity ?? this.isFromCommunity,
      communityId: communityId ?? this.communityId,
      content: content ?? this.content,
      type: type ?? this.type,
      anonymousPost: anonymousPost ?? this.anonymousPost,
      mentions: mentions ?? this.mentions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  //empty model
  static Post empty({anonymousPost = false}) {
    return Post(
      id: '',
      userId: '',
      isReply: false,
      replyTo: null,
      isFromCommunity: false,
      communityId: null,
      content: '',
      type: PostType.text,
      anonymousPost: anonymousPost,
      mentions: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Post{id: $id, userId: $userId, isReply: $isReply, replyTo: $replyTo, isFromCommunity: $isFromCommunity, communityId: $communityId content: $content, type: $type, anonymousPost: $anonymousPost, mentions: $mentions, createdAt: $createdAt, updatedAt: $updatedAt, expiresAt: $expiresAt}';
  }
}
