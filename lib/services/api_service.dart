import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/achievement_model.dart';
import '../config/config_url.dart';
import './api_exception.dart';
import '../models/auth_response.dart';
import '../models/user_profile.dart';
import '../models/game_score_data.dart';
import '../models/leaderboard_entry.dart';
import '../models/game_stats.dart';
import '../models/friend_request_data.dart';
import '../models/friend_data.dart';
import '../models/message_data.dart';
import '../models/conversation_data.dart';
import '../models/post_data.dart';
import '../models/comment_data.dart';
import '../models/sudoku_model.dart';
import '../models/puzzle_model.dart';

/// API Service để giao tiếp với Backend
class ApiService {
  // Base URL từ .env file
  static String get baseUrl => ConfigUrl.baseUrl;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // JWT Token storage
  String? _authToken;

  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null;

  /// Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Get headers with authentication
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// Centralized request helper to reduce boilerplate code.
  /// Handles HTTP requests, response parsing, and error handling.
  Future<T> _request<T>(
    String debugLabel, {
    required Future<http.Response> Function() request,
    required T Function(dynamic data) onSuccess,
    String? defaultErrorMessage,
  }) async {
    try {
      final response = await request();

      // Handle cases with no content but a successful status code (e.g., DELETE, or POSTs that don't return a body)
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Assuming onSuccess can handle a null for void returns
          return onSuccess(null);
        } else {
          throw ApiException(
            message: defaultErrorMessage ?? 'Request failed with empty response',
            statusCode: response.statusCode,
          );
        }
      }
      
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return onSuccess(data);
      } else {
        throw ApiException(
          message: data['message'] ?? data['error'] ?? defaultErrorMessage ?? 'An unknown error occurred',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('$debugLabel error: $e');
      if (e is ApiException) rethrow; // If it's already our custom exception, just rethrow
      // Otherwise, wrap it in a generic network error
      throw ApiException(message: 'Network error or parsing issue: ${e.toString()}');
    }
  }

  // ==================== AUTH ENDPOINTS ====================

  /// Register new user
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
  }) =>
      _request(
        'Register',
        request: () => http.post(
          Uri.parse('$baseUrl/api/auth/register'),
          headers: _headers,
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password,
          }),
        ),
        onSuccess: (data) {
          final authData = AuthResponse.fromJson(data['data']);
          setAuthToken(authData.token); // Save token
          return authData;
        },
        defaultErrorMessage: 'Registration failed',
      );

  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) =>
      _request(
        'Login',
        request: () => http.post(
          Uri.parse('$baseUrl/api/auth/login'),
          headers: _headers,
          body: jsonEncode({'email': email, 'password': password}),
        ),
        onSuccess: (data) {
          final authData = AuthResponse.fromJson(data['data']);
          setAuthToken(authData.token); // Save token
          return authData;
        },
        defaultErrorMessage: 'Login failed',
      );

  /// Get current user profile
  Future<UserProfile> getCurrentUser() => _request(
        'GetCurrentUser',
        request: () => http.get(
          Uri.parse('$baseUrl/api/auth/me'),
          headers: _headers,
        ),
        onSuccess: (data) => UserProfile.fromJson(data['data']['user']),
        defaultErrorMessage: 'Failed to get user',
      );

  /// Forgot Password - Send reset token
  Future<Map<String, dynamic>> forgotPassword({required String email}) =>
      _request(
        'ForgotPassword',
        request: () => http.post(
          Uri.parse('$baseUrl/api/auth/forgot-password'),
          headers: _headers,
          body: jsonEncode({'email': email}),
        ),
        onSuccess: (data) => (data['data'] as Map<String, dynamic>?) ?? {},
        defaultErrorMessage: 'Failed to send reset token',
      );

  /// Reset Password - With token
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) =>
      _request(
        'ResetPassword',
        request: () => http.post(
          Uri.parse('$baseUrl/api/auth/reset-password'),
          headers: _headers,
          body: jsonEncode({
            'email': email,
            'resetToken': token,
            'newPassword': newPassword,
          }),
        ),
        onSuccess: (_) {},
        defaultErrorMessage: 'Failed to reset password',
      );

  /// Update Profile - Username and Avatar
  Future<UserProfile> updateProfile({String? username, String? avatarUrl}) {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

    return _request(
      'UpdateProfile',
      request: () => http.put(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: _headers,
        body: jsonEncode(body),
      ),
      onSuccess: (data) => UserProfile.fromJson(data['data']['user']),
      defaultErrorMessage: 'Failed to update profile',
    );
  }

  /// Change Password - Requires current password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _request(
        'ChangePassword',
        request: () => http.post(
          Uri.parse('$baseUrl/api/auth/change-password'),
          headers: _headers,
          body: jsonEncode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        ),
        onSuccess: (_) {},
        defaultErrorMessage: 'Failed to change password',
      );

  // ==================== GAME SCORE ENDPOINTS ====================

  /// Save game score
  Future<GameScoreData> saveScore({
    required String gameType,
    required int score,
    required String difficulty,
    int attempts = 1,
    int timeSpent = 0,
    Map<String, dynamic>? gameData,
  }) =>
      _request(
        'SaveScore',
        request: () => http.post(
          Uri.parse('$baseUrl/api/scores'),
          headers: _headers,
          body: jsonEncode({
            'gameType': gameType,
            'score': score,
            'difficulty': difficulty,
            'attempts': attempts,
            'timeSpent': timeSpent,
            'gameData': gameData,
          }),
        ),
        onSuccess: (data) => GameScoreData.fromJson(data['data']['score']),
        defaultErrorMessage: 'Failed to save score',
      );

  /// Get user scores
  Future<List<GameScoreData>> getScores({
    String? gameType,
    String? difficulty,
    int limit = 50,
    int offset = 0,
  }) {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (gameType != null) queryParams['gameType'] = gameType;
    if (difficulty != null) queryParams['difficulty'] = difficulty;
    final uri = Uri.parse('$baseUrl/api/scores').replace(queryParameters: queryParams);

    return _request(
      'GetScores',
      request: () => http.get(uri, headers: _headers),
      onSuccess: (data) => (data['data']['scores'] as List)
          .map((json) => GameScoreData.fromJson(json))
          .toList(),
      defaultErrorMessage: 'Failed to get scores',
    );
  }

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({
    String gameType = 'all',
    String difficulty = 'all',
    int limit = 10,
  }) {
    final uri = Uri.parse('$baseUrl/api/scores/leaderboard').replace(
      queryParameters: {
        'gameType': gameType,
        'difficulty': difficulty,
        'limit': limit.toString(),
      },
    );

    return _request(
      'GetLeaderboard',
      request: () => http.get(uri, headers: _headers),
      onSuccess: (data) => (data['data']['leaderboard'] as List)
          .map((json) => LeaderboardEntry.fromJson(json))
          .toList(),
      defaultErrorMessage: 'Failed to get leaderboard',
    );
  }

  /// Get user statistics
  Future<List<GameStats>> getStats() => _request(
        'GetStats',
        request: () => http.get(
          Uri.parse('$baseUrl/api/scores/stats'),
          headers: _headers,
        ),
        onSuccess: (data) => (data['data']['stats'] as List)
            .map((json) => GameStats.fromJson(json))
            .toList(),
        defaultErrorMessage: 'Failed to get stats',
      );
}


