import 'package:zic_flutter/core/models/post.dart';

class PollOption {
  String text;
  int votes;
  List<Voter> voters;

  PollOption({required this.text, this.votes = 0, this.voters = const []});

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      text: json['text'],
      votes: json['votes'] ?? 0,
      voters:
          (json['voters'] as List?)
              ?.map((voter) => Voter.fromJson(voter))
              .toList() ??
          [], // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'votes': votes,
      'voters': voters.map((voter) => voter.toJson()).toList(), // Add this line
    };
  }
}

class Voter {
  String userId;
  DateTime votedAt;

  Voter({required this.userId, required this.votedAt});

  factory Voter.fromJson(Map<String, dynamic> json) {
    return Voter(
      userId: json['userId'],
      votedAt: DateTime.parse(json['votedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'votedAt': votedAt.toIso8601String()};
  }
}

class PollPost extends Post {
  List<PollOption> options;

  PollPost({
    required super.id,
    required super.userId,
    super.isReply,
    super.replyTo,
    required super.content,
    required super.type,
    this.options = const [],
    super.anonymousPost,
    super.mentions,
    super.audience,
    required super.createdAt,
    required super.updatedAt,
    super.expiresAt,
  });

  factory PollPost.fromJson(Map<String, dynamic> json) {
    final idValue = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    return PollPost(
      id: idValue,
      userId: json['userId'],
      isReply: json['isReply'] ?? false,
      replyTo: json['replyTo'],
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
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
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
