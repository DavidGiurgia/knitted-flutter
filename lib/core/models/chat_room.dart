class Room {
  final String id;
  final String type;
  final String topic;
  final String? creatorId;
  final String? joinCode;
  final bool allowJoinCode;
  final String? privateRoomKey; // Înlocuire participantsKey cu privateRoomKey
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive; // Adăugat isActive
  final String? lastMessage; // Adăugat lastMessage
  DateTime? lastActivity; // Adăugat lastActivity

  Room({
    required this.id,
    required this.type,
    required this.topic,
    this.creatorId,
    this.joinCode,
    required this.allowJoinCode,
    this.privateRoomKey, // Înlocuire participantsKey cu privateRoomKey
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive, // Adăugat isActive
    this.lastMessage, // Adăugat lastMessage
    this.lastActivity, // Adăugat lastActivity
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? 'permanent',
      topic: json['topic'] ?? '',
      creatorId: json['creatorId'],
      joinCode: json['joinCode'],
      allowJoinCode: json['allowJoinCode'] ?? true,
      privateRoomKey: json['privateRoomKey'], // Înlocuire participantsKey cu privateRoomKey
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt']) : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? false, // Adăugat isActive
      lastMessage: json['lastMessage'], // Adăugat lastMessage
      lastActivity: json['lastActivity'] != null ? DateTime.tryParse(json['lastActivity']) : null, // Adăugat lastActivity
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
      'privateRoomKey': privateRoomKey, // Înlocuire participantsKey cu privateRoomKey
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive, // Adăugat isActive
      'lastMessage': lastMessage, // Adăugat lastMessage
      'lastActivity': lastActivity?.toIso8601String(), // Adăugat lastActivity
    };
  }
}