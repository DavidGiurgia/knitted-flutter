import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/api/notifications.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/notification.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
import 'package:zic_flutter/widgets/notifincations/notification.dart';

class NotificationsSection extends StatefulWidget {
  const NotificationsSection({super.key});

  @override
  _NotificationsSectionState createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  List<NotificationModel> notifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() => isLoading = true);
    try {
      List<NotificationModel> fetchedNotifications =
          await NotificationService.fetchNotifications(userProvider.user!.id);
      setState(() => notifications = fetchedNotifications);
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleNotificationAction(
     NotificationModel notification
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    switch (notification.type) {
      case NotificationType.friendRequest:
        await FriendsService.acceptFriendRequest(
          userProvider.user!.id,
          notification.senderId,
        );
        break;
      case NotificationType.chatInvitation:
        final Room? room = await RoomService.getRoomById(notification.data['chatRoomId']);
        if (room != null) {
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TemporaryChatRoom(room: room),
            ),
          );
        } else {
          print("Error: Room not found");
        }
        break;
      case NotificationType.friendRequestAccepted:
        
        break;
    }
    await userProvider.loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: AppTheme.backgroundColor(context),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
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
                ),
      ),
    );
  }
}
