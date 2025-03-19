import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/room_participants.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/message.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/core/services/chat_socket_service.dart';

class RoomsNotifier extends AsyncNotifier<List<Room>> {
  final Map<String, int> _unreadCounts = {};
  late final ChatSocketService _socketService;

  RoomsNotifier() {
    _socketService = ChatSocketService ();
    _setupSocketListeners();
  }

  @override
  Future<List<Room>> build() async {
    final user = ref.watch(userProvider).value;
    if (user == null) return [];

    await _loadUnreadCounts(user.id);
    return await _fetchRoomsForUser(user.id);
  }

  void _setupSocketListeners() {
    // Ascultă pentru actualizări ale camerelor
    _socketService.onRoomUpdated = (roomId, lastActivity, lastMessage) {
      updateRoomActivity(roomId, lastActivity, lastMessage);
    };

    // Ascultă pentru actualizări ale numărului de mesaje necitite
    _socketService.onUnreadCountUpdated = (roomId, unreadCount) {
      _unreadCounts[roomId] = unreadCount;
      state = AsyncValue.data(state.value ?? []);
    };

    // Ascultă pentru utilizatori care intră sau ies din cameră
    _socketService.onUserJoined = (userId, roomId) {
      // Poți adăuga logica pentru a actualiza lista de participanți
    };

    _socketService.onUserLeft = (userId, roomId) {
      // Poți adăuga logica pentru a actualiza lista de participanți
    };
  }

  Future<void> _loadUnreadCounts(String userId) async {
    try {
      _unreadCounts.clear();
      final rooms = await _fetchRoomsForUser(userId);
      for (final room in rooms) {
        _unreadCounts[room.id] = await RoomService.getRoomUnreadCount(
          room.id,
          userId,
        );
      }
      print("Unread count:  $_unreadCounts");
    } catch (e) {
      print("Error loading unread counts: $e");
    }
  }

  Future<List<Room>> _fetchRoomsForUser(String userId) async {
    try {
      final roomsForUserList = await RoomParticipantsService.findByUserId(
        userId,
      );
      final rooms = await Future.wait(
        roomsForUserList.map((pair) => _fetchRoomIfActive(pair.roomId)),
      );
      return rooms.whereType<Room>().toList()..sort(
        (a, b) => (b.lastActivity ?? DateTime(0)).compareTo(
          a.lastActivity ?? DateTime(0),
        ),
      );
    } catch (e) {
      print("Error fetching rooms: $e");
      return [];
    }
  }

  Future<Room?> _fetchRoomIfActive(String roomId) async {
    try {
      final room = await RoomService.getRoomById(roomId);
      return room?.isActive == true ? room : null;
    } catch (e) {
      print("Error fetching room $roomId: $e");
      return null;
    }
  }

  Future<List<User>> getRoomParticipants(String roomId) async {
    try {
      final participantsList = await RoomParticipantsService.findByRoomId(
        roomId,
      );
      final participants = await Future.wait(
        participantsList.map((p) => UserService.fetchUserById(p.userId)),
      );
      return participants.whereType<User>().toList();
    } catch (e) {
      print("Error fetching participants for room $roomId: $e");
      return [];
    }
  }

  void addRoom(Room room) {
    if (!room.isActive) return;

    final rooms = state.value ?? [];
    if (!rooms.any((r) => r.id == room.id)) {
      final updatedRooms = [...rooms, room]..sort(
        (a, b) => (b.lastActivity ?? DateTime(0)).compareTo(
          a.lastActivity ?? DateTime(0),
        ),
      );
      state = AsyncValue.data(updatedRooms);
    }
  }

  void removeRoom(String roomId) {
    final rooms = state.value ?? [];
    if (rooms.any((r) => r.id == roomId)) {
      final updatedRooms = rooms.where((r) => r.id != roomId).toList();
      state = AsyncValue.data(updatedRooms);
    }
  }

  void updateRoomActivity(
    String roomId,
    DateTime activityTime,
    Message lastMessage,
  ) {
    final rooms = state.value ?? [];
    final roomIndex = rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex != -1) {
      final updatedRooms = [...rooms];
      updatedRooms[roomIndex].lastActivity = activityTime;
      updatedRooms[roomIndex].lastMessage = lastMessage;
      updatedRooms.sort(
        (a, b) => (b.lastActivity ?? DateTime(0)).compareTo(
          a.lastActivity ?? DateTime(0),
        ),
      );
      state = AsyncValue.data(updatedRooms);
    }
  }

  int getUnreadCount(String roomId) => _unreadCounts[roomId] ?? 0;
}

final roomsProvider = AsyncNotifierProvider<RoomsNotifier, List<Room>>(
  RoomsNotifier.new,
);
