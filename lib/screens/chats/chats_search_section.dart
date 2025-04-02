import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/rooms_provider.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/search_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/screens/chats/chats_search_result_tile.dart';
import 'package:zic_flutter/screens/friends/find_friends_section.dart';
import 'package:zic_flutter/widgets/search_input.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class ChatsSearchSection extends ConsumerStatefulWidget {
  const ChatsSearchSection({super.key});

  @override
  ConsumerState<ChatsSearchSection> createState() => _ChatsSearchSectionState();
}

class _ChatsSearchSectionState extends ConsumerState<ChatsSearchSection> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchProvider.notifier).searchFriendsAndRooms(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    if (user == null) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.only(right: 6),
        titleSpacing: 0,
        title: SearchInput(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
      ),
      body: Expanded(
        child: Consumer(
          builder: (context, ref, child) {
            final searchAsync = ref.watch(searchProvider);
            final searchQuery = _searchController.text.trim();
            if (searchQuery.isNotEmpty) {
              if (searchAsync.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (searchAsync.hasError) {
                return Center(child: Text('Error: ${searchAsync.error}'));
              }
              if (searchAsync.value?.isEmpty ?? true) {
                return const Center(child: Text('No results found'));
              }
              return ListView.builder(
                itemCount: searchAsync.value!.length,
                itemBuilder: (context, index) {
                  final result = searchAsync.value![index];
                  return SearchResultTile(result: result);
                },
              );
            } else {
              final friendsAsync = ref.watch(friendsProvider(null));
              final friends = friendsAsync.value ?? [];
              if (friends.isEmpty) {
                return _buildEmptyState(context);
              }
              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return UserListTile(
                    user: friend,
                    onTap: () async {
                      final room = await RoomService.createPrivateRoom(
                        user.id,
                        friend.id,
                      );
                      if (room != null && context.mounted) {
                        ref.read(roomsProvider.notifier).addRoom(room);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomSection(room: room),
                          ),
                        );
                      }
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
          Icons.person_search_rounded,
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
                        builder: (context) => const FindFriendsSection(),
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