// ==================== FRIEND API EXTENSIONS ====================
extension FriendAPI on ApiService {
  /// Search users by username/email
  Future<List<UserProfile>> searchUsers(String query) => _request(
        'SearchUsers',
        request: () => http.get(
          Uri.parse('${ApiService.baseUrl}/api/friends/search?q=$query'),
          headers: _headers,
        ),
        onSuccess: (data) =>
            (data['users'] as List).map((json) => UserProfile.fromJson(json)).toList(),
        defaultErrorMessage: 'Search failed',
      );

  /// Send friend request
  Future<FriendRequestData> sendFriendRequest({
    required String receiverId,
    String? message,
  }) =>
      _request(
        'SendFriendRequest',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/friends/request'),
          headers: _headers,
          body: jsonEncode({'receiverId': receiverId, 'message': message}),
        ),
        onSuccess: (data) => FriendRequestData.fromJson(data),
        defaultErrorMessage: 'Failed to send request',
      );

  /// Get pending friend requests
  Future<List<FriendRequestData>> getFriendRequests() => _request(
        'GetFriendRequests',
        request: () => http.get(
          Uri.parse('${ApiService.baseUrl}/api/friends/requests'),
          headers: _headers,
        ),
        onSuccess: (data) => (data['requests'] as List)
            .map((json) => FriendRequestData.fromJson(json))
            .toList(),
        defaultErrorMessage: 'Failed to get requests',
      );

  /// Accept friend request
  Future<void> acceptFriendRequest(String requestId) => _request(
        'AcceptFriendRequest',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/friends/accept/$requestId'),
          headers: _headers,
        ),
        onSuccess: (_) {},
        defaultErrorMessage: 'Failed to accept request',
      );

  /// Reject friend request
  Future<void> rejectFriendRequest(String requestId) => _request(
        'RejectFriendRequest',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/friends/reject/$requestId'),
          headers: _headers,
        ),
        onSuccess: (_) {},
        defaultErrorMessage: 'Failed to reject request',
      );

  /// Get friends list
  Future<List<FriendData>> getFriends() => _request(
        'GetFriends',
        request: () => http.get(
          Uri.parse('${ApiService.baseUrl}/api/friends'),
          headers: _headers,
        ),
        onSuccess: (data) =>
            (data['friends'] as List).map((json) => FriendData.fromJson(json)).toList(),
        defaultErrorMessage: 'Failed to get friends',
      );
}

