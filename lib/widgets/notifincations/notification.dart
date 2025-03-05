import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/notifications.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/notification.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/shared/user_profile_screen.dart';
import 'package:zic_flutter/utils/utils.dart';
import 'package:zic_flutter/widgets/button.dart';

class NotificationItem extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback onAction;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onAction,
  });

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  bool isLoading = true;
  User? sender;
  bool isRoomStilActive = false;

  @override
  void initState() {
    super.initState();
    _fetchNotificationMetadata();
  }

  Future<void> _fetchNotificationMetadata() async {
    await NotificationService.markNotificationAsRead(widget.notification.id);
    try {
      final senderId = widget.notification.senderId;
      if (senderId != "zic_team") {
        final fetchedSender = await UserService.fetchUserById(senderId);
        final room = await RoomService.getRoomById(
          widget.notification.data['chatRoomId'] ?? "",
        );
        setState(() => isRoomStilActive = room != null);
        setState(() => sender = fetchedSender);
      } else {
        print("sender id is not an user");
      }
    } catch (e) {
      print("Error fetching notification metadata: $e");
    } finally {
      setState(() => isLoading = false);
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
                    widget.notification.id,
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
      widget.notification.createdAt,
    );
    final bool isRead = widget.notification.read;
    final String avatarUrl = sender?.avatarUrl ?? '';
    final bool hasIncomingRequest = userProvider.user!.friendRequests.contains(
      sender?.id,
    );

    // Definirea mesajului și butonului de acțiune
    String message = "You have a new notification.";
    Widget? actionButton;

    switch (widget.notification.type) {
      case NotificationType.friendRequest:
        message = "${sender?.fullname} sent you a friend request.";
        actionButton =
            hasIncomingRequest
                ? CustomButton(
                  onPressed: widget.onAction,
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
      case NotificationType.chatInvitation:
        message =
            "${sender?.fullname} has been invited you to join a temporary chat: ${widget.notification.data['chatRoomTopic']}.";
        if (isRoomStilActive) {
          actionButton = CustomButton(
            onPressed: widget.onAction,
            text: "Join",
            type: ButtonType.solid,
            size: ButtonSize.small,
            bgColor: AppTheme.primaryColor,
          );
        }
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
              size: 52,
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
            if (actionButton != null) actionButton,
          ],
        ),
      ),
    );
  }
}
