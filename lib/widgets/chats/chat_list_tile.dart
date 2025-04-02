import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/message.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:zic_flutter/core/providers/rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';
import 'package:zic_flutter/utils/utils.dart';

class ChatListTile extends ConsumerWidget {
  final Room room;

  const ChatListTile({super.key, required this.room});

  void _showBottomSheet(BuildContext context, WidgetRef ref) {
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
                var success = await RoomService.deleteRoom(room.id);
                if (success) {
                  ref.read(roomsProvider.notifier).removeRoom(room.id);

                  Navigator.of(context).pop();
                } else {
                  CustomToast.show(context, "Failed to delete chat");
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final currentUser = userAsync.value;

    if (currentUser == null) {
      return const Text("User not logged in");
    }

    final unreadCount = ref
        .read(roomsProvider.notifier)
        .getUnreadCount(room.id);

    return FutureBuilder<List<User>>(
      future: ref.read(roomsProvider.notifier).getRoomParticipants(room.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context);
        } else if (snapshot.hasError) {
          return _buildErrorState(context, "Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildErrorState(context, "No participants found");
        } else {
          final participants = snapshot.data!;
          final otherParticipants =
              participants.where((p) => p.id != currentUser.id).toList();
          final title = _getRoomTitle(otherParticipants);
          return ListTile(
            onLongPress: () => _showBottomSheet(context, ref),
            leading: _getLeadingWidget(context, otherParticipants),
            title: _buildTitleText(context, title),
            subtitle: _buildSubtitleText(
              context,
              room.lastMessage,
              currentUser,
              participants,
              unreadCount,
            ),
            trailing: _buildTrailingWidget(context, unreadCount),
            onTap: () => _navigateToChatRoom(context),
          );
        }
      },
    );
  }

  String _getRoomTitle(List<User> otherParticipants) {
    if (room.topic == "" && otherParticipants.isNotEmpty) {
      if (otherParticipants.length == 1) {
        return otherParticipants.first.fullname;
      } else {
        return "${otherParticipants.first.fullname} and ${otherParticipants.length - 1} other${otherParticipants.length > 2 ? 's' : ''}";
      }
    }
    return room.topic.isNotEmpty ? room.topic : "New chat";
  }

  Widget _buildEmptyAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 25,
      backgroundColor:
          AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey100,
    );
  }

  ListTile _buildLoadingState(BuildContext context) {
    return ListTile(
      leading: _buildEmptyAvatar(context),
      title: const Text("Loading..."),
      subtitle: const Text("Fetching chat data..."),
    );
  }

  ListTile _buildErrorState(BuildContext context, String log) {
    return ListTile(
      leading: _buildEmptyAvatar(context),
      title: const Text("Error", style: TextStyle(color: Colors.red)),
      subtitle: Text(log),
    );
  }

  Text _buildTitleText(BuildContext context, String title) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 18,
        color: AppTheme.isDark(context) ? AppTheme.grey200 : AppTheme.grey800,
      ),
    );
  }

  Text _buildSubtitleText(
    BuildContext context,
    Message? lastMessage,
    User currentUser,
    List<User> participants,
    int unreadCount,
  ) {
    return Text(
      (room.type == "temporary")
          ? "(#${room.joinCode ?? "Temporary chat"})"
          : lastMessage != null
          ? _buildLastMessageText(lastMessage, currentUser, participants)
          : 'No messages yet',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color:
            unreadCount > 0
                ? AppTheme.foregroundColor(context)
                : (AppTheme.isDark(context)
                    ? AppTheme.grey400
                    : AppTheme.grey600),
      ),
    );
  }

  Widget _buildTrailingWidget(BuildContext context, int unreadCount) {
    return (room.type == "temporary")
        ? _buildCountdown(room.expiresAt!)
        // : (unreadCount > 0)
        // ? Badge(
        //   label: Text(
        //     unreadCount.toString(),
        //     style: TextStyle(color: AppTheme.backgroundColor(context)),
        //   ),
        //   backgroundColor: AppTheme.primaryColor,
        // )
        : SizedBox();
  }

  Widget _buildCountdown(DateTime? expiresAt) {
    if (expiresAt == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now().toUtc();
    final expiresAtUtc = expiresAt.toUtc();
    final difference = expiresAtUtc.difference(now);

    String timeText;
    Color textColor = Colors.grey;

    if (difference.inHours >= 1) {
      timeText =
          "${difference.inHours} h";
    } else if (difference.inMinutes >= 1) {
      timeText = "${difference.inMinutes} m";
      textColor = Colors.red;
    } else if (difference.inSeconds >= 0) {
      timeText = "Ending soon!";
      textColor = Colors.red.shade700;
    } else {
      timeText = "Ended";
      textColor = Colors.grey;
    }

    return Text(timeText, style: TextStyle(fontSize: 16, color: textColor));
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
      return lastMessage.content; // • ${lastMessage.status}";
    } else if (room.type == "private") {
      return "${lastMessage.content} • ${multiFormatDateString(lastMessage.createdAt, short: true)}";
    } else {
      final sender = participants.firstWhere(
        (user) => user.id == lastMessage.senderId,
        orElse: () => User.defaultUser(),
      );
      return "${sender.fullname}: ${lastMessage.content}";
    }
  }

  void _navigateToChatRoom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                room.type == 'temporary'
                    ? TemporaryChatRoomSection(room: room)
                    : ChatRoomSection(room: room),
      ),
    );
  }

  Widget _getLeadingWidget(BuildContext context, List<User> otherParticipants) {
    if (room.type == "temporary") {
      return CircleAvatar(
        radius: 25,
        backgroundColor:
            AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey100,
        child: Icon(
          TablerIcons.hash,
          size: 30,
          color: AppTheme.primaryColor,
        ),
      );
    } else if (otherParticipants.length > 1) {
      return CircleAvatar(
        radius: 25,
        backgroundColor:
            AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey100,
        child: Icon(
          TablerIcons.users,
          size: 26,
          color: AppTheme.isDark(context) ? AppTheme.grey200 : AppTheme.grey800,
        ),
      );
    } else if (otherParticipants.isNotEmpty) {
      return AdvancedAvatar(
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
          color: AppTheme.isDark(context) ? AppTheme.grey100 : AppTheme.grey800,
        ),
        decoration: BoxDecoration(
          color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey100,
          shape: BoxShape.circle,
        ),
      );
    } else {
      return AdvancedAvatar(
        size: 50,
        decoration: BoxDecoration(
          color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200,
          shape: BoxShape.circle,
        ),
      );
    }
  }
}
