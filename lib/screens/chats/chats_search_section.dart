import 'dart:async';

import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/chat_rooms_provider.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/search_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/screens/chats/chats_search_result_tile.dart';
import 'package:zic_flutter/screens/chats/new_chat_section.dart';
import 'package:zic_flutter/widgets/search_input.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class ChatsSearchSection extends StatefulWidget {
  const ChatsSearchSection({super.key});

  @override
  State<ChatsSearchSection> createState() => _ChatsSearchSectionState();
}

class _ChatsSearchSectionState extends State<ChatsSearchSection> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomsProvider = Provider.of<ChatRoomsProvider>(
        context,
        listen: false,
      );
      final friendsProvider = Provider.of<FriendsProvider>(
        context,
        listen: false,
      );
      roomsProvider.loadRooms(context);
      friendsProvider.loadFriends(context);
    });
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      Provider.of<SearchProvider>(context, listen: false).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.only(right: 6),
        titleSpacing: 0,
        title: SearchInput(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
        actions: [
          HeroIcon(HeroIcons.paperAirplane, style: HeroIconStyle.micro, ),
        ],
      ),
      body: Expanded(
        child: Consumer<SearchProvider>(
          builder: (context, searchProvider, child) {
            final searchQuery = _searchController.text.trim();
            if (searchQuery.isNotEmpty) {
              if (searchProvider.results.isEmpty) {
                return const Center(child: Text('No results found'));
              }
              return ListView.builder(
                itemCount: searchProvider.results.length,
                itemBuilder: (context, index) {
                  final result = searchProvider.results[index];
                  return SearchResultTile(result: result);
                },
              );
            } else {
              return Consumer<FriendsProvider>(
                builder: (context, friendsProvider, child) {
                  if (friendsProvider.friends.isEmpty) {
                    return _buildEmptyState(context); // no friends
                  }
                  return ListView.builder(
                    itemCount: friendsProvider.friends.length,
                    itemBuilder: (context, index) {
                      final friend = friendsProvider.friends[index];
                      return UserListTile(
                        user: friend,
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatRoomSection(room: room),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}

Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person_search,
          size: 60,
          color:
              AppTheme.isDark(context)
                  ? Colors.grey.shade700
                  : Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          "No friends found",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color:
                AppTheme.isDark(context)
                    ? Colors.grey.shade500
                    : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: "You can ",
            style: TextStyle(
              fontSize: 16,
              color:
                  AppTheme.isDark(context)
                      ? Colors.grey.shade500
                      : Colors.grey.shade600,
            ),
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const NewChatSection(), //FindFriendsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "find friends",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const TextSpan(text: " to start chatting."),
            ],
          ),
        ),
      ],
    ),
  );
}
