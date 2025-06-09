import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class NotificationItem extends ConsumerStatefulWidget {
  final NotificationModel notification;
  final VoidCallback onAction;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onAction,
  });

  @override
  ConsumerState<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends ConsumerState<NotificationItem> {
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
      if (senderId != "troop_team") {
        final fetchedSender = await UserService.fetchUserById(senderId);
        final room = await RoomService.getRoomById(
          widget.notification.data['chatRoomId'] ?? "",
        );
        setState(() => isRoomStilActive = room != null);
        setState(() => sender = fetchedSender);
      } else {
        debugPrint("sender id is not an user");
      }
    } catch (e) {
      debugPrint("Error fetching notification metadata: $e");
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

  String _getNotificationTitle() {
    if (isLoading || sender == null) return "Loading...";

    switch (widget.notification.type) {
      case NotificationType.friendRequest:
        return sender!.fullname;
      case NotificationType.friendRequestAccepted:
        return sender!.fullname;
      case NotificationType.chatInvitation:
        return sender!.fullname;
      case NotificationType.reply:
        return sender!.fullname;
      case NotificationType.mention:
        return sender!.fullname;
    }
  }

  String _getNotificationSubtitle() {
    if (isLoading) return "Loading...";

    switch (widget.notification.type) {
      case NotificationType.friendRequest:
        return "Friend request";
      case NotificationType.friendRequestAccepted:
        return "You are now friends";
      case NotificationType.chatInvitation:
        return isRoomStilActive
            ? "Invited you to join a chat"
            : "Chat invitation expired";
      case NotificationType.reply:
        return "Replied to your message";
      case NotificationType.mention:
        return "Mentioned you";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;

    if (user == null) {
      return SizedBox.shrink();
    }
    final String timestamp = formatTimestampCompact(
      widget.notification.createdAt,
    );
    final bool isRead = widget.notification.read;
    final String avatarUrl = sender?.avatarUrl ?? '';
    final bool hasIncomingRequest = user.friendRequests.contains(sender?.id);

    Widget? actionButton;

    switch (widget.notification.type) {
      case NotificationType.friendRequest:
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
        null;
        break;
      case NotificationType.chatInvitation:
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
      default:
        actionButton = null;
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
        //margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              isRead
                  ? AppTheme.backgroundColor(context)
                  : Colors.yellow.shade400.withAlpha(20),
          //borderRadius: BorderRadius.circular(12),
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
                color: AppTheme.foregroundColor(context).withValues(alpha: 0.2),
              ),
              decoration: BoxDecoration(
                color: AppTheme.foregroundColor(context).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading) ...[
                    Container(
                      width: 100, // Made narrower
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.foregroundColor(
                          context,
                        ).withValues(alpha: 0.2), // Used withOpacity for alpha
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Made more rounded
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 140, // Made narrower
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.foregroundColor(
                          context,
                        ).withValues(alpha: 0.2), // Used withOpacity for alpha
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Made more rounded
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Text(
                          _getNotificationTitle(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppTheme.foregroundColor(context),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timestamp,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                AppTheme.isDark(context)
                                    ? Colors.grey[700]
                                    : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    //const SizedBox(height: 4),
                    Text(
                      _getNotificationSubtitle(),
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            AppTheme.isDark(context)
                                ? Colors.grey[700]
                                : Colors.grey[400],
                      ),
                    ),
                  ],
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