// ==================== MESSAGE API EXTENSIONS ====================
extension MessageAPI on ApiService {
  /// Send message to friend
  Future<MessageData> sendMessage({
    required String receiverId,
    required String content,
    String type = 'text',
  }) =>
      _request(
        'SendMessage',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/messages'),
          headers: _headers,
          body: jsonEncode({
            'receiverId': receiverId,
            'content': content,
            'type': type,
          }),
        ),
        onSuccess: (data) => MessageData.fromJson(data),
        defaultErrorMessage: 'Failed to send message',
      );

  /// Get chat history with a user
  Future<List<MessageData>> getChatHistory({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) =>
      _request(
        'GetChatHistory',
        request: () => http.get(
          Uri.parse(
            '${ApiService.baseUrl}/api/messages/$userId?limit=$limit&offset=$offset',
          ),
          headers: _headers,
        ),
        onSuccess: (data) =>
            (data['messages'] as List).map((json) => MessageData.fromJson(json)).toList(),
        defaultErrorMessage: 'Failed to get messages',
      );

  /// Get conversations list
  Future<List<ConversationData>> getConversations() => _request(
        'GetConversations',
        request: () => http.get(
          Uri.parse('${ApiService.baseUrl}/api/messages/conversations/list'),
          headers: _headers,
        ),
        onSuccess: (data) => (data['conversations'] as List)
            .map((json) => ConversationData.fromJson(json))
            .toList(),
        defaultErrorMessage: 'Failed to get conversations',
      );
}


extension SudokuAPI on ApiService {
  Future<SudokuGame> generateSudoku({
    required String difficulty, // 'easy', 'medium', 'hard'
  }) =>
      _request(
        'GenerateSudoku',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/sudoku/generate'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }, 
          body: jsonEncode({'difficulty': difficulty}),
        ),
        onSuccess: (data) => SudokuGame.fromJson(data['data']),
        defaultErrorMessage: 'Failed to generate Sudoku',
      );

  /// Validate Sudoku solution
  Future<Map<String, dynamic>> validateSudoku({
    required List<int> currentState,
    required List<int> solution,
  }) =>
      _request(
        'ValidateSudoku',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/sudoku/validate'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'currentState': currentState,
            'solution': solution,
          }),
        ),
        onSuccess: (data) => data['data'] as Map<String, dynamic>,
        defaultErrorMessage: 'Failed to validate Sudoku',
      );

  /// Get hint for next move
  Future<Map<String, dynamic>> getSudokuHint({
    required List<int> currentState,
    required List<int> solution,
  }) =>
      _request(
        'GetSudokuHint',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/sudoku/hint'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'currentState': currentState,
            'solution': solution,
          }),
        ),
        onSuccess: (data) => data['data'] as Map<String, dynamic>,
        defaultErrorMessage: 'Failed to get hint',
      );

  /// Calculate score (optional - có thể tính ở FE hoặc BE)
  Future<int> calculateSudokuScore({
    required String difficulty,
    required int timeInSeconds,
    required int hintsUsed,
    required int mistakes,
  }) =>
      _request(
        'CalculateSudokuScore',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/sudoku/calculate-score'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'difficulty': difficulty,
            'timeInSeconds': timeInSeconds,
            'hintsUsed': hintsUsed,
            'mistakes': mistakes,
          }),
        ),
        onSuccess: (data) => data['data']['score'] as int,
        defaultErrorMessage: 'Failed to calculate score',
      );
}

