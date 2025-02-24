import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FriendsService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://192.168.0.103:8000";
  static String apiUrl = "$baseUrl/friends";

  static Future<Map<String, dynamic>> request(String senderId, String receiverId) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/request"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"senderId": senderId, "receiverId": receiverId}),
      );

      return _handleResponse(response);
    } catch (error) {
      print("Error sending friend request: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> acceptFriendRequest(String userId, String senderId) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/accept"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "senderId": senderId}),
      );

      return _handleResponse(response);
    } catch (error) {
      print("Error accepting friend request: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> cancelFriendRequest(String senderId, String receiverId) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/cancel"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"senderId": senderId, "receiverId": receiverId}),
      );

      return _handleResponse(response);
    } catch (error) {
      print("Error canceling friend request: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> blockUser(String userId, String blockedUserId) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/block"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "blockedUserId": blockedUserId}),
      );

      return _handleResponse(response);
    } catch (error) {
      print("Error blocking user: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> unblockUser(String userId, String blockedUserId) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/unblock"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "blockedUserId": blockedUserId}),
      );

      return _handleResponse(response);
    } catch (error) {
      print("Error unblocking user: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> removeFriend(String userId, String friendId) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/remove"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "friendId": friendId}),
      );

      return _handleResponse(response);
    } catch (error) {
      print("Error removing friend: $error");
      rethrow;
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }
}
