import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/room_participants.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';

class ChatListTile extends StatelessWidget {
  final Room room;

  const ChatListTile({super.key, required this.room});

  Future<List<User>> _loadParticipants(String roomId) async {
    List<User> participants = [];
    try {
      final roomParticipants = await RoomParticipantsService.findByRoomId(
        roomId,
      );
      for (var participant in roomParticipants) {
        User? user = await UserService.fetchUserById(participant.userId);
        if (user != null) {
          participants.add(user);
        }
      }
    } catch (e) {
      debugPrint('Error loading participants: $e');
    }
    return participants;
  }

  void _showBottomSheet(BuildContext context, String chatId) {
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
                await RoomService.deleteRoom(chatId);
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
    final currentUser = userProvider.user;

    if (currentUser == null) {
      return const Text("User not logged in");
    }

    return FutureBuilder<List<User>>(
      future: _loadParticipants(room.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            leading: AdvancedAvatar(
              size: 52,
              decoration: BoxDecoration(
                color:
                    AppTheme.isDark(context)
                        ? AppTheme.grey800
                        : AppTheme.grey200,
                shape: BoxShape.circle,
              ),
            ),
            title: const Text("Loading..."),
          );
        } else if (snapshot.hasError) {
          return ListTile(title: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final participants = snapshot.data!;
          final otherParticipants =
              participants.where((p) => p.id != currentUser.id).toList();

          String title = "New chat";
          if (room.topic == "New chat") {
            if (otherParticipants.length == 1) {
              title = otherParticipants.first.fullname;
            } else {
              title =
                  "${otherParticipants.first.fullname} and ${otherParticipants.length - 1} other${otherParticipants.length > 2 ? 's' : ''}";
            }
          } else {
            title = room.topic;
          }
          
          Widget leadingWidget;

          if (room.type == "temporary") {
            leadingWidget = CircleAvatar(
              radius: 25,
              backgroundColor:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey100,
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
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey100,
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
            onLongPress: () => {_showBottomSheet(context, room.id)},
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
                      : "Costel: Nu ba.. 🤣",
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
                                ? TemporaryChatRoom(room: room)
                                : ChatRoomSection(room: room),
                  ),
                ),
          );
        } else {
          return const ListTile(title: Text('No data'));
        }
      },
    );
  }

  Widget _buildCountdown(DateTime expiresAt) {
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
}