// ==================== PUZZLE API EXTENSION ====================
extension PuzzleAPI on ApiService {
  /// Generate Puzzle Game
  Future<PuzzleGame> generatePuzzle({
    required String difficulty,
    required int gridSize,
  }) async {
    try {
      debugPrint('🎮 Generating puzzle: difficulty=$difficulty, gridSize=$gridSize');
      debugPrint('🌐 Request URL: ${ApiService.baseUrl}/puzzle/generate');
      
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/puzzle/generate'), // Không có /api
        headers: _headers,
        body: jsonEncode({
          'difficulty': difficulty,
          'gridSize': gridSize,
        }),
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final game = PuzzleGame.fromJson(data['puzzle']);
        debugPrint('✅ Game generated successfully!');
        debugPrint('📷 Image URL: ${game.imageUrl}');
        debugPrint('🧩 First tile: ${game.tilePaths.isNotEmpty ? game.tilePaths[0] : "none"}');
        return game;
      } else {
        throw Exception('Failed to generate puzzle: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error generating puzzle: $e');
      throw Exception('Error generating puzzle: $e');
    }
  }

  /// Calculate Puzzle Score
  Future<int> calculatePuzzleScore({
    required String difficulty,
    required int timeInSeconds,
    required int moves,
    required int gridSize,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/puzzle/calculate-score'), // Không có /api
        headers: _headers,
        body: jsonEncode({
          'difficulty': difficulty,
          'timeInSeconds': timeInSeconds,
          'moves': moves,
          'gridSize': gridSize,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['score'] as int;
      } else {
        throw Exception('Failed to calculate score: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calculating score: $e');
    }
  }
}

// ============ POSTS API EXTENSION ============

extension PostsAPI on ApiService {
  /// Centralized helper for multipart requests to reduce boilerplate.
  Future<T> _multipartRequest<T>(
    String debugLabel, {
    required http.MultipartRequest request,
    required T Function(dynamic data) onSuccess,
    String? defaultErrorMessage,
  }) async {
    try {
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return onSuccess(data);
      } else {
        throw ApiException(
          message: data['message'] ?? data['error'] ?? defaultErrorMessage ?? 'An unknown error occurred',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('$debugLabel error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error or parsing issue: ${e.toString()}');
    }
  }


  /// Create a new post
  Future<PostData> createPost({
    required String content,
    String? imageUrl,
    String visibility = 'public',
    String? category,
  }) =>
      _request(
        'CreatePost',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/posts'),
          headers: _headers,
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

  /// Upload image file
  Future<String> uploadImage(String filePath) async {
    final request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/api/upload'));
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    return _multipartRequest(
      'UploadImage',
      request: request,
      onSuccess: (data) => data['imageUrl'],
      defaultErrorMessage: 'Failed to upload image',
    );
  }

  /// Get posts feed (all or filtered by userId, category, or search)
  Future<List<PostData>> getPosts({
    int limit = 20,
    int offset = 0,
    String? userId,
    String? category,
    String? search,
  }) {
    var url = '${ApiService.baseUrl}/api/posts?limit=$limit&offset=$offset';
    if (userId != null) {
      url += '&userId=$userId';
    }
    if (category != null && category.isNotEmpty) {
      url += '&category=$category';
    }
    if (search != null && search.isNotEmpty) {
      url += '&search=${Uri.encodeComponent(search)}';
    }

    return _request(
      'GetPosts',
      request: () => http.get(Uri.parse(url), headers: _headers),
      onSuccess: (data) =>
          (data['posts'] as List).map((post) => PostData.fromJson(post)).toList(),
      defaultErrorMessage: 'Failed to get posts',
    );
  }

  /// Get single post with comments
  Future<PostData> getPost(String postId) => _request(
        'GetPost',
        request: () => http.get(Uri.parse('${ApiService.baseUrl}/api/posts/$postId'), headers: _headers),
        onSuccess: (data) => PostData.fromJson(data),
        defaultErrorMessage: 'Failed to get post',
      );

  /// Update post (owner only)
  Future<PostData> updatePost({
    required String postId,
    required String content,
    String? imageUrl,
    String? visibility,
    String? category,
  }) =>
      _request(
        'UpdatePost',
        request: () => http.put(
          Uri.parse('${ApiService.baseUrl}/api/posts/$postId'),
          headers: _headers,
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

  /// Delete post (owner only)
  Future<void> deletePost(String postId) => _request(
        'DeletePost',
        request: () => http.delete(Uri.parse('${ApiService.baseUrl}/api/posts/$postId'), headers: _headers),
        onSuccess: (_) {},
        defaultErrorMessage: 'Failed to delete post',
      );

  /// Toggle like on post
  Future<Map<String, dynamic>> toggleLike(String postId) => _request(
        'ToggleLike',
        request: () => http.post(Uri.parse('${ApiService.baseUrl}/api/posts/$postId/like'), headers: _headers),
        onSuccess: (data) => data as Map<String, dynamic>,
        defaultErrorMessage: 'Failed to toggle like',
      );

  /// Add comment to post
  Future<CommentData> addComment({
    required String postId,
    required String content,
  }) =>
      _request(
        'AddComment',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/posts/$postId/comments'),
          headers: _headers,
          body: jsonEncode({'content': content}),
        ),
        onSuccess: (data) => CommentData.fromJson(data),
        defaultErrorMessage: 'Failed to add comment',
      );

  /// Toggle save post to favorites
  Future<Map<String, dynamic>> toggleSavePost(String postId) => _request(
        'ToggleSavePost',
        request: () => http.post(Uri.parse('${ApiService.baseUrl}/api/posts/$postId/save'), headers: _headers),
        onSuccess: (data) => data as Map<String, dynamic>,
        defaultErrorMessage: 'Failed to toggle save',
      );

  /// Get saved posts
  Future<List<PostData>> getSavedPosts() => _request(
        'GetSavedPosts',
        request: () => http.get(
          Uri.parse('${ApiService.baseUrl}/api/posts/saved/list'),
          headers: _headers,
        ),
        onSuccess: (data) =>
            (data['posts'] as List).map((post) => PostData.fromJson(post)).toList(),
        defaultErrorMessage: 'Failed to get saved posts',
      );

  /// Toggle follow user
  Future<Map<String, dynamic>> toggleFollow(String targetUserId) => _request(
        'ToggleFollow',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/posts/follow/$targetUserId'),
          headers: _headers,
        ),
        onSuccess: (data) => data as Map<String, dynamic>,
        defaultErrorMessage: 'Failed to toggle follow',
      );

  /// Share post (increment share count)
  Future<void> sharePost(String postId) => _request(
        'SharePost',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/posts/$postId/share'),
          headers: _headers,
        ),
        onSuccess: (_) {}, // Success case is void
        defaultErrorMessage: 'Failed to share post',
      );

  // ==================== ACHIEVEMENT ENDPOINTS ====================

  /// Get user achievements
  Future<List<dynamic>> getUserAchievements(int userId) => _request(
        'GetUserAchievements',
        request: () => http.get(
          Uri.parse('${ApiService.baseUrl}/api/users/$userId/achievements'),
          headers: _headers,
        ),
        onSuccess: (data) => data['achievements'] ?? [],
        defaultErrorMessage: 'Failed to get user achievements',
      );

  /// Get achievement stats
  Future<Map<String, dynamic>> getAchievementStats(int userId) => _request(
        'GetAchievementStats',
        request: () => http.get(
          Uri.parse('${ApiService.baseUrl}/api/users/$userId/achievements/stats'),
          headers: _headers,
        ),
        onSuccess: (data) => data as Map<String, dynamic>,
        defaultErrorMessage: 'Failed to get achievement stats',
      );

  /// Check achievements
  Future<List<dynamic>> checkAchievements(int userId) => _request(
        'CheckAchievements',
        request: () => http.post(
          Uri.parse('${ApiService.baseUrl}/api/users/$userId/achievements/check'),
          headers: _headers,
        ),
        onSuccess: (data) => data['newAchievements'] ?? [],
        defaultErrorMessage: 'Failed to check achievements',
      );

  /// Get all achievements (optionally filtered by category)
  /// GET /api/achievements?category=general|games|social|milestone
  Future<List<AchievementData>> getAllAchievements({
    String? category,
  }) {
    final Map<String, String> queryParams = {};
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    final uri = Uri.parse('${ApiService.baseUrl}/api/achievements')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    
    return _request(
        'GetAllAchievements',
        request: () => http.get(uri, headers: _headers),
        onSuccess: (data) => (data['data']['achievements'] as List)
            .map((json) => AchievementData.fromJson(json))
            .toList(),
        defaultErrorMessage: 'Failed to get achievements',
      );
  }
}

