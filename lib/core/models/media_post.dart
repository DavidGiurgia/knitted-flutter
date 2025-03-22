import 'package:zic_flutter/core/models/post.dart';

class MediaPost extends Post {
  List<String> mediaUrls;

  MediaPost({
    required super.userId,
    required super.content,
    required super.type,
    this.mediaUrls = const [],
    super.anonymousPost,
    super.mentions,
    super.audience,
    super.expiresAt,
  });

  // Convertire din JSON
  factory MediaPost.fromJson(Map<String, dynamic> json) {
    return MediaPost(
      userId: json['userId'],
      content: json['content'],
      type: postTypeMap[json['type']] ?? PostType.text,
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
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
    return {...super.toJson(), 'mediaUrls': mediaUrls};
  }
}
