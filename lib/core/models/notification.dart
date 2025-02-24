class NotificationModel {
  final String id;
  final String type;
  final String avatarUrl;
  final String message;
  final String timestamp;
  final List<String> actions;

  NotificationModel({
    required this.id,
    required this.type,
    required this.avatarUrl,
    required this.message,
    required this.timestamp,
    required this.actions,
  });
}