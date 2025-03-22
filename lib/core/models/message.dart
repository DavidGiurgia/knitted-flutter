class Message {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String content;
  final bool? isAnonymous;
  final String type;
  final String? mediaUrl;
  final Map<String, List<String>> reactions;
  final String? replyTo;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> readBy;

  Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.isAnonymous,
    required this.type,
    this.mediaUrl,
    required this.reactions,
    this.replyTo,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.readBy,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isAnonymous:
          json['isAnonymous'] == null ? false : json['isAnonymous'] as bool,
      type: json['type']?.toString() ?? 'text',
      mediaUrl: json['mediaUrl']?.toString(),
      readBy: (json['readBy'] is List) ? List<String>.from(json['readBy']) : [],
      reactions:
          (json['reactions'] is Map<String, dynamic>)
              ? (json['reactions'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, List<String>.from(value)),
              )
              : {},
      replyTo: json['replyTo']?.toString(),
      expiresAt:
          json['expiresAt'] != null
              ? DateTime.tryParse(json['expiresAt'].toString())
              : null,
      createdAt:
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now(),
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
      'readBy': readBy, 
      'reactions': reactions,
      'replyTo': replyTo,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Message{id: $id, roomId: $roomId, senderId: $senderId, senderName: $senderName, content: $content, type: $type, mediaUrl: $mediaUrl, readBy: $readBy, reactions: $reactions, replyTo: $replyTo, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
