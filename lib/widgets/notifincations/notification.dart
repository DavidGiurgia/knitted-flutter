import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/notifications.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/shared/user_profile_screen.dart';
import 'package:zic_flutter/utils/utils.dart';
import 'package:zic_flutter/widgets/button.dart';

enum NotificationType { friendRequest, friendRequestAccepted, groupInvitation }

class NotificationItem extends StatefulWidget {
  final Map<String, dynamic> notification;
  final Function(NotificationType type, String? senderId)? onAction;

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
  NotificationType? type;

  @override
  void initState() {
    super.initState();
    _fetchNotificationMetadata();
  }

  Future<void> _fetchNotificationMetadata() async {
    await NotificationService.markNotificationAsRead(
      widget.notification['_id'],
    );
    try {
      setState(() {
        type = _getNotificationType(widget.notification['type']);
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
    } catch (e) {
      print("Error fetching notification metadata: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  NotificationType _getNotificationType(String type) {
    switch (type) {
      case 'friend_request':
        return NotificationType.friendRequest;
      case 'friend_request_accepted':
        return NotificationType.friendRequestAccepted;
      case 'group_invitation':
        return NotificationType.groupInvitation;
      default:
        throw Exception('Unknown notification type');
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Delete Notification',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await NotificationService.deleteNotification(
                    widget.notification['_id'],
                  );
                  // Implement delete functionality
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final String timestamp = multiFormatDateString(
      widget.notification['createdAt'],
    );
    final bool isRead = widget.notification['read'] ?? false;
    final String avatarUrl = sender?.avatarUrl ?? '';
    final bool hasIncomingRequest = userProvider.user!.friendRequests.contains(
      sender?.id,
    );

    // Definirea mesajului și butonului de acțiune
    String message = "You have a new notification.";
    Widget? actionButton;

    switch (type) {
      case NotificationType.friendRequest:
        message = "${sender?.fullname} sent you a friend request.";
        actionButton =
            hasIncomingRequest
                ? CustomButton(
                  onPressed:
                      () async => await widget.onAction!(type!, sender?.id),
                  text: "Accept",
                  type: ButtonType.bordered,
                  size: ButtonSize.small,
                  bgColor: AppTheme.primaryColor,
                )
                : null;
        break;
      case NotificationType.friendRequestAccepted:
        message = "${sender?.fullname} accepted your friend request.";
        break;
      case NotificationType.groupInvitation:
        message =
            "You have been invited to join ${widget.notification['data']['groupName']}.";
        actionButton = CustomButton(
          onPressed: () => widget.onAction!(type!, null),
          text: "Join",
          type: ButtonType.solid,
          size: ButtonSize.small,
          bgColor: AppTheme.primaryColor,
        );
        break;
      default:
        message = "You have a new notification.";
        break;
    }

    return GestureDetector(
      onLongPress: () => _showBottomSheet(context),
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return sender != null
                    ? UserProfileScreen(user: sender!)
                    : Container();
              },
            ),
          ),
      child: Container(
        //margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              isRead
                  ? AppTheme.backgroundColor(context)
                  : Colors.yellow.shade400.withAlpha(20),
          //borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        color:
                            AppTheme.isDark(context)
                                ? AppTheme.grey800
                                : AppTheme.grey200,
                      ) // Skeleton loader
                      : Text(message, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if(actionButton!= null) actionButton, 
          ],
        ),
      ),
    );
  }
}
