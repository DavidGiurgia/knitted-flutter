import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RecentSearchService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://192.168.0.103:8000";

  // Obține căutările recente
  static Future<List<String>> fetchRecentSearches(String userId) async {
    final url = Uri.parse('$baseUrl/recent-searches/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body));
      }
    } catch (e) {
      print("Error fetching recent searches: $e");
    }
    return [];
  }

  // Adaugă un utilizator în căutările recente
  static Future<void> addRecentSearch(
    String userId,
    String recentUserId,
  ) async {
    final url = Uri.parse('$baseUrl/recent-searches/$userId');

    try {
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"recentUserId": recentUserId}),
      );
    } catch (e) {
      print("Error adding recent search: $e");
    }
  }

  // Șterge un utilizator din căutările recente
  static Future<void> removeRecentSearch(
    String userId,
    String recentUserId,
  ) async {
    final url = Uri.parse('$baseUrl/recent-searches/$userId');

    try {
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"recentUserId": recentUserId}),
      );
    } catch (e) {
      print("Error removing recent search: $e");
    }
  }

  // Șterge toate căutările recente
  static Future<void> clearRecentSearches(String userId) async {
    final url = Uri.parse('$baseUrl/recent-searches/$userId');

    try {
      await http.delete(url);
    } catch (e) {
      print("Error clearing recent searches: $e");
    }
  }
}
