import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zic_flutter/core/models/message.dart';

class MessageService {
  static String? baseUrl = dotenv.env['BASE_URL'];

  static Future<Message?> createMessage(Message message) async {
    final url = Uri.parse('$baseUrl/messages/create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return Message.fromJson(jsonData);
      } else {
        print("Failed to create message. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error creating message: $e");
      return null;
    }
  }

  static Future<List<Message>> getMessagesForRoom(String roomId) async {
    final url = Uri.parse('$baseUrl/messages/room/$roomId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Message.fromJson(json)).toList();
      } else {
        print("Failed to fetch messages for room. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching messages for room: $e");
      return [];
    }
  }

  static Future<Message?> getLastMessage(String roomId) async {
    final url = Uri.parse('$baseUrl/messages/room/$roomId/last');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return Message.fromJson(jsonData);
      } else {
        print("Failed to fetch last message. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching last message: $e");
      return null;
    }
  }
}