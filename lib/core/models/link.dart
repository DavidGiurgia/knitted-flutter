import 'package:zic_flutter/core/models/post.dart';

class LinkPost extends Post {
  String url;

  LinkPost({
    required super.userId,
    required super.content,
    required super.type,
    this.url = '',
    super.anonymousPost,
    super.mentions,
    super.audience,
    super.expiresAt,
  });

  // Convertire din JSON
  factory LinkPost.fromJson(Map<String, dynamic> json) {
    return LinkPost(
      userId: json['userId'],
      content: json['content'],
      type: postTypeMap[json['type']] ?? PostType.text,
      url: json['url'],

      anonymousPost: json['anonymousPost'] ?? false,
      mentions: List<String>.from(json['mentions'] ?? []),
      audience: List<String>.from(json['audience'] ?? []),
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
