import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zic_flutter/core/api/room_participants.dart';
import 'package:zic_flutter/core/models/chat_room.dart';

class RoomService {
  static String? baseUrl = dotenv.env['BASE_URL'];

  // Crearea unei camere (temporare sau permanente)
  static Future<Room?> createRoom(Room roomData) async {
    if (baseUrl == null) {
      print("BASE_URL is not set in environment variables.");
      return null;
    }
    final url = Uri.parse('$baseUrl/rooms/create');
    final jsonRoomData = roomData.toJson();
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonRoomData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonData = jsonDecode(response.body);
          return Room.fromJson(jsonData);
        } catch (e) {
          print("Error decoding JSON: $e");
          print("Response body: ${response.body}");
          return null;
        }
      } else {
        print("Failed to create room. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error creating room: $e");
      return null;
    }
  }
  

  // Actualizarea unei camere
  static Future<Room?> updateRoom(String roomId, Room updateData) async {
    final url = Uri.parse('$baseUrl/rooms/$roomId');
    final jsonRoomData = updateData.toJson();
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonRoomData),
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonData = jsonDecode(response.body);
          return Room.fromJson(jsonData);
        } catch (e) {
          print("Error decoding JSON: $e");
          print("Response body: ${response.body}");
          return null;
        }
      } else {
        print("Failed to update room. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error updating room: $e");
      return null;
    }
  }

  // Obținerea unei camere după ID
  static Future<Room?> getRoomById(String roomId) async {
    final url = Uri.parse('$baseUrl/rooms/$roomId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return Room.fromJson(jsonData);
      } else {
        print(
          "Failed to fetch room by ID. Status code: ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      print("Error fetching room by ID: $e");
      return null;
    }
  }

  // Obținerea unei camere temporare după codul de alăturare
  static Future<Room?> getRoomByCode(String joinCode) async {
    final url = Uri.parse('$baseUrl/rooms/code/$joinCode');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return Room.fromJson(jsonData);
      } else {
        print(
          "Failed to fetch room by code. Status code: ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      print("Error fetching room by code: $e");
      return null;
    }
  }

  // Verificarea dacă un cod de alăturare este unic
  static Future<bool> checkCode(String joinCode) async {
    final url = Uri.parse('$baseUrl/rooms/code/check/$joinCode');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to check code. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error checking code: $e");
      return false;
    }
  }

  // Ștergerea unei camere
  static Future<bool> deleteRoom(String roomId) async {
    final url = Uri.parse('$baseUrl/rooms/$roomId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to delete room. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error deleting room: $e");
      return false;
    }
  }

  // Crearea unei camere private
  static Future<Room?> createPrivateRoom(String userId, String friendId) async {
    final participantsIds = [userId, friendId];
    participantsIds.sort();
    final privateRoomKey = participantsIds.join('-');

    final newRoomData = Room(
      type: 'private',
      creatorId: userId,
      topic: '',
      allowJoinCode: false,
      id: '',
      privateRoomKey: privateRoomKey,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      expiresAt: null,
      isActive: false,
      lastActivity: null,
    );

    final newRoom = await createRoom(newRoomData);
    if (newRoom != null) {
      await RoomParticipantsService.addParticipantToRoom(newRoom.id, friendId);
      return newRoom;
    } else {
      print("Failed to create private room.");
      return null;
    }
  }

  // Crearea unei camere de grup
  static Future<Room?> createGroupRoom(String userId, String topic) async {
    final newRoomData = Room(
      type: 'group',
      creatorId: userId,
      topic: topic,
      allowJoinCode: false,
      id: '',
      privateRoomKey: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      expiresAt: null,
      isActive: true,
      lastActivity: null,
    );

    return createRoom(newRoomData);
  }

  // Crearea unei camere temporare
  static Future<Room?> createTemporaryRoom(
    String userId,
    String topic,
    DateTime expiresAt,
    String? joinCode,
    bool allowJoinCode,
  ) async {
    final newRoomData = Room(
      type: 'temporary',
      creatorId: userId,
      topic: topic,
      allowJoinCode: allowJoinCode,
      id: '',
      privateRoomKey: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      expiresAt: expiresAt,
      isActive: true,
      lastActivity: null,
      joinCode: joinCode,
    );

    return createRoom(newRoomData);
  }

  static Future<bool> activateRoom(String roomId) async {
    final url = Uri.parse('$baseUrl/rooms/$roomId/activate');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to activate room. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error activating room: $e");
      return false;
    }
  }

  static Future<int> getRoomUnreadCount(String roomId, String userId) async {
  final url = Uri.parse('$baseUrl/rooms/$roomId/unread-count?userId=$userId'); // Construct the URL with query parameter
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final unreadCount = int.parse(response.body); // Parse the response body as an integer
      return unreadCount;
    } else {
      print("Failed to fetch unread count. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      return 0; // Return 0 or handle error as needed
    }
  } catch (e) {
    print("Error fetching unread count: $e");
    return 0; // Return 0 or handle error as needed
  }
}
}
