import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zic_flutter/core/models/notification.dart';

class NotificationService {
  static String apiUrl =
      dotenv.env['BASE_URL'] ??
      "http://192.168.0.103:8000"; // URL-ul API-ului backend
  static final String baseUrl = "$apiUrl/notifications";

  // Creează o notificare
  static Future<Map<String, dynamic>> createNotification(
    String senderId,
    String receiverId,

    String type,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
          'type': type, // Include tipul notificării
          'data': data, // Include datele flexibile pentru notificare
        }),
      );
      if (response.statusCode >= 200 || response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        print(response.statusCode);
        throw Exception('Failed to create notification');
      }
    } catch (error) {
      print("Error creating notification: $error");
      rethrow;
    }
  }

 static Future<List<NotificationModel>> fetchNotifications(
    String userId, {
    bool unreadOnly = false,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId?unreadOnly=$unreadOnly'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body); // Decode into a List
        return jsonData.map((json) => NotificationModel.fromJson(json)).toList(); // Parse each item
      } else {
        throw Exception('Failed to fetch notifications. Status Code: ${response.statusCode}'); // Include status code in exception
      }
    } catch (error) {
      print("Error fetching notifications: $error");
      rethrow;
    }
  }

  // Marchează o notificare ca citită
  static Future<Map<String, dynamic>> markNotificationAsRead(
    String notificationId,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$notificationId/read'),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } catch (error) {
      print("Error marking notification as read: $error");
      rethrow;
    }
  }

  // Șterge o notificare
  static Future<Map<String, dynamic>> deleteNotification(
    String notificationId,
  ) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$notificationId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete notification');
      }
    } catch (error) {
      print("Error deleting notification: $error");
      rethrow;
    }
  }

  // Marchează toate notificările unui utilizator ca citite
  static Future<Map<String, dynamic>> markAllNotificationsAsRead(
    String userId,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$userId/markAllRead'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (error) {
      print("Error marking all notifications as read: $error");
      rethrow;
    }
  }
}
