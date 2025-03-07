import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zic_flutter/core/models/chat_room.dart';

class RoomService {
  static String? baseUrl = dotenv.env['BASE_URL'];

  // Crearea unei camere (temporare sau permanente)
  static Future<Room?> createRoom(Room roomData) async {
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

  // Obținerea camerelor temporare create de un utilizator
  static Future<List<Room>> getCreatorRooms(String userId) async {
    final url = Uri.parse('$baseUrl/rooms/creator/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Room.fromJson(json)).toList();
      } else {
        print(
          "Failed to fetch creator rooms. Status code: ${response.statusCode}",
        );
        return [];
      }
    } catch (e) {
      print("Error fetching creator rooms: $e");
      return [];
    }
  }

  // Obținerea camerelor unui utilizator
  static Future<List<Room>> getRoomsForUser(String userId) async {
    final url = Uri.parse('$baseUrl/rooms/user/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Room.fromJson(json)).toList();
      } else {
        print(
          "Failed to fetch rooms for user. Status code: ${response.statusCode}",
        );
        return [];
      }
    } catch (e) {
      print("Error fetching rooms for user: $e");
      return [];
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
        return false;
      }
    } catch (e) {
      print("Error deleting room: $e");
      return false;
    }
  }

  // Obținerea participanților unei camere
  static Future<List<String>> getParticipantsForRoom(String roomId) async {
    final url = Uri.parse('$baseUrl/rooms/$roomId/participants');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => json.toString()).toList();
      } else {
        print(
          "Failed to fetch participants for room. Status code: ${response.statusCode}",
        );
        return [];
      }
    } catch (e) {
      print("Error fetching participants for room: $e");
      return [];
    }
  }

  // Adăugarea mai multor participanți la o cameră
  static Future<bool> addParticipantsToRoom(
    String roomId,
    List<String> participantsIds,
  ) async {
    final url = Uri.parse('$baseUrl/rooms/$roomId/participants');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'participantsIds': participantsIds}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print(
          "Failed to add participants. Status code: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("Error adding participants: $e");
      return false;
    }
  }

  // Adăugarea unui participant la o cameră
  static Future<bool> addParticipantToRoom(String roomId, String userId) async {
    final url = Uri.parse('$baseUrl/rooms/$roomId/participant/$userId');
    try {
      final response = await http.post(url);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print("Failed to add participant. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error adding participant: $e");
      return false;
    }
  }

  // Eliminarea unui participant dintr-o cameră
  static Future<bool> removeParticipantFromRoom(
    String roomId,
    String userId,
  ) async {
    final url = Uri.parse('$baseUrl/rooms/$roomId/participant/$userId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          "Failed to remove participant. Status code: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("Error removing participant: $e");
      return false;
    }
  }

  static Future<Room?> createRoomWithFriend(
    String userId,
    String friendId,
  ) async {
    // Generarea participantKeys
    final participantsIds = [userId, friendId];
    participantsIds.sort(); // Sortarea ID-urilor
    final participantsKey = participantsIds.join('-');

    try {
      // Creare obiect Room
      final newRoomData = Room(
        type: 'permanent',
        creatorId: userId,
        topic: '',
        allowJoinCode: false,
        id: '', // id-ul va fi generat de backend
        participantsKey: participantsKey,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Creare camera
      final room = await RoomService.createRoom(newRoomData);
      if (room != null) {
        // Adaugare participanti
        final success = await RoomService.addParticipantsToRoom(room.id, [
          friendId,
        ]);

        if (success) return room;
      } 
    } catch (error) {
      print("Error creating room: $error");
    }
    return null;
  }
}
