import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/utils/utils.dart';
import 'package:zic_flutter/widgets/button.dart';

class NotificationItem extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onAction;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onAction,
  });

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  Map<String, dynamic>? metadata;
  bool isLoading = true;
  User? sender;
  String? type;

  @override
  void initState() {
    super.initState();
    _fetchNotificationMetadata();
  }

  Future<void> _fetchNotificationMetadata() async {
    try {
      setState(() {
        type = widget.notification['type'];
      });

      final data = widget.notification['data'];

      final userId = data['senderId'] ?? data["acceptedBy"];
      if (userId != null && userId != "zic_team") {
        final user = await UserService.fetchUserById(userId);
        setState(() => sender = user);
        print("sender found: $sender");
      } else {
        print("sender id not valid");
      }
      // Se pot adăuga și alte tipuri de notificări aici...
    } catch (e) {
      print("Error fetching notification metadata: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String timestamp = multiFormatDateString(
      widget.notification['createdAt'],
    );
    final bool isRead = widget.notification['read'] ?? false;
    final String avatarUrl = sender?.avatarUrl ?? '';

    // Definirea mesajului și butonului de acțiune
    String message = "You have a new notification.";
    Widget? actionButton;

    switch (type) {
      case "friend_request":
        message = "${sender?.fullname} sent you a friend request.";
        actionButton = CustomButton(
          onPressed: () => widget.onAction,
          text: "Accept",
          type: ButtonType.light,
          size: ButtonSize.small,
          bgColor: AppTheme.primaryColor,
        );
        break;
      case "friend_request_accepted":
        message = "${sender?.fullname} accepted your friend request.";
        break;
      case "group_invitation":
        message =
            "You have been invited to join ${widget.notification['data']['groupName']}.";
        actionButton = CustomButton(
          onPressed: () => widget.onAction,
          text: "Join",
          type: ButtonType.light,
          size: ButtonSize.small,
          bgColor: AppTheme.primaryColor,
        );
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.yellow.shade400.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          AdvancedAvatar(
            size: 46,
            image: NetworkImage(avatarUrl),
            autoTextSize: true,
            name: sender?.fullname,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey200
                      : AppTheme.grey800,
            ),
            decoration: BoxDecoration(
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey200,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? Container(
                      height: 10,
                      width: 100,
                      color: Colors.grey.shade300,
                    ) // Skeleton loader
                    : Text(message, style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  timestamp,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (actionButton != null) actionButton,
        ],
      ),
    );
  }
}
