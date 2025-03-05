import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zic_flutter/core/models/room_participants.dart';

class RoomParticipantsService {
  static String? baseUrl = dotenv.env['BASE_URL'];

  // Creare participant la cameră
  static Future<RoomParticipant?> create(String userId, String roomId) async {
    final url = Uri.parse('$baseUrl/room-participants');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'roomId': roomId}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return RoomParticipant.fromJson(jsonData);
      } else {
        print(
          "Failed to create room participant. Status code: ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      print("Error creating room participant: $e");
      return null;
    }
  }

  // Obținere participanți după ID cameră
  static Future<List<RoomParticipant>> findByRoomId(String roomId) async {
    final url = Uri.parse('$baseUrl/room-participants/room/$roomId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => RoomParticipant.fromJson(json)).toList();
      } else {
        print(
          "Failed to fetch room participants by room ID. Status code: ${response.statusCode}",
        );
        return [];
      }
    } catch (e) {
      print("Error fetching room participants by room ID: $e");
      return [];
    }
  }

  // Obținere camere după ID utilizator
  static Future<List<RoomParticipant>> findByUserId(String userId) async {
    final url = Uri.parse('$baseUrl/room-participants/user/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => RoomParticipant.fromJson(json)).toList();
      } else {
        print(
          "Failed to fetch room participants by user ID. Status code: ${response.statusCode}",
        );
        return [];
      }
    } catch (e) {
      print("Error fetching room participants by user ID: $e");
      return [];
    }
  }

  // Ștergere participant dintr-o cameră
  static Future<bool> delete(String userId, String roomId) async {
    final url = Uri.parse(
      '$baseUrl/room-participants/user/$userId/room/$roomId',
    );
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          "Failed to delete room participant. Status code: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("Error deleting room participant: $e");
      return false;
    }
  }

  // Ștergere participanți dintr-o cameră
  static Future<bool> deleteByRoomId(String roomId) async {
    final url = Uri.parse('$baseUrl/room-participants/room/$roomId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          "Failed to delete room participants by room ID. Status code: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("Error deleting room participants by room ID: $e");
      return false;
    }
  }

  // Ștergere camere pentru un utilizator
  static Future<bool> deleteByUserId(String userId) async {
    final url = Uri.parse('$baseUrl/room-participants/user/$userId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          "Failed to delete room participants by user ID. Status code: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("Error deleting room participants by user ID: $e");
      return false;
    }
  }

  //get by keys
  static Future<RoomParticipant?> getOne(
    String userId,
    String roomId,
  ) async {
    final url = Uri.parse('$baseUrl/room-participants/user/$userId/room/$roomId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return RoomParticipant.fromJson(jsonData);
      } else {
        print(
          "Failed to fetch room participant by keys. Status code: ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      print("Error fetching room participant by keys: $e");
      return null;
    }
  }
}
