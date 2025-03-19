import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/notification.dart';
import 'package:zic_flutter/core/providers/notifications_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
import 'package:zic_flutter/widgets/notifincations/notification.dart';

class NotificationsSection extends ConsumerStatefulWidget {
  const NotificationsSection({super.key});

  @override
  ConsumerState<NotificationsSection> createState() =>
      _NotificationsSectionState();
}

class _NotificationsSectionState extends ConsumerState<NotificationsSection> {
  Future<void> _handleNotificationAction(NotificationModel notification) async {
    final userId = ref.watch(userProvider).value?.id;

    if (userId == null) {
      return;
    }
    switch (notification.type) {
      case NotificationType.friendRequest:
        await FriendsService.acceptFriendRequest(userId, notification.senderId);
        break;
      case NotificationType.chatInvitation:
        final Room? room = await RoomService.getRoomById(
          notification.data['chatRoomId'],
        );
        if (room != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TemporaryChatRoomSection(room: room),
            ),
          );
        } else {
          print("Error: Room not found");
        }
        break;
      case NotificationType.friendRequestAccepted:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: AppTheme.backgroundColor(context),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
        },
        child: notificationsAsync.when(
          data: (notifications) {
            return notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationItem(
                      notification: notification,
                      onAction: () => _handleNotificationAction(notification),
                    );
                  },
                  addAutomaticKeepAlives: true,
                );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text("Error: $error")),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              "No notifications yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "We'll let you know when something happens.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
