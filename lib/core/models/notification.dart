enum NotificationType { friendRequest, friendRequestAccepted, chatInvitation }

class NotificationModel {
  final String id;
  final String senderId;
  final String receiverId;
  final NotificationType type;
  final Map<String, dynamic> data;
  final bool read;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.data,
    required this.read,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType notificationType;
    switch (json['type']) {
      case 'friend_request':
        notificationType = NotificationType.friendRequest;
        break;
      case 'friend_request_accepted':
        notificationType = NotificationType.friendRequestAccepted;
        break;
      case 'chat_invitation':
        notificationType = NotificationType.chatInvitation;
        break;
      default:
        notificationType = NotificationType.friendRequest; // Or handle unknown types differently
        break;
    }
    return NotificationModel(
      id: json['_id'] ?? '', // Assuming MongoDB _id
      senderId: json['senderId'] ?? 'zic_team',
      receiverId: json['receiverId'] ?? '',
      type: notificationType,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      read: json['read'] ?? false,
      archived: json['archived'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    String typeString;
    switch (type) {
      case NotificationType.friendRequest:
        typeString = 'friend_request';
        break;
      case NotificationType.friendRequestAccepted:
        typeString = 'friend_request_accepted';
        break;
      case NotificationType.chatInvitation:
        typeString = 'chat_invitation';
        break;
      }
    return {
      '_id': id, // Assuming MongoDB _id
      'senderId': senderId,
      'receiverId': receiverId,
      'type': typeString,
      'data': data,
      'read': read,
      'archived': archived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}