import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/message_service.dart';
import 'package:zic_flutter/core/api/room_participants.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/message.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';

class ChatRoomsProvider with ChangeNotifier {
  List<Room> _rooms = [];

  List<Room> get rooms => _rooms;

  Future<void> loadRooms(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user == null) return;

    try {
      final roomsForUserList = await RoomParticipantsService.findByUserId(
        userProvider.user!.id,
      );
      if (roomsForUserList.isNotEmpty) {
        List<Room> roomList = [];
        for (var pair in roomsForUserList) {
          try {
            final room = await RoomService.getRoomById(pair.roomId);
            if (room != null && room.isActive) {
              roomList.add(room);
            } else {
              print("Room ${pair.roomId} is null or inactive");
            }
          } catch (e) {
            print("Error fetching room ${pair.roomId}: $e");
          }
        }
        _rooms =
            roomList..sort(
              (a, b) => (b.lastActivity ?? DateTime(0)).compareTo(
                a.lastActivity ?? DateTime(0),
              ),
            );
        notifyListeners();
      }
    } catch (e) {
      print("Error loading rooms: $e");
    }
  }

  Future<List<User>> getRoomParticipants(String roomId) async {
    try {
      final participantsList = await RoomParticipantsService.findByRoomId(
        roomId,
      );
      if (participantsList.isNotEmpty) {
        List<User> participants = [];
        for (var participant in participantsList) {
          try {
            final user = await UserService.fetchUserById(participant.userId);
            if (user != null) {
              participants.add(user);
            }
          } catch (e) {
            print("Error fetching user ${participant.userId}: $e");
          }
        }
        return participants;
      }
    } catch (e) {
      print("Error fetching participants for room $roomId: $e");
    }
    return [];
  }

  Future<Message?> getLastMessage(String roomId) async {
    try {
      return await MessageService.getLastMessage(roomId);
    } catch (e) {
      print("Error fetching last message for room $roomId: $e");
      return null;
    }
  }

  void addRoom(Room room) {
    if (!room.isActive) return;


    if (!_rooms.any((r) => r.id == room.id)) {
      _rooms.add(room);
      _rooms.sort(
        (a, b) => (b.lastActivity ?? DateTime(0)).compareTo(
          a.lastActivity ?? DateTime(0),
        ),
      );
      notifyListeners();
    }
  }

  

  void updateRoomActivity(String roomId, DateTime activityTime) {
    if (activityTime.isAfter(DateTime.now())) {
      print("Invalid activity time: $activityTime");
      return;
    }

    final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex != -1) {
      _rooms[roomIndex].lastActivity = activityTime;
      _rooms.sort(
        (a, b) => (b.lastActivity ?? DateTime(0)).compareTo(
          a.lastActivity ?? DateTime(0),
        ),
      );
      notifyListeners();
    }
  }
}
