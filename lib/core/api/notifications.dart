import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zic_flutter/core/models/notification.dart';

class NotificationService {
  static String apiUrl = dotenv.env['BASE_URL'] ?? "http://192.168.0.103:8000";
  static final String baseUrl = "$apiUrl/notifications";

  static Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed with status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createNotification(String senderId, String receiverId, String type, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
          'type': type,
          'data': data,
        }),
      ).timeout(const Duration(seconds: 10)); // Adăugare timeout
      return _handleResponse(response);
    } catch (error) {
      print("Error creating notification: $error");
      rethrow;
    }
  }

  static Future<List<NotificationModel>> fetchNotifications(String userId, {bool unreadOnly = false}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$userId?unreadOnly=$unreadOnly')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch notifications. Status Code: ${response.statusCode}, body: ${response.body}');
      }
    } catch (error) {
      print("Error fetching notifications: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    try {
      final response = await http.patch(Uri.parse('$baseUrl/$notificationId/read')).timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (error) {
      print("Error marking notification as read: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$notificationId')).timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (error) {
      print("Error deleting notification: $error");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead(String userId) async {
    try {
      final response = await http.patch(Uri.parse('$baseUrl/$userId/markAllRead')).timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (error) {
      print("Error marking all notifications as read: $error");
      rethrow;
    }
  }
}