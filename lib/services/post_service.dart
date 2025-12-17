import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/post_model.dart';

/// Service để quản lý API calls cho Posts
class PostService {
  // TODO: Thay đổi base URL này thành URL backend thật của bạn
  static const String baseUrl = 'YOUR_API_URL_HERE/api/posts';

  /// Lấy tất cả posts
  static Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Post.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      rethrow;
    }
  }

  /// Lấy post theo ID
  static Future<Post> getPostById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load post: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching post by ID: $e');
      rethrow;
    }
  }

  /// Tìm kiếm posts theo content
  static Future<List<Post>> searchPosts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Post.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search posts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching posts: $e');
      rethrow;
    }
  }

  /// Tạo post mới
  static Future<Post> createPost(Post post) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  /// Cập nhật post
  static Future<Post> updatePost(int id, Post post) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update post: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating post: $e');
      rethrow;
    }
  }

  /// Xóa post
  static Future<void> deletePost(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete post: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  /// Like/Unlike post (bonus feature)
  static Future<Post> toggleLike(int id) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/$id/like'));

      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to toggle like: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }
}
