import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_data.dart';
import '../models/comment_data.dart';
import '../exceptions/api_exception.dart';
import 'api_client.dart';

class PostService {
  final ApiClient apiClient;
  PostService(this.apiClient);

  Future<PostData> createPost({
    required String content,
    String? imageUrl,
    String visibility = 'public',
    String? category,
  }) => apiClient.request(
    'CreatePost',
    httpRequest: () => http.post(
      Uri.parse('${ApiClient.baseUrl}/api/posts'),
      headers: apiClient.headers,
      body: jsonEncode({
        'content': content,
        'imageUrl': imageUrl,
        'visibility': visibility,
        'category': category,
      }),
    ),
    onSuccess: (data) => PostData.fromJson(data),
    defaultErrorMessage: 'Failed to create post',
  );

  Future<String> uploadImage(String filePath) =>
      apiClient.uploadImage(filePath);

  Future<List<PostData>> getPosts({
    int limit = 20,
    int offset = 0,
    String? userId,
    String? category,
    String? search,
  }) {
    var url = '${ApiClient.baseUrl}/api/posts?limit=$limit&offset=$offset';
    if (userId != null) {
      url += '&userId=$userId';
    }
    if (category != null && category.isNotEmpty) {
      url += '&category=$category';
    }
    if (search != null && search.isNotEmpty) {
      url += '&search=${Uri.encodeComponent(search)}';
    }
    return apiClient.request(
      'GetPosts',
      httpRequest: () => http.get(Uri.parse(url), headers: apiClient.headers),
      onSuccess: (data) => (data['posts'] as List)
          .map((post) => PostData.fromJson(post))
          .toList(),
      defaultErrorMessage: 'Failed to get posts',
    );
  }

  Future<PostData> getPost(String postId) => apiClient.request(
    'GetPost',
    httpRequest: () => http.get(
      Uri.parse('${ApiClient.baseUrl}/api/posts/$postId'),
      headers: apiClient.headers,
    ),
    onSuccess: (data) => PostData.fromJson(data),
    defaultErrorMessage: 'Failed to get post',
  );

  Future<PostData> updatePost({
    required String postId,
    required String content,
    String? imageUrl,
    String? visibility,
    String? category,
  }) => apiClient.request(
    'UpdatePost',
    httpRequest: () => http.put(
      Uri.parse('${ApiClient.baseUrl}/api/posts/$postId'),
      headers: apiClient.headers,
      body: jsonEncode({
        'content': content,
        'imageUrl': imageUrl,
        'visibility': visibility,
        'category': category,
      }),
    ),
    onSuccess: (data) => PostData.fromJson(data),
    defaultErrorMessage: 'Failed to update post',
  );

  Future<void> deletePost(String postId) => apiClient.request(
    'DeletePost',
    httpRequest: () => http.delete(
      Uri.parse('${ApiClient.baseUrl}/api/posts/$postId'),
      headers: apiClient.headers,
    ),
    onSuccess: (_) {},
    defaultErrorMessage: 'Failed to delete post',
  );

  Future<Map<String, dynamic>> toggleLike(String postId) => apiClient.request(
    'ToggleLike',
    httpRequest: () => http.post(
      Uri.parse('${ApiClient.baseUrl}/api/posts/$postId/like'),
      headers: apiClient.headers,
    ),
    onSuccess: (data) => data as Map<String, dynamic>,
    defaultErrorMessage: 'Failed to toggle like',
  );

  Future<CommentData> addComment({
    required String postId,
    required String content,
  }) => apiClient.request(
    'AddComment',
    httpRequest: () => http.post(
      Uri.parse('${ApiClient.baseUrl}/api/posts/$postId/comments'),
      headers: apiClient.headers,
      body: jsonEncode({'content': content}),
    ),
    onSuccess: (data) => CommentData.fromJson(data),
    defaultErrorMessage: 'Failed to add comment',
  );

  Future<Map<String, dynamic>> toggleSavePost(String postId) =>
      apiClient.request(
        'ToggleSavePost',
        httpRequest: () => http.post(
          Uri.parse('${ApiClient.baseUrl}/api/posts/$postId/save'),
          headers: apiClient.headers,
        ),
        onSuccess: (data) => data as Map<String, dynamic>,
        defaultErrorMessage: 'Failed to toggle save',
      );

  Future<List<PostData>> getSavedPosts() => apiClient.request(
    'GetSavedPosts',
    httpRequest: () => http.get(
      Uri.parse('${ApiClient.baseUrl}/api/posts/saved/list'),
      headers: apiClient.headers,
    ),
    onSuccess: (data) =>
        (data['posts'] as List).map((post) => PostData.fromJson(post)).toList(),
    defaultErrorMessage: 'Failed to get saved posts',
  );

  Future<Map<String, dynamic>> toggleFollow(String targetUserId) =>
      apiClient.request(
        'ToggleFollow',
        httpRequest: () => http.post(
          Uri.parse('${ApiClient.baseUrl}/api/posts/follow/$targetUserId'),
          headers: apiClient.headers,
        ),
        onSuccess: (data) => data as Map<String, dynamic>,
        defaultErrorMessage: 'Failed to toggle follow',
      );

  Future<void> sharePost(String postId) => apiClient.request(
    'SharePost',
    httpRequest: () => http.post(
      Uri.parse('${ApiClient.baseUrl}/api/posts/$postId/share'),
      headers: apiClient.headers,
    ),
    onSuccess: (_) {},
    defaultErrorMessage: 'Failed to share post',
  );
}
