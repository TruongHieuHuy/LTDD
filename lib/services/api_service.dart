import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// API Service để giao tiếp với Backend
class ApiService {
  // Base URL - Thay đổi theo platform
  // Android Emulator: 10.0.2.2 (đại diện cho localhost của host machine)
  // iOS Simulator: localhost
  // Physical Device: Dùng IP thật của máy (ví dụ: 192.168.1.100)
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000'
      : 'http://10.0.2.2:3000';

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

  // ==================== AUTH ENDPOINTS ====================

  /// Register new user
  /// POST /api/auth/register
  Future<ApiResponse<AuthResponse>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final authData = AuthResponse.fromJson(data['data']);
        _authToken = authData.token; // Save token

        return ApiResponse<AuthResponse>(
          success: true,
          data: authData,
          message: data['message'],
        );
      } else {
        return ApiResponse<AuthResponse>(
          success: false,
          message: data['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      debugPrint('Register error: $e');
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Login user
  /// POST /api/auth/login
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authData = AuthResponse.fromJson(data['data']);
        _authToken = authData.token; // Save token

        return ApiResponse<AuthResponse>(
          success: true,
          data: authData,
          message: data['message'],
        );
      } else {
        return ApiResponse<AuthResponse>(
          success: false,
          message: data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get current user profile
  /// GET /api/auth/me
  Future<ApiResponse<UserProfile>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = UserProfile.fromJson(data['data']['user']);

        return ApiResponse<UserProfile>(success: true, data: user);
      } else {
        return ApiResponse<UserProfile>(
          success: false,
          message: data['message'] ?? 'Failed to get user',
        );
      }
    } catch (e) {
      debugPrint('Get user error: $e');
      return ApiResponse<UserProfile>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ==================== GAME SCORE ENDPOINTS ====================

  /// Save game score
  /// POST /api/scores
  Future<ApiResponse<GameScoreData>> saveScore({
    required String gameType,
    required int score,
    required String difficulty,
    int attempts = 1,
    int timeSpent = 0,
    Map<String, dynamic>? gameData,
  }) async {
    try {
      final response = await http.post(
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
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final scoreData = GameScoreData.fromJson(data['data']['score']);

        return ApiResponse<GameScoreData>(
          success: true,
          data: scoreData,
          message: data['message'],
        );
      } else {
        return ApiResponse<GameScoreData>(
          success: false,
          message: data['message'] ?? 'Failed to save score',
        );
      }
    } catch (e) {
      debugPrint('Save score error: $e');
      return ApiResponse<GameScoreData>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get user scores
  /// GET /api/scores?gameType=sudoku&limit=20
  Future<ApiResponse<List<GameScoreData>>> getScores({
    String? gameType,
    String? difficulty,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (gameType != null) queryParams['gameType'] = gameType;
      if (difficulty != null) queryParams['difficulty'] = difficulty;

      final uri = Uri.parse(
        '$baseUrl/api/scores',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final scores = (data['data']['scores'] as List)
            .map((json) => GameScoreData.fromJson(json))
            .toList();

        return ApiResponse<List<GameScoreData>>(success: true, data: scores);
      } else {
        return ApiResponse<List<GameScoreData>>(
          success: false,
          message: data['message'] ?? 'Failed to get scores',
        );
      }
    } catch (e) {
      debugPrint('Get scores error: $e');
      return ApiResponse<List<GameScoreData>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get leaderboard
  /// GET /api/scores/leaderboard?gameType=all&limit=10
  Future<ApiResponse<List<LeaderboardEntry>>> getLeaderboard({
    String gameType = 'all',
    String difficulty = 'all',
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/scores/leaderboard').replace(
        queryParameters: {
          'gameType': gameType,
          'difficulty': difficulty,
          'limit': limit.toString(),
        },
      );

      final response = await http.get(uri, headers: _headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final leaderboard = (data['data']['leaderboard'] as List)
            .map((json) => LeaderboardEntry.fromJson(json))
            .toList();

        return ApiResponse<List<LeaderboardEntry>>(
          success: true,
          data: leaderboard,
        );
      } else {
        return ApiResponse<List<LeaderboardEntry>>(
          success: false,
          message: data['message'] ?? 'Failed to get leaderboard',
        );
      }
    } catch (e) {
      debugPrint('Get leaderboard error: $e');
      return ApiResponse<List<LeaderboardEntry>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get user statistics
  /// GET /api/scores/stats
  Future<ApiResponse<List<GameStats>>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/scores/stats'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final stats = (data['data']['stats'] as List)
            .map((json) => GameStats.fromJson(json))
            .toList();

        return ApiResponse<List<GameStats>>(success: true, data: stats);
      } else {
        return ApiResponse<List<GameStats>>(
          success: false,
          message: data['message'] ?? 'Failed to get stats',
        );
      }
    } catch (e) {
      debugPrint('Get stats error: $e');
      return ApiResponse<List<GameStats>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}

// ==================== RESPONSE MODELS ====================

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({required this.success, this.data, this.message});
}

/// Auth response after login/register
class AuthResponse {
  final UserProfile user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserProfile.fromJson(json['user']),
      token: json['token'],
    );
  }
}

/// User profile data
class UserProfile {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final int totalGamesPlayed;
  final int totalScore;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.totalGamesPlayed = 0,
    this.totalScore = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try {
      return UserProfile(
        id: (json['id'] ?? '').toString(),
        username: json['username']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        avatarUrl: json['avatarUrl']?.toString(),
        totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
        totalScore: json['totalScore'] ?? 0,
      );
    } catch (e) {
      print('Error parsing UserProfile: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
    };
  }
}

/// Game score data
class GameScoreData {
  final String id;
  final String gameType;
  final int score;
  final int attempts;
  final String difficulty;
  final int timeSpent;
  final Map<String, dynamic>? gameData;
  final DateTime createdAt;

  GameScoreData({
    required this.id,
    required this.gameType,
    required this.score,
    required this.attempts,
    required this.difficulty,
    required this.timeSpent,
    this.gameData,
    required this.createdAt,
  });

  factory GameScoreData.fromJson(Map<String, dynamic> json) {
    return GameScoreData(
      id: json['id'],
      gameType: json['gameType'],
      score: json['score'],
      attempts: json['attempts'],
      difficulty: json['difficulty'],
      timeSpent: json['timeSpent'],
      gameData: json['gameData'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Leaderboard entry
class LeaderboardEntry {
  final String id;
  final String gameType;
  final int score;
  final String difficulty;
  final int timeSpent;
  final UserProfile user;
  final DateTime createdAt;

  LeaderboardEntry({
    required this.id,
    required this.gameType,
    required this.score,
    required this.difficulty,
    required this.timeSpent,
    required this.user,
    required this.createdAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'],
      gameType: json['gameType'],
      score: json['score'],
      difficulty: json['difficulty'],
      timeSpent: json['timeSpent'],
      user: UserProfile.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Game statistics
class GameStats {
  final String gameType;
  final int totalGames;
  final int maxScore;
  final double avgScore;
  final double avgTimeSpent;

  GameStats({
    required this.gameType,
    required this.totalGames,
    required this.maxScore,
    required this.avgScore,
    required this.avgTimeSpent,
  });

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      gameType: json['gameType'],
      totalGames: json['_count']['id'],
      maxScore: json['_max']['score'] ?? 0,
      avgScore: (json['_avg']['score'] ?? 0).toDouble(),
      avgTimeSpent: (json['_avg']['timeSpent'] ?? 0).toDouble(),
    );
  }
}

// ==================== FRIEND API EXTENSIONS ====================
extension FriendAPI on ApiService {
  /// Search users by username/email
  /// GET /api/friends/search?q=query
  Future<ApiResponse<List<UserProfile>>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/friends/search?q=$query'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final users = (data['users'] as List)
            .map((json) => UserProfile.fromJson(json))
            .toList();

        return ApiResponse<List<UserProfile>>(success: true, data: users);
      } else {
        return ApiResponse<List<UserProfile>>(
          success: false,
          message: data['error'] ?? 'Search failed',
        );
      }
    } catch (e) {
      debugPrint('Search users error: $e');
      return ApiResponse<List<UserProfile>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Send friend request
  /// POST /api/friends/request
  Future<ApiResponse<FriendRequestData>> sendFriendRequest({
    required String receiverId,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/friends/request'),
        headers: _headers,
        body: jsonEncode({'receiverId': receiverId, 'message': message}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<FriendRequestData>(
          success: true,
          data: FriendRequestData.fromJson(data),
        );
      } else {
        return ApiResponse<FriendRequestData>(
          success: false,
          message: data['error'] ?? 'Failed to send request',
        );
      }
    } catch (e) {
      debugPrint('Send friend request error: $e');
      return ApiResponse<FriendRequestData>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get pending friend requests
  /// GET /api/friends/requests
  Future<ApiResponse<List<FriendRequestData>>> getFriendRequests() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/friends/requests'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final requests = (data['requests'] as List)
            .map((json) => FriendRequestData.fromJson(json))
            .toList();

        return ApiResponse<List<FriendRequestData>>(
          success: true,
          data: requests,
        );
      } else {
        return ApiResponse<List<FriendRequestData>>(
          success: false,
          message: data['error'] ?? 'Failed to get requests',
        );
      }
    } catch (e) {
      debugPrint('Get friend requests error: $e');
      return ApiResponse<List<FriendRequestData>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Accept friend request
  /// POST /api/friends/accept/:requestId
  Future<ApiResponse<void>> acceptFriendRequest(String requestId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/friends/accept/$requestId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(success: true);
      } else {
        return ApiResponse<void>(
          success: false,
          message: data['error'] ?? 'Failed to accept request',
        );
      }
    } catch (e) {
      debugPrint('Accept friend request error: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Reject friend request
  /// POST /api/friends/reject/:requestId
  Future<ApiResponse<void>> rejectFriendRequest(String requestId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/friends/reject/$requestId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<void>(success: true);
      } else {
        return ApiResponse<void>(
          success: false,
          message: data['error'] ?? 'Failed to reject request',
        );
      }
    } catch (e) {
      debugPrint('Reject friend request error: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get friends list
  /// GET /api/friends
  Future<ApiResponse<List<FriendData>>> getFriends() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/friends'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final friends = (data['friends'] as List)
            .map((json) => FriendData.fromJson(json))
            .toList();

        return ApiResponse<List<FriendData>>(success: true, data: friends);
      } else {
        return ApiResponse<List<FriendData>>(
          success: false,
          message: data['error'] ?? 'Failed to get friends',
        );
      }
    } catch (e) {
      debugPrint('Get friends error: $e');
      return ApiResponse<List<FriendData>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}

// ==================== MESSAGE API EXTENSIONS ====================
extension MessageAPI on ApiService {
  /// Send message to friend
  /// POST /api/messages
  Future<ApiResponse<MessageData>> sendMessage({
    required String receiverId,
    required String content,
    String type = 'text',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/messages'),
        headers: _headers,
        body: jsonEncode({
          'receiverId': receiverId,
          'content': content,
          'type': type,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<MessageData>(
          success: true,
          data: MessageData.fromJson(data),
        );
      } else {
        return ApiResponse<MessageData>(
          success: false,
          message: data['error'] ?? 'Failed to send message',
        );
      }
    } catch (e) {
      debugPrint('Send message error: $e');
      return ApiResponse<MessageData>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get chat history with a user
  /// GET /api/messages/:userId
  Future<ApiResponse<List<MessageData>>> getChatHistory({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/api/messages/$userId?limit=$limit&offset=$offset',
        ),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final messages = (data['messages'] as List)
            .map((json) => MessageData.fromJson(json))
            .toList();

        return ApiResponse<List<MessageData>>(success: true, data: messages);
      } else {
        return ApiResponse<List<MessageData>>(
          success: false,
          message: data['error'] ?? 'Failed to get messages',
        );
      }
    } catch (e) {
      debugPrint('Get chat history error: $e');
      return ApiResponse<List<MessageData>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get conversations list
  /// GET /api/messages/conversations/list
  Future<ApiResponse<List<ConversationData>>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/messages/conversations/list'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final conversations = (data['conversations'] as List)
            .map((json) => ConversationData.fromJson(json))
            .toList();

        return ApiResponse<List<ConversationData>>(
          success: true,
          data: conversations,
        );
      } else {
        return ApiResponse<List<ConversationData>>(
          success: false,
          message: data['error'] ?? 'Failed to get conversations',
        );
      }
    } catch (e) {
      debugPrint('Get conversations error: $e');
      return ApiResponse<List<ConversationData>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}

// ==================== DATA MODELS ====================

/// Friend Request Data
class FriendRequestData {
  final String id;
  final String senderId;
  final String receiverId;
  final String? message;
  final String status;
  final DateTime sentAt;
  final DateTime? respondedAt;
  final UserProfile? sender;

  FriendRequestData({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    required this.status,
    required this.sentAt,
    this.respondedAt,
    this.sender,
  });

  factory FriendRequestData.fromJson(Map<String, dynamic> json) {
    return FriendRequestData(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      status: json['status'],
      sentAt: DateTime.parse(json['sentAt']),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'])
          : null,
      sender: json['sender'] != null
          ? UserProfile.fromJson(json['sender'])
          : null,
    );
  }
}

/// Friend Data
class FriendData {
  final String friendshipId;
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final int totalScore;
  final int totalGamesPlayed;
  final DateTime friendsSince;

  FriendData({
    required this.friendshipId,
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.totalScore,
    required this.totalGamesPlayed,
    required this.friendsSince,
  });

  factory FriendData.fromJson(Map<String, dynamic> json) {
    return FriendData(
      friendshipId: json['friendshipId'],
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      totalScore: json['totalScore'] ?? 0,
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      friendsSince: DateTime.parse(json['friendsSince']),
    );
  }
}

/// Message Data
class MessageData {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String type;
  final bool isRead;
  final DateTime sentAt;
  final DateTime? readAt;
  final UserProfile? sender;

  MessageData({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.isRead,
    required this.sentAt,
    this.readAt,
    this.sender,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      type: json['type'] ?? 'text',
      isRead: json['isRead'] ?? false,
      sentAt: DateTime.parse(json['sentAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      sender: json['sender'] != null
          ? UserProfile.fromJson(json['sender'])
          : null,
    );
  }
}

/// Conversation Data
class ConversationData {
  final UserProfile friend;
  final MessageData? lastMessage;
  final int unreadCount;

  ConversationData({
    required this.friend,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ConversationData.fromJson(Map<String, dynamic> json) {
    return ConversationData(
      friend: UserProfile.fromJson(json['friend']),
      lastMessage: json['lastMessage'] != null
          ? MessageData.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

// ============ POST MODELS ============

/// Post Data Model
class PostData {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final String visibility;
  final String? category;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile user;
  final bool isLiked;
  final bool isSaved;
  final List<CommentData>? comments;

  PostData({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.visibility,
    this.category,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.isLiked,
    required this.isSaved,
    this.comments,
  });

  factory PostData.fromJson(Map<String, dynamic> json) {
    try {
      return PostData(
        id: (json['id'] ?? '').toString(),
        userId: (json['userId'] ?? '').toString(),
        content: json['content']?.toString() ?? '',
        imageUrl: json['imageUrl']?.toString(),
        visibility: json['visibility']?.toString() ?? 'public',
        category: json['category']?.toString(),
        likeCount: json['likeCount'] ?? 0,
        commentCount: json['commentCount'] ?? 0,
        shareCount: json['shareCount'] ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : DateTime.now(),
        user: UserProfile.fromJson(json['user'] ?? {}),
        isLiked: json['isLiked'] ?? false,
        isSaved: json['isSaved'] ?? false,
        comments: json['comments'] != null
            ? (json['comments'] as List)
                  .map((c) => CommentData.fromJson(c))
                  .toList()
            : null,
      );
    } catch (e) {
      print('Error parsing PostData: $e');
      print('JSON: $json');
      rethrow;
    }
  }
}

/// Comment Data Model
class CommentData {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final UserProfile user;

  CommentData({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.user,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) {
    try {
      return CommentData(
        id: (json['id'] ?? '').toString(),
        postId: (json['postId'] ?? '').toString(),
        userId: (json['userId'] ?? '').toString(),
        content: json['content']?.toString() ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        user: UserProfile.fromJson(json['user'] ?? {}),
      );
    } catch (e) {
      print('Error parsing CommentData: $e');
      print('JSON: $json');
      rethrow;
    }
  }
}

// ============ POSTS API EXTENSION ============

extension PostsAPI on ApiService {
  /// Create a new post
  Future<Map<String, dynamic>> createPost({
    required String content,
    String? imageUrl,
    String visibility = 'public',
    String? category,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/posts');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'content': content,
        'imageUrl': imageUrl,
        'visibility': visibility,
        'category': category,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to create post: ${jsonDecode(response.body)['error'] ?? response.statusCode}',
      );
    }
  }

  /// Upload image file
  Future<String> uploadImage(String filePath) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/upload');
    final request = http.MultipartRequest('POST', url);

    // Add auth header
    if (_authToken != null) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }

    // Add file
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['imageUrl'];
    } else {
      throw Exception(
        'Failed to upload image: ${jsonDecode(responseBody)['error'] ?? response.statusCode}',
      );
    }
  }

  /// Get posts feed (all or filtered by userId, category, or search)
  Future<List<PostData>> getPosts({
    int limit = 20,
    int offset = 0,
    String? userId,
    String? category,
    String? search,
  }) async {
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

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final posts = (data['posts'] as List)
          .map((post) => PostData.fromJson(post))
          .toList();
      return posts;
    } else {
      throw Exception(
        'Failed to get posts: ${jsonDecode(response.body)['error'] ?? response.statusCode}',
      );
    }
  }

  /// Get single post with comments
  Future<PostData> getPost(String postId) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/posts/$postId');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PostData.fromJson(data['post']);
    } else {
      throw Exception(
        'Failed to get post: ${jsonDecode(response.body)['error'] ?? response.statusCode}',
      );
    }
  }

  /// Update post (owner only)
  Future<Map<String, dynamic>> updatePost({
    required String postId,
    required String content,
    String? imageUrl,
    String? visibility,
    String? category,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/posts/$postId');
    final response = await http.put(
      url,
      headers: _headers,
      body: jsonEncode({
        'content': content,
        'imageUrl': imageUrl,
        'visibility': visibility,
        'category': category,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to update post: ${jsonDecode(response.body)['error'] ?? response.statusCode}',
      );
    }
  }

  /// Delete post (owner only)
  Future<Map<String, dynamic>> deletePost(String postId) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/posts/$postId');
    final response = await http.delete(url, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to delete post: ${jsonDecode(response.body)['error'] ?? response.statusCode}',
      );
    }
  }

  /// Toggle like on post
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/posts/$postId/like');
    final response = await http.post(url, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to toggle like: ${jsonDecode(response.body)['error'] ?? response.statusCode}',
      );
    }
  }

  /// Add comment to post
  Future<CommentData> addComment({
    required String postId,
    required String content,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/posts/$postId/comments');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return CommentData.fromJson(data);
    } else {
      throw Exception(
        'Failed to add comment: ${jsonDecode(response.body)['error'] ?? response.statusCode}',
      );
    }
  }

  /// Toggle save post to favorites
  Future<Map<String, dynamic>> toggleSavePost(String postId) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/posts/$postId/save');
    final response = await http.post(url, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to toggle save: ${jsonDecode(response.body)['error'] ?? response.statusCode}',
      );
    }
  }

  /// Get saved posts
  Future<List<PostData>> getSavedPosts() async {
    final url = Uri.parse('${ApiService.baseUrl}/api/posts/saved/list');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final posts = (data['posts'] as List)
          .map((post) => PostData.fromJson(post))
          .toList();
      return posts;
    } else {
      throw Exception(
        'Failed to get saved posts: ${jsonDecode(response.body)['error'] ?? response.statusCode}',
      );
    }
  }

  /// Toggle follow user
  Future<Map<String, dynamic>> toggleFollow(String targetUserId) async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/api/posts/follow/$targetUserId',
    );
    final response = await http.post(url, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to toggle follow: ${jsonDecode(response.body)['error'] ?? response.statusCode}',
      );
    }
  }
}
