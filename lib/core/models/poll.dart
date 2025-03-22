import 'package:zic_flutter/core/models/post.dart';

class PollOption {
  String text;
  int votes;

  PollOption({required this.text, this.votes = 0});

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(text: json['text'], votes: json['votes'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'votes': votes};
  }
}

class PollPost extends Post {
  List<PollOption> options;

  PollPost({
    required super.userId,
    required super.content,
    required super.type,
    this.options = const [],
    super.anonymousPost,
    super.mentions,
    super.audience,
    super.expiresAt,
  });

  factory PollPost.fromJson(Map<String, dynamic> json) {
    return PollPost(
      userId: json['userId'],
      content: json['content'],
      type: postTypeMap[json['type']] ?? PostType.text,
      options:
          (json['options'] as List?)
              ?.map((e) => PollOption.fromJson(e))
              .toList() ??
          [],
      anonymousPost: json['anonymousPost'] ?? false,
      mentions: List<String>.from(json['mentions'] ?? []),
      audience: List<String>.from(json['audience'] ?? []),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}
