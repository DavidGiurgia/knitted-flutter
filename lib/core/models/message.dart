class Message {
  final String roomId;
  final String senderId;
  final String senderName;
  final String content;
  final bool isAnonymous;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.isAnonymous,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      roomId: json['roomId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      isAnonymous: json['isAnonymous'] ?? false,
      expiresAt: DateTime.parse(json['expiresAt']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'isAnonymous': isAnonymous,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Message{roomId: $roomId, senderId: $senderId, senderName: $senderName, content: $content, isAnonymous: $isAnonymous, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
