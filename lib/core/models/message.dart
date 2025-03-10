class Message {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String content;
  final bool isAnonymous;
  final String type; // text, image, video, file, audio
  final String? mediaUrl;
  final String status; // sent, delivered, read, failed
  final Map<String, List<String>> reactions; // {"😂": ["user1", "user2"]}
  final String? replyTo;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.isAnonymous,
    required this.type,
    this.mediaUrl,
    required this.status,
    required this.reactions,
    this.replyTo,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'] ?? '', // Acceptă și id-ul MongoDB
      roomId: json['roomId'],
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'],
      content: json['content'] ?? '',
      isAnonymous: json['isAnonymous'] ?? false,
      type: json['type'] ?? 'text',
      mediaUrl: json['mediaUrl'],
      status: json['status'] ?? 'sent',
      reactions:
          (json['reactions'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ) ??
          {},
      replyTo: json['replyTo'],
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'isAnonymous': isAnonymous,
      'type': type,
      'mediaUrl': mediaUrl,
      'status': status,
      'reactions': reactions,
      'replyTo': replyTo,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Message{id: $id, roomId: $roomId, senderId: $senderId, senderName: $senderName, content: $content, type: $type, mediaUrl: $mediaUrl, status: $status, reactions: $reactions, replyTo: $replyTo, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
