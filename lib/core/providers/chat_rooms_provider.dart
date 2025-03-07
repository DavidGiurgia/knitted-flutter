import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/room_participants.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/core/api/message_service.dart';
import 'package:zic_flutter/core/models/message.dart';

class ChatRoomsProvider with ChangeNotifier {
  List<Room> _rooms = [];
  final Map<String, List<User>> _roomParticipants = {};
  final Map<String, Message?> _lastMessages = {};
  final Map<String, List<Message>> _roomMessages = {};
  final Map<String, DateTime?> _lastMessageTimes = {}; // RoomId -> Last message time

  List<Room> get rooms => _rooms;
  Map<String, List<User>> get roomParticipants => _roomParticipants;
  Map<String, Message?> get lastMessages => _lastMessages;
  Map<String, List<Message>> get roomMessages => _roomMessages;

  Future<void> loadRooms(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user == null) return;

    _rooms.clear();
    _roomParticipants.clear();
    _lastMessages.clear();
    _roomMessages.clear();
    _lastMessageTimes.clear(); // Clear last message times as well

    final roomParticipantsList = await RoomParticipantsService.findByUserId(
      userProvider.user!.id,
    );
    for (var participant in roomParticipantsList) {
      final room = await RoomService.getRoomById(participant.roomId);
      if (room != null) {
        _rooms.add(room);
        await _loadRoomParticipants(room.id);
        await _loadLastMessage(room.id);
      }
    }
    _sortRoomsByLastMessageTime(); // Sort rooms after loading
    notifyListeners();
  }

  Future<void> _loadRoomParticipants(String roomId) async {
    final participantsList = await RoomParticipantsService.findByRoomId(roomId);
    if (participantsList.isNotEmpty) {
      _roomParticipants[roomId] = [];
      for (var participant in participantsList) {
        final user = await UserService.fetchUserById(participant.userId);
        if (user != null) {
          _roomParticipants[roomId]!.add(user);
        }
      }
    }
  }

  Future<void> _loadLastMessage(String roomId) async {
    final lastMessage = await MessageService.getLastMessage(roomId);
    _lastMessages[roomId] = lastMessage;
    _lastMessageTimes[roomId] = lastMessage?.createdAt; // Store last message time
  }

  void addRoom(Room room) {
    if (!_rooms.any((r) => r.id == room.id)) {
      _rooms.add(room);
      _sortRoomsByLastMessageTime();
      _loadRoomParticipants(room.id);
      _loadLastMessage(room.id);
      notifyListeners();
    }
  }

  Future<void> updateLastMessage(String roomId) async {
    await _loadLastMessage(roomId);
    _sortRoomsByLastMessageTime();
    notifyListeners();
  }

  Future<void> loadRoomMessages(String roomId) async {
    final messages = await MessageService.getMessagesForRoom(roomId);
    _roomMessages[roomId] = messages;
    notifyListeners();
  }

  void _sortRoomsByLastMessageTime() {
    _rooms.sort((a, b) {
      final timeA = _lastMessageTimes[a.id];
      final timeB = _lastMessageTimes[b.id];

      if (timeA == null && timeB == null) {
        return 0;
      } else if (timeA == null) {
        return 1;
      } else if (timeB == null) {
        return -1;
      } else {
        return timeB.compareTo(timeA);
      }
    });
  }
}