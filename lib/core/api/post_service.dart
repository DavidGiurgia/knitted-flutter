import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zic_flutter/core/models/link.dart';
import 'package:zic_flutter/core/models/media_post.dart';
import 'package:zic_flutter/core/models/poll.dart';
import 'package:zic_flutter/core/models/post.dart';

class PostService {
  static String? baseUrl = dotenv.env['BASE_URL'];
  static const storage = FlutterSecureStorage();

  // Helper method for auth headers
  static Future<Map<String, String>> _authHeaders() async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle API responses
  static dynamic _handleResponse(http.Response response) {
    final responseBody = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody['data']; // Return the data part of successful responses
    } else {
      final errorMessage = responseBody['message'] ?? 'Request failed with status ${response.statusCode}';
      throw Exception(errorMessage);
    }
  }

  // Create post
  static Future<Post> createPost(Post post) async {
    final url = Uri.parse('$baseUrl/posts');
    try {
      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: json.encode(post.toCreateJson()),
      );
      final responseData = _handleResponse(response);
      return _postFromJson(responseData);
    } catch (e) {
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  static Future<List<Post>> getUserPosts() async {
    final url = Uri.parse('$baseUrl/posts/feed');
    try {
      final response = await http.get(url, headers: await _authHeaders());
      final responseData = _handleResponse(response) as List<dynamic>;
      return responseData.map((postJson) => _postFromJson(postJson)).toList();
    } catch (e) {
      throw Exception('Failed to load user posts: ${e.toString()}');
    }
  }

  static Future<List<Post>> getCreatorPosts(String userId) async {
    final url = Uri.parse('$baseUrl/posts/creator/$userId');
    try {
      final response = await http.get(url, headers: await _authHeaders());
      final responseData = _handleResponse(response) as List<dynamic>;
      return responseData.map((postJson) => _postFromJson(postJson)).toList();
    } catch (e) {
      throw Exception('Failed to load creator posts: ${e.toString()}');
    }
  }

  static Future<List<Post>> getPostReplies(String postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId/replies');
    try {
      final response = await http.get(url, headers: await _authHeaders());
      final responseData = _handleResponse(response) as List<dynamic>;
      return responseData.map((postJson) => _postFromJson(postJson)).toList();
    } catch (e) {
      throw Exception('Failed to load post replies: ${e.toString()}');
    }
  }

  static Future<List<Post>> getCommunityPosts(String communityId) async {
    final url = Uri.parse('$baseUrl/posts/community/$communityId');
    try {
      final response = await http.get(url, headers: await _authHeaders());
      final responseData = _handleResponse(response) as List<dynamic>;
      return responseData.map((postJson) => _postFromJson(postJson)).toList();
    } catch (e) {
      throw Exception('Failed to load community posts: ${e.toString()}');
    }
  }

  static Future<Post> getPostById(String id) async {
    final url = Uri.parse('$baseUrl/posts/$id');
    try {
      final response = await http.get(url, headers: await _authHeaders());
      final responseData = _handleResponse(response);
      return _postFromJson(responseData);
    } catch (e) {
      throw Exception('Failed to load post: ${e.toString()}');
    }
  }

  static Future<Post> revealIdentity(String id) async {
    final url = Uri.parse('$baseUrl/posts/$id/reveal');
    try {
      final response = await http.patch(url, headers: await _authHeaders());
      final responseData = _handleResponse(response);
      return _postFromJson(responseData);
    } catch (e) {
      throw Exception('Failed to reveal identity: ${e.toString()}');
    }
  }

  static Future<Post> updatePost(String id, Post post) async {
    final url = Uri.parse('$baseUrl/posts/$id');
    try {
      final response = await http.put(
        url,
        headers: await _authHeaders(),
        body: json.encode(post.toJson()),
      );
      final responseData = _handleResponse(response);
      return _postFromJson(responseData);
    } catch (e) {
      throw Exception('Failed to update post: ${e.toString()}');
    }
  }

  static Future<void> deletePost(String id) async {
    final url = Uri.parse('$baseUrl/posts/$id');
    try {
      final response = await http.delete(url, headers: await _authHeaders());
      _handleResponse(response); // Will throw if not successful
    } catch (e) {
      throw Exception('Failed to delete post: ${e.toString()}');
    }
  }

  static Post _postFromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString().toLowerCase().trim();
    if (type == null || !postTypeMap.containsKey(type)) {
      throw Exception('Invalid post type: $type');
    }
    switch (postTypeMap[type]) {
      case PostType.link:
        return LinkPost.fromJson(json);
      case PostType.poll:
        return PollPost.fromJson(json);
      case PostType.media:
        return MediaPost.fromJson(json);
      default:
        return Post.fromJson(json);
    }
  }
}