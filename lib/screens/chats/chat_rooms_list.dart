// chat_rooms_list.dart
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/chat_rooms_provider.dart';
import 'package:zic_flutter/widgets/chats/chat_list_tile.dart';

class ChatRoomsList extends StatelessWidget {
  const ChatRoomsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatRoomsProvider>(
      builder: (context, roomsProvider, child) {
        if (roomsProvider.rooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeroIcon(
                  HeroIcons.chatBubbleLeftRight,
                  style: HeroIconStyle.solid,
                  color:
                      AppTheme.isDark(context)
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  "No chats found",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color:
                        AppTheme.isDark(context)
                            ? Colors.grey.shade600
                            : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          key: const PageStorageKey('chat_rooms_list'),
          itemCount: roomsProvider.rooms.length,
          itemBuilder: (context, index) {
            final room = roomsProvider.rooms[index];
            return ChatListTile(room: room);
          },
        );
      },
    );
  }
}
