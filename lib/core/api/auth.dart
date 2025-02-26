import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String? baseUrl =
      dotenv.env['BASE_URL'];// ?? "http://192.168.0.102:8000"; // API URL

  // 🔹 Funcție pentru înregistrarea utilizatorului
  static Future<bool> registerUser(
    String fullname,
    String username,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullname": fullname,
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        String token = data["access_token"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        return true;
      } else {
        throw Exception(
          jsonDecode(response.body)["message"] ?? "Registration failed",
        );
      }
    } catch (e) {
      print("Error during registration: $e");
      return false;
    }
  }

  // 🔹 Funcție pentru autentificare (login)
  static Future<bool> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        String token = data["access_token"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        return true;
      } else {
        print("❌ Login failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error during login: $e");
      return false;
    }
  }

  // 🔹 Funcție pentru obținerea utilizatorului curent
  static Future<Map<String, dynamic>?> getCurrentUserFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      return null;
    }

    final url = Uri.parse('$baseUrl/auth/profile');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch user: ${response.body}");
      }
    } catch (e) {
      print("Error fetching current user: $e");
      return null;
    }
  }

  // 🔹 Funcție pentru delogare (șterge token-ul local)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<bool> isLoggedIn() async {
    var user = await getCurrentUserFromApi();
    return user != null; // Verificăm dacă user există
  }
}
