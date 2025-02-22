import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zic_flutter/core/models/user.dart';

class UserService {
  static String? baseUrl = dotenv.env['BASE_URL'];

  // Obține un utilizator după ID
  static Future<User?> fetchUserById(String id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }

  static Future<List<User>> searchUser(String searchText, String userId) async {
  final url = Uri.parse('$baseUrl/users/search/$searchText?userId=$userId');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
  } catch (e) {
    print("Error searching users: $e");
  }
  return [];
}

}
