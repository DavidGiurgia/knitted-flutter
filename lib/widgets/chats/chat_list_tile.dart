import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/message.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/chat_rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';

class ChatListTile extends StatelessWidget {
  final Room room;

  const ChatListTile({super.key, required this.room});

  void _showBottomSheet(BuildContext context, Room chat) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    if (currentUser == null) return;

    //final isCreator = currentUser.id == chat.creatorId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete this chat?'),
          content: const Text('Are you sure you want to delete this chat?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.foregroundColor(context)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Provider.of<ChatRoomsProvider>(
                  context,
                  listen: false,
                ).loadRooms(context);
                await RoomService.deleteRoom(chat.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatRoomsProvider = Provider.of<ChatRoomsProvider>(context);
    final currentUser = userProvider.user;

    if (currentUser == null) {
      return const Text("User not logged in");
    }

    return FutureBuilder(
      future: Future.wait([
        chatRoomsProvider.getLastMessage(room.id),
        chatRoomsProvider.getRoomParticipants(room.id),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey100,
            ),
            title: Text("Loading..."),
            subtitle: Text("Fetching chat data..."),
          );
        }

        if (snapshot.hasError) {
          return const ListTile(
            title: Text("Error"),
            subtitle: Text("Failed to load chat data"),
          );
        }

        if (snapshot.data?[1] == null || snapshot.data?[1].isEmpty) {
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey100,
            ),
            title: Text("No data"),
            subtitle: Text("Empty chat data"),
          );
        }

        final Message? lastMessage = snapshot.data?[0] as Message?;
        final List<User> participants = snapshot.data?[1] as List<User>? ?? [];
        if (participants.isEmpty && room.type != "temporary") {
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey100,
            ),
            title: Text("No participants"),
            subtitle: Text("This chat has no participants"),
          );
        }

        final otherParticipants =
            participants.where((p) => p.id != currentUser.id).toList();
        if (otherParticipants.isEmpty && room.type != "temporary") {
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey100,
            ),
            title: Text("No other participants"),
            subtitle: Text("You are the only participant"),
          );
        }

        String title = "New chat";
        if (room.topic == "" && otherParticipants.isNotEmpty) {
          if (otherParticipants.length == 1) {
            title = otherParticipants.first.fullname;
          } else {
            title =
                "${otherParticipants.first.fullname} and ${otherParticipants.length - 1} other${otherParticipants.length > 2 ? 's' : ''}";
          }
        } else {
          title = room.topic.isNotEmpty ? room.topic : "New chat";
        }

        Widget leadingWidget;

        if (room.type == "temporary") {
          leadingWidget = CircleAvatar(
            radius: 25,
            backgroundColor:
                AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey100,
            child: HeroIcon(
              HeroIcons.hashtag,
              style: HeroIconStyle.micro,
              size: 30,
              color: AppTheme.primaryColor,
            ),
          );
        } else if (participants.length > 2) {
          leadingWidget = CircleAvatar(
            radius: 25,
            backgroundColor:
                AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey100,
            child: HeroIcon(
              HeroIcons.users,
              style: HeroIconStyle.micro,
              size: 30,
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey200
                      : AppTheme.grey800,
            ),
          );
        } else if (otherParticipants.isNotEmpty) {
          leadingWidget = AdvancedAvatar(
            size: 50,
            autoTextSize: true,
            image: NetworkImage(
              otherParticipants.first.avatarUrl.isNotEmpty
                  ? otherParticipants.first.avatarUrl
                  : 'https://example.com/default-avatar.png',
            ),
            name: otherParticipants.first.fullname,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey100
                      : AppTheme.grey800,
            ),
            decoration: BoxDecoration(
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey100,
              shape: BoxShape.circle,
            ),
          );
        } else {
          leadingWidget = AdvancedAvatar(
            size: 50,
            decoration: BoxDecoration(
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey200,
              shape: BoxShape.circle,
            ),
          );
        }

        return ListTile(
          onLongPress: () => {_showBottomSheet(context, room)},
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: leadingWidget,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color:
                      AppTheme.isDark(context)
                          ? AppTheme.grey200
                          : AppTheme.grey800,
                ),
              ),
              Text(
                (room.type == "temporary")
                    ? "(#${room.joinCode ?? "Temporary chat"})"
                    : lastMessage != null
                    ? _buildLastMessageText(
                      lastMessage,
                      currentUser,
                      participants,
                    )
                    : 'No messages yet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w400,

                  fontSize: 14,
                  color:
                      AppTheme.isDark(context)
                          ? AppTheme.grey200
                          : AppTheme.grey800,
                ),
              ),
            ],
          ),
          trailing:
              (room.type == "temporary")
                  ? _buildCountdown(room.expiresAt!)
                  : null,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          room.type == 'temporary'
                              ? TemporaryChatRoomSection(room: room)
                              : ChatRoomSection(room: room),
                ),
              ),
        );
      },
    );
  }

  Widget _buildCountdown(DateTime? expiresAt) {
    if (expiresAt == null) {
      return const SizedBox.shrink(); // Sau un alt widget implicit
    }

    final now = DateTime.now().toUtc();
    final expiresAtUtc = expiresAt.toUtc();
    final difference = expiresAtUtc.difference(now);

    String timeText;
    Color textColor = Colors.grey;

    if (difference.inDays > 1) {
      timeText = "${difference.inDays} d";
    } else if (difference.inHours >= 1) {
      timeText = "${difference.inHours} h";
      textColor = AppTheme.primaryColor;
    } else if (difference.inMinutes >= 1) {
      timeText = "${difference.inMinutes} m";
      textColor = Colors.red;
    } else {
      timeText = "Expiring soon!";
      textColor = Colors.red.shade700;
    }

    return Text(timeText, style: TextStyle(fontSize: 18, color: textColor));
  }

  String _buildLastMessageText(
    Message? lastMessage,
    User currentUser,
    List<User> participants,
  ) {
    if (lastMessage == null) {
      return "No messages yet";
    }

    if (lastMessage.senderId == currentUser.id) {
      return "You: ${lastMessage.content ?? 'No content'}";
    } else {
      final sender = participants.firstWhere(
        (user) => user.id == lastMessage.senderId,
        orElse:
            () => User(
              id: '',
              username: '',
              fullname: 'Unknown',
              email: '',
              bio: '',
              role: '',
              friendsIds: [],
              friendRequests: [],
              sentRequests: [],
              blockedUsers: [],
              avatarUrl: '',
              avatarPublicId: '',
              coverUrl: '',
              coverPublicId: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      );
      return "${sender.fullname}: ${lastMessage.content ?? 'No content'}";
    }
  }
}
