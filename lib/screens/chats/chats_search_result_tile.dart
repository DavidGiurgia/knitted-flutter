import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/chat_rooms_provider.dart';
import 'package:zic_flutter/core/providers/search_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/widgets/chats/chat_list_tile.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class SearchResultTile extends StatelessWidget {
  final SearchResult result;

  const SearchResultTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (result.type == 'room') {
      final room = result.data as Room;
      return ChatListTile(room: room);
    } else if (result.type == 'friend') {
      final friend = result.data as User;
      return UserListTile(
        user: friend,
        //actionWidget: HeroIcon(HeroIcons.chevronRight, style: HeroIconStyle.micro, ),
        onTap: () async {
          final room = await RoomService.createRoomWithFriend(
            userProvider.user!.id,
            friend.id,
          );
          if (room != null && context.mounted) {
            Provider.of<ChatRoomsProvider>(
              context,
              listen: false,
            ).addRoom(room);
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
