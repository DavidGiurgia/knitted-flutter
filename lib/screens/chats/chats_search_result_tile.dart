import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/rooms_provider.dart';
import 'package:zic_flutter/core/providers/search_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/widgets/chats/chat_list_tile.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class SearchResultTile extends ConsumerWidget {
  final SearchResult result;

  const SearchResultTile({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    if (user == null) {
      return const SizedBox.shrink();
    }

    if (result.type == 'room') {
      final room = result.data as Room;
      return ChatListTile(room: room);
    } else if (result.type == 'friend') {
      final friend = result.data as User;
      return UserListTile(
        user: friend,
        //actionWidget: HeroIcon(HeroIcons.chevronRight, style: HeroIconStyle.micro, ),
        onTap: () async {
          final room = await RoomService.createPrivateRoom(
            user.id,
            friend.id,
          );
          if (room != null && context.mounted) {
            ref.read(roomsProvider.notifier).addRoom(room);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomSection(room: room),
              ),
            );
          }
        },
      );
    }
    return const SizedBox.shrink();
  }
}
