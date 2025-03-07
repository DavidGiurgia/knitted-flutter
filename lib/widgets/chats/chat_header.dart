import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/room_participants.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:heroicons/heroicons.dart';

class ChatHeader extends StatelessWidget {
  final Room room;

  const ChatHeader({super.key, required this.room});

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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    if (currentUser == null) {
      return const Text("User not logged in");
    }

    String truncateTitle(String title, {int maxLength = 25}) {
      if (title.length <= maxLength) return title;
      return "${title.substring(0, maxLength)}...";
    }

    return FutureBuilder<List<User>>(
      future: _loadParticipants(room.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final participants = snapshot.data!;
          final otherParticipants =
              participants.where((p) => p.id != currentUser.id).toList();

          String title = "New chat";
          if (room.topic == "") {
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
              radius: 20,
              backgroundColor:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey200,
              child: HeroIcon(
                HeroIcons.hashtag,
                style: HeroIconStyle.micro,
                size: 25,
                color: AppTheme.primaryColor,
              ),
            );
          } else if (participants.length > 2) {
            leadingWidget = CircleAvatar(
              radius: 20,
              backgroundColor:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey200,
              child: HeroIcon(
                HeroIcons.users,
                style: HeroIconStyle.micro,
                size: 25,
                color:
                    AppTheme.isDark(context)
                        ? AppTheme.grey200
                        : AppTheme.grey800,
              ),
            );
          } else if (otherParticipants.isNotEmpty) {
            leadingWidget = AdvancedAvatar(
              size: 35,
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
            );
          } else {
            leadingWidget = AdvancedAvatar(
              size: 35,
              decoration: BoxDecoration(
                color:
                    AppTheme.isDark(context)
                        ? AppTheme.grey800
                        : AppTheme.grey200,
                shape: BoxShape.circle,
              ),
            );
          }

          return Expanded(
            flex: 1,
            child: InkWell(
              enableFeedback: false,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    leadingWidget,
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truncateTitle(title),
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
                              : "Tap here for chat info",
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
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Text('No data');
        }
      },
    );
  }
}
