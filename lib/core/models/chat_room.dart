import 'package:zic_flutter/core/models/message.dart';

class Room {
  final String id;
  final String type;
  final String topic;
  final String? creatorId;
  final String? joinCode;
  final bool allowJoinCode;
  final String? privateRoomKey;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  Message? lastMessage;
  DateTime? lastActivity;
  List<UnreadCount> unreadCounts; // Adăugat unreadCounts

  Room({
    required this.id,
    required this.type,
    required this.topic,
    this.creatorId,
    this.joinCode,
    required this.allowJoinCode,
    this.privateRoomKey,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.lastMessage,
    this.lastActivity,
    this.unreadCounts = const [], // Inițializare cu o listă goală
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? 'permanent',
      topic: json['topic'] ?? '',
      creatorId: json['creatorId'],
      joinCode: json['joinCode'],
      allowJoinCode: json['allowJoinCode'] ?? true,
      privateRoomKey: json['privateRoomKey'],
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt']) : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? false,
      lastMessage: json['lastMessage'] != null ? Message.fromJson(json['lastMessage']) : null,
      lastActivity: json['lastActivity'] != null ? DateTime.tryParse(json['lastActivity']) : null,
      unreadCounts: (json['unreadCounts'] as List<dynamic>?)
              ?.map((e) => UnreadCount.fromJson(e))
              .toList() ??
          [], // Parsare unreadCounts
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
      'privateRoomKey': privateRoomKey,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'lastMessage': lastMessage?.toJson(),
      'lastActivity': lastActivity?.toIso8601String(),
      'unreadCounts': unreadCounts.map((e) => e.toJson()).toList(), // Adăugat unreadCounts
    };
  }
}

class UnreadCount {
  final String userId;
  final int count;

  UnreadCount({
    required this.userId,
    required this.count,
  });

  factory UnreadCount.fromJson(Map<String, dynamic> json) {
    return UnreadCount(
      userId: json['userId'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'count': count,
    };
  }
}