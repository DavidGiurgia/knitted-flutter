import 'package:zic_flutter/core/models/post.dart';

class MediaItem {
  final String url;
  final String publicId;

  MediaItem({required this.url, required this.publicId});

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(url: json['url'], publicId: json['publicId']);
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'publicId': publicId};
  }
}

class MediaPost extends Post {
  List<MediaItem> media;

  MediaPost({
    required super.id,
    super.isReply,
    super.replyTo,
    super.isFromCommunity,
    super.communityId,
    required super.userId,
    required super.content,
    required super.type,
    this.media = const [],
    super.anonymousPost,
    super.mentions,
    required super.createdAt,
    required super.updatedAt,
    super.expiresAt,
  });

  // Convertire din JSON
  factory MediaPost.fromJson(Map<String, dynamic> json) {
    final idValue = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    return MediaPost(
      id: idValue,
      userId: json['userId'],
      isReply: json['isReply'] ?? false,
      replyTo: json['replyTo'],
      isFromCommunity: json['isFromCommunity'] ?? false,
      communityId: json['communityId'],
      content: json['content'],
      type: postTypeMap[json['type']] ?? PostType.text,
      media:
          (json['media'] as List<dynamic>?)
              ?.map((item) => MediaItem.fromJson(item))
              .toList() ??
          [],
      anonymousPost: json['anonymousPost'] ?? false,
      mentions: List<String>.from(json['mentions'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  // Convertire în JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'media': media.map((item) => item.toJson()).toList(),
    };
  }
  
  @override
  Map<String, dynamic> toCreateJson() {
    return {
      ...super.toCreateJson(),
      'media': media.map((item) => item.toJson()).toList(),
    };
  }
}
