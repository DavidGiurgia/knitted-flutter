import 'package:zic_flutter/core/models/post.dart';

class LinkPost extends Post {
  String url;

  LinkPost({
    required super.id,
    required super.userId,
    super.isReply,
    super.replyTo,
    required super.content,
    required super.type,
    this.url = '',
    super.anonymousPost,
    super.mentions,
    super.audience,
    required super.createdAt,
    required super.updatedAt,
    super.expiresAt,
  });

  // Convertire din JSON
  factory LinkPost.fromJson(Map<String, dynamic> json) {
    return LinkPost(
      id: json['id'],
      userId: json['userId'],
      isReply: json['isReply'] ?? false,
          replyTo: json['replyTo'],
      content: json['content'],
      type: postTypeMap[json['type']] ?? PostType.text,
      url: json['url'],

      anonymousPost: json['anonymousPost'] ?? false,
      mentions: List<String>.from(json['mentions'] ?? []),
      audience: List<String>.from(json['audience'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  // Convertire în JSON
  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'url': url};
  }
}
