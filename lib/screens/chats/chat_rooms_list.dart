// chat_rooms_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/rooms_provider.dart';
import 'package:zic_flutter/widgets/chats/chat_list_tile.dart';

class ChatRoomsList extends ConsumerWidget {
  const ChatRoomsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);

    if (roomsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (roomsAsync.hasError) {
      return Center(child: Text('Error: ${roomsAsync.error}'));
    }

    final rooms = roomsAsync.value ?? [];

    if (rooms.isEmpty) {
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
    return roomsAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stack) => Center(child: Text('Error: $error')),
    data: (rooms) {
      return ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return ChatListTile(room: room);
        },
      );
    },
  );
  }
}
