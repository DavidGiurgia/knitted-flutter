import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';

class SearchResult {
  final String type; // "room" sau "friend"
  final dynamic data; // Room sau User

  SearchResult.room(Room room) : type = 'room', data = room;
  SearchResult.friend(User friend) : type = 'friend', data = friend;
}

class SearchNotifier extends AsyncNotifier<List<SearchResult>> {
  @override
  Future<List<SearchResult>> build() async {
    return [];
  }

  Future<void> searchUsers(String query) async {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      final users = await UserService.searchUser(query, user.id);
      state = AsyncValue.data(
        users.map((u) => SearchResult.friend(u)).toList(),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> searchFriendsAndRooms(String query) async {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    final friendsAsync = ref.watch(friendsProvider(null));
    final roomsAsync = ref.watch(roomsProvider);

    final friends = friendsAsync.value ?? [];
    final rooms = roomsAsync.value ?? [];

    final friendResults = friends
        .where(
          (friend) =>
              friend.fullname.toLowerCase().contains(query.toLowerCase()),
        )
        .map((friend) => SearchResult.friend(friend));

    final roomResults = rooms
        .where((room) => room.topic.toLowerCase().contains(query.toLowerCase()))
        .map((room) => SearchResult.room(room));

    state = AsyncValue.data([...friendResults, ...roomResults]);
  }
}

final searchProvider =
    AsyncNotifierProvider<SearchNotifier, List<SearchResult>>(
      () => SearchNotifier(),
    );
