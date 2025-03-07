class Room {
  final String id;
  final String type;
  final String topic;
  final String? creatorId;

  final String? joinCode;
  final bool allowJoinCode;
  final String? participantsKey;

  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Room({
    required this.id,
    required this.type,
    required this.topic,
    this.creatorId,
    this.joinCode,
    required this.allowJoinCode,
    this.participantsKey,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'] ?? '',
      type: json['type'] ?? 'permanent',
      topic: json['topic'] ?? '',
      creatorId: json['creatorId'],
      joinCode: json['joinCode'],
      allowJoinCode: json['allowJoinCode'] ?? true,
      participantsKey: json['participantsKey'],
      expiresAt:
          json['expiresAt'] != null
              ? DateTime.tryParse(json['expiresAt'])
              : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'topic': topic,
      'creatorId': creatorId,
      'joinCode': joinCode,
      'allowJoinCode': allowJoinCode,
      'participantsKey': participantsKey,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
