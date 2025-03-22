import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zic_flutter/core/models/link.dart';
import 'package:zic_flutter/core/models/media_post.dart';
import 'package:zic_flutter/core/models/poll.dart';
import 'package:zic_flutter/core/models/post.dart';

class PostService {
  static final String baseUrl = '${dotenv.env['BASE_URL']}/post';

  // Creare postare
  Future<Post> createPost(Post post) async {
    final url = Uri.parse('$baseUrl/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );

      if (response.statusCode >= 200 || response.statusCode < 300) {
        if (response.body.isEmpty) {
          throw Exception("Empty response from server");
        }
        final data = json.decode(response.body);
        return _postFromJson(
          data,
        ); // În funcție de tipul postării, poți crea o instanță specifică
      } else {
        throw Exception('Failed to create post (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Obține un post
  Future<Post> getPost(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _postFromJson(data);
      } else {
        throw Exception('Failed to load post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load post: $e');
    }
  }

  // Actualizează un post
  Future<Post> updatePost(String id, Post post) async {
    final url = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Post.fromJson(data);
      } else {
        throw Exception('Failed to update post');
      }
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // Șterge un post
  Future<void> deletePost(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  Post _postFromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString().toLowerCase().trim();
    if (type == null || !postTypeMap.containsKey(type)) {
      throw Exception('Invalid post type: $type'); // Or throw an exception
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
