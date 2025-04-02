import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  static String? baseUrl = dotenv.env['BASE_URL'];

  static Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // 🔹 Funcție pentru înregistrarea utilizatorului
  static Future<bool> registerUser(
    String fullname,
    String username,
    String email,
    String password,
  ) async {
    if (!await checkInternetConnection()) {
      print('No internet connection');
      return false;
    }
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

        const storage = FlutterSecureStorage();
        await storage.write(key: 'auth_token', value: token);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 🔹 Funcție pentru autentificare (login)
  static Future<bool> loginUser(String email, String password) async {
    if (!await checkInternetConnection()) {
      print('No internet connection');
      return false;
    }
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data.containsKey("access_token")) {
          String token = data["access_token"];
          const storage = FlutterSecureStorage();
          await storage.write(key: 'auth_token', value: token);
          return true;
        } else {
          print('No access token found in response');
          return false;
        }
      } else {
        print('Login failed with status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 🔹 Funcție pentru obținerea utilizatorului curent
  static Future<Map<String, dynamic>?> getCurrentUserFromApi() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');

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
      } else if (response.statusCode == 401) {
        await logout(); // Șterge token-ul invalid
        return null;
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
    const storage = FlutterSecureStorage();
    await storage.delete(
      key: 'auth_token',
    ); // Șterge token-ul din secure storage
  }

  static Future<bool> isLoggedIn() async {
    var user = await getCurrentUserFromApi();
    return user != null;
  }
}
