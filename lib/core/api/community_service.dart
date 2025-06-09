import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:zic_flutter/core/models/community.dart';

class CommunityService {
  static String? baseUrl = dotenv.env['BASE_URL'];
  static const storage = FlutterSecureStorage();

  // Helper method for auth headers
  static Future<Map<String, String>> _authHeaders() async {
    String? token = await storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    debugPrint('Token: $token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Create a new community
  static Future<Community?> createCommunity({
    required String name,
    required String description,
    bool onlyAdminsCanPost = false,
    bool allowAnonymousPosts = false,
    List<String> rules = const [],
    String bannerUrl = '',
    String bannerPublicId = '',
  }) async {
    final url = Uri.parse('$baseUrl/communities');
    try {
      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({
          'name': name,
          'description': description,
          'onlyAdminsCanPost': onlyAdminsCanPost,
          'allowAnonymousPosts': allowAnonymousPosts,
          'rules': rules,
          'bannerUrl': bannerUrl, // Optional, can be set later
          'bannerPublicId': bannerPublicId, // Optional, can be set later
        }),
      );

      if (response.statusCode == 201) {
        return Community.fromJson(jsonDecode(response.body));
      } else {
        throw HttpException(
          'Failed to create community: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint("Error creating community: $e");
      return null;
    }
  }

  // Get all communities with pagination
  static Future<List<Community>> getAllCommunities({
    int page = 1,
    int limit = 10,
  }) async {
    final url = Uri.parse('$baseUrl/communities?page=$page&limit=$limit');
    try {
      final response = await http.get(url, headers: await _authHeaders());
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Community.fromJson(json)).toList();
      }
      throw HttpException('Failed to load communities: ${response.statusCode}');
    } catch (e) {
      debugPrint("Error fetching communities: $e");
      return [];
    }
  }

  // Get community by ID
  static Future<Community?> getCommunityById(String id) async {
    final url = Uri.parse('$baseUrl/communities/$id');
    try {
      final response = await http.get(url, headers: await _authHeaders());
      if (response.statusCode == 200) {
        return Community.fromJson(jsonDecode(response.body));
      }
      throw HttpException('Community not found: ${response.statusCode}');
    } catch (e) {
      debugPrint("Error fetching community: $e");
      return null;
    }
  }

  // Update community
  static Future<Community?> updateCommunity({
    required String communityId,
    required String name,
    required String description,
    bool? onlyAdminsCanPost,
    bool? allowAnonymousPosts,
    List<String>? rules,
    String? bannerUrl,
    String? bannerPublicId,
  }) async {
    final url = Uri.parse('$baseUrl/communities/$communityId');
    try {
      final response = await http.put(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({
          'name': name,
          'description': description,
          'onlyAdminsCanPost': onlyAdminsCanPost,
          'allowAnonymousPosts': allowAnonymousPosts,
          'rules': rules,
          'bannerUrl': bannerUrl,
          'bannerPublicId': bannerPublicId,
        }),
      );

      if (response.statusCode == 200) {
        return Community.fromJson(jsonDecode(response.body));
      }
      throw HttpException('Failed to update: ${response.statusCode}');
    } catch (e) {
      debugPrint("Error updating community: $e");
      return null;
    }
  }

  // Delete community
  static Future<bool> deleteCommunity(String communityId) async {
    final url = Uri.parse('$baseUrl/communities/$communityId');
    try {
      final response = await http.delete(url, headers: await _authHeaders());
      return response.statusCode == 204; // Note the changed status code
    } catch (e) {
      debugPrint("Error deleting community: $e");
      return false;
    }
  }

  // Membership Operations
  static Future<bool> joinCommunity(String communityId) async {
    final url = Uri.parse('$baseUrl/communities/$communityId/members');
    try {
      final response = await http.post(url, headers: await _authHeaders());
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error joining community: $e");
      return false;
    }
  }

  static Future<bool> acceptJoinRequest({
    required String communityId,
    required String userId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/communities/$communityId/members/$userId/accept',
    );
    try {
      final response = await http.post(url, headers: await _authHeaders());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error accepting join request: $e");
      return false;
    }
  }

  static Future<bool> inviteUserToCommunity({
    required String communityId,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/communities/$communityId/invitations');
    try {
      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode({'userId': userId}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error inviting user: $e");
      return false;
    }
  }

  // Search communities
  static Future<List<Community>> searchCommunities(String query) async {
    final url = Uri.parse('$baseUrl/communities/search?q=${Uri.encodeQueryComponent(query)}');
    try {
      final response = await http.get(url, headers: await _authHeaders());
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Community.fromJson(json)).toList();
      }
      throw HttpException('Search failed: ${response.statusCode}');
    } catch (e) {
      debugPrint("Error searching communities: $e");
      return [];
    }
  }

  // Get user's communities
  static Future<List<Community>> getUserCommunities() async {
    final url = Uri.parse('$baseUrl/communities/user/me');
    try {
      final response = await http.get(url, headers: await _authHeaders());
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Community.fromJson(json)).toList();
      }
      throw HttpException('Failed to load user communities: ${response.statusCode}');
    } catch (e) {
      debugPrint("Error fetching user communities: $e");
      return [];
    }
  }
}