import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zic_flutter/core/models/user.dart';
import 'package:collection/collection.dart';

class FriendsService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://192.168.0.103:8000";
  static String apiUrl = "$baseUrl/friends";

  static Future<List<User>> getUserFriends(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/$userId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> friendsJson = jsonDecode(response.body);
        return friendsJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load friends");
      }
    } catch (error) {
      print("Error fetching user friends: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> request(
    String senderId,
    String receiverId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/request"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"requestSenderId": senderId, "requestReceiverId": receiverId}),
      );

      return _handleResponse(response);
    } catch (error) {
      print("Error sending friend request: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> acceptFriendRequest(
    String userId,
    String senderId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/accept"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"requestSenderId": senderId, "requestReceiverId": userId}),
      );

      return _handleResponse(response);
    } catch (error) {
      print("Error accepting friend request: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> cancelFriendRequest(
    String senderId,
    String receiverId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/cancel"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"requestSenderId": senderId, "requestReceiverId": receiverId}),
      );

      return _handleResponse(response);
    } catch (error) {
      print("Error canceling friend request: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> blockUser(
    String userId,
    String blockedUserId,
  ) async {
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

  static Future<Map<String, dynamic>> unblockUser(
    String userId,
    String blockedUserId,
  ) async {
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

  static Future<Map<String, dynamic>> removeFriend(
    String userId,
    String friendId,
  ) async {
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


  static Future<List<User>> fetchMutualFriends(
    String userId,
    String friendId,
  ) async {
    try {
      final List<User> mutualFriends = [];
      final List<User> userFriends = await getUserFriends(userId);
      final List<User> friendFriends = await getUserFriends(friendId);

      for (User userFriend in userFriends) {
        if (friendFriends.any(
          (friendFriend) => friendFriend.id == userFriend.id,
        )) {
          mutualFriends.add(userFriend);
        }
      }
      return mutualFriends;
    } catch (error) {
      print("Error fetching mutual friends: $error");
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

  static Future<List<User>> getRecommendedUsers(String userId) async {
    try {
      // 1. Obține lista de prieteni ai utilizatorului curent
      List<User> friends = await getUserFriends(userId);

      // 2. Obține lista de prieteni ai prietenilor
      List<User> friendsOfFriends = [];
      for (var friend in friends) {
        friendsOfFriends.addAll(await getUserFriends(friend.id));
      }

      // 3. Calculează frecvența prietenilor comuni
      Map<String, int> frequency = {};
      for (var user in friendsOfFriends) {
        if (user.id != userId && !friends.any((f) => f.id == user.id)) {
          frequency[user.id] = (frequency[user.id] ?? 0) + 1;
        }
      }

      // 4. Sortează și filtrează recomandările
      List<User> recommendedUsers = frequency.entries
          .sorted((a, b) => b.value.compareTo(a.value))
          .map((entry) => friendsOfFriends.firstWhere((user) => user.id == entry.key))
          .toList();

      // 5. Limitează numărul de recomandări la 30
      return recommendedUsers.take(30).toList();
    } catch (error) {
      print("Error fetching recommended users: $error");
      rethrow;
    }
  }
}
