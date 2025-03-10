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

    Widget? actionButton;

    List<TextSpan> messageSpans = [];

    switch (widget.notification.type) {
      case NotificationType.friendRequest:
        messageSpans = [
          TextSpan(
            text: "${sender?.fullname} ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: "sent you a friend request.",
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
        ];
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
        messageSpans = [
          TextSpan(
            text: "${sender?.fullname} ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: "accepted your friend request.",
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
        ];
        break;
      case NotificationType.chatInvitation:
        messageSpans = [
          TextSpan(
            text: "${sender?.fullname} ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: "invited you to join a temporary chat:\n",
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: "# ${widget.notification.data['chatRoomTopic']}",
            style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.primaryColor.withValues(alpha: 0.8)),
          ),
          if (!isRoomStilActive)
            TextSpan(
              text: "   Expired",
              style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
            ),
        ];
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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              isRead
                  ? AppTheme.backgroundColor(context)
                  : Colors.yellow.shade400.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdvancedAvatar(
              size: 40,
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
                      : RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: AppTheme.foregroundColor(context),
                            fontSize: 16,
                          ), // Stilul implicit pentru RichText
                          children: messageSpans,
                        ),
                      ),
                  SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
