import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/friendship_model.dart';

/// Provider quản lý bạn bè (Zalo-style friend system)
class FriendProvider extends ChangeNotifier {
  static const String _requestsBoxName = 'friend_requests';
  static const String _friendshipsBoxName = 'friendships';

  Box? _requestsBox;
  Box? _friendshipsBox;

  String? _currentUserId; // Current user's MSSV

  // Getters
  String? get currentUserId => _currentUserId;
  bool get isInitialized => _requestsBox != null && _friendshipsBox != null;

  /// Initialize provider with current user
  Future<void> initialize(String userId) async {
    _currentUserId = userId;

    // Open Hive boxes
    if (!Hive.isBoxOpen(_requestsBoxName)) {
      _requestsBox = await Hive.openBox(_requestsBoxName);
    } else {
      _requestsBox = Hive.box(_requestsBoxName);
    }

    if (!Hive.isBoxOpen(_friendshipsBoxName)) {
      _friendshipsBox = await Hive.openBox(_friendshipsBoxName);
    } else {
      _friendshipsBox = Hive.box(_friendshipsBoxName);
    }

    notifyListeners();
  }

  /// Get all friends of current user
  List<Friendship> getFriends() {
    if (_friendshipsBox == null || _currentUserId == null) return [];

    return _friendshipsBox!.values
        .map((json) => Friendship.fromJson(Map<String, dynamic>.from(json)))
        .where(
          (friendship) =>
              friendship.hasUser(_currentUserId!) && !friendship.isBlocked,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get friend IDs (MSSV list) of current user
  List<String> getFriendIds() {
    return getFriends()
        .map((friendship) => friendship.getOtherUserId(_currentUserId!))
        .toList();
  }

  /// Check if two users are friends
  bool areFriends(String userId1, String userId2) {
    if (_friendshipsBox == null) return false;

    final friendshipId = Friendship.getFriendshipId(userId1, userId2);
    final friendshipJson = _friendshipsBox!.get(friendshipId);

    if (friendshipJson == null) return false;

    final friendship = Friendship.fromJson(
      Map<String, dynamic>.from(friendshipJson),
    );
    return !friendship.isBlocked;
  }

  /// Send friend request
  Future<bool> sendFriendRequest({
    required String receiverId,
    String? message,
  }) async {
    if (_requestsBox == null ||
        _friendshipsBox == null ||
        _currentUserId == null) {
      return false;
    }

    // Check if already friends
    if (areFriends(_currentUserId!, receiverId)) {
      debugPrint('Already friends with $receiverId');
      return false;
    }

    // Check if request already exists
    final existingRequest = getPendingRequestBetween(
      _currentUserId!,
      receiverId,
    );
    if (existingRequest != null) {
      debugPrint('Friend request already exists');
      return false;
    }

    final now = DateTime.now();
    final request = FriendRequest(
      id: '${_currentUserId}_${receiverId}_${now.millisecondsSinceEpoch}',
      senderId: _currentUserId!,
      receiverId: receiverId,
      sentAt: now,
      message: message,
    );

    await _requestsBox!.put(request.id, request.toJson());
    notifyListeners();

    debugPrint('Friend request sent to $receiverId');
    return true;
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String requestId) async {
    if (_requestsBox == null ||
        _friendshipsBox == null ||
        _currentUserId == null) {
      return false;
    }

    final requestJson = _requestsBox!.get(requestId);
    if (requestJson == null) return false;

    final request = FriendRequest.fromJson(
      Map<String, dynamic>.from(requestJson),
    );

    // Verify current user is the receiver
    if (request.receiverId != _currentUserId) {
      debugPrint('Cannot accept request - not the receiver');
      return false;
    }

    // Update request status
    final updatedRequest = FriendRequest(
      id: request.id,
      senderId: request.senderId,
      receiverId: request.receiverId,
      sentAt: request.sentAt,
      status: 'accepted',
      respondedAt: DateTime.now(),
      message: request.message,
    );
    await _requestsBox!.put(requestId, updatedRequest.toJson());

    // Create friendship
    final friendshipId = Friendship.getFriendshipId(
      request.senderId,
      request.receiverId,
    );
    final friendship = Friendship(
      id: friendshipId,
      userId1: request.senderId.compareTo(request.receiverId) < 0
          ? request.senderId
          : request.receiverId,
      userId2: request.senderId.compareTo(request.receiverId) < 0
          ? request.receiverId
          : request.senderId,
      createdAt: DateTime.now(),
    );
    await _friendshipsBox!.put(friendshipId, friendship.toJson());

    notifyListeners();
    debugPrint('Friend request accepted from ${request.senderId}');
    return true;
  }

  /// Reject friend request
  Future<bool> rejectFriendRequest(String requestId) async {
    if (_requestsBox == null || _currentUserId == null) return false;

    final requestJson = _requestsBox!.get(requestId);
    if (requestJson == null) return false;

    final request = FriendRequest.fromJson(
      Map<String, dynamic>.from(requestJson),
    );

    // Verify current user is the receiver
    if (request.receiverId != _currentUserId) {
      debugPrint('Cannot reject request - not the receiver');
      return false;
    }

    // Update request status
    final updatedRequest = FriendRequest(
      id: request.id,
      senderId: request.senderId,
      receiverId: request.receiverId,
      sentAt: request.sentAt,
      status: 'rejected',
      respondedAt: DateTime.now(),
      message: request.message,
    );
    await _requestsBox!.put(requestId, updatedRequest.toJson());

    notifyListeners();
    debugPrint('Friend request rejected from ${request.senderId}');
    return true;
  }

  /// Get pending friend requests (received by current user)
  List<FriendRequest> getPendingRequests() {
    if (_requestsBox == null || _currentUserId == null) return [];

    return _requestsBox!.values
        .map((json) => FriendRequest.fromJson(Map<String, dynamic>.from(json)))
        .where(
          (request) =>
              request.receiverId == _currentUserId && request.isPending,
        )
        .toList()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  /// Get sent friend requests (sent by current user)
  List<FriendRequest> getSentRequests() {
    if (_requestsBox == null || _currentUserId == null) return [];

    return _requestsBox!.values
        .map((json) => FriendRequest.fromJson(Map<String, dynamic>.from(json)))
        .where(
          (request) => request.senderId == _currentUserId && request.isPending,
        )
        .toList()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  /// Get pending request between two users (either direction)
  FriendRequest? getPendingRequestBetween(String userId1, String userId2) {
    if (_requestsBox == null) return null;

    final requests = _requestsBox!.values
        .map((json) => FriendRequest.fromJson(Map<String, dynamic>.from(json)))
        .where(
          (request) =>
              request.isPending &&
              ((request.senderId == userId1 && request.receiverId == userId2) ||
                  (request.senderId == userId2 &&
                      request.receiverId == userId1)),
        )
        .toList();

    return requests.isNotEmpty ? requests.first : null;
  }

  /// Remove friend (unfriend)
  Future<bool> removeFriend(String friendId) async {
    if (_friendshipsBox == null || _currentUserId == null) return false;

    final friendshipId = Friendship.getFriendshipId(_currentUserId!, friendId);
    await _friendshipsBox!.delete(friendshipId);

    notifyListeners();
    debugPrint('Removed friend: $friendId');
    return true;
  }

  /// Block user
  Future<bool> blockUser(String userId) async {
    if (_friendshipsBox == null || _currentUserId == null) return false;

    final friendshipId = Friendship.getFriendshipId(_currentUserId!, userId);
    final friendshipJson = _friendshipsBox!.get(friendshipId);

    if (friendshipJson == null) return false;

    final friendship = Friendship.fromJson(
      Map<String, dynamic>.from(friendshipJson),
    );

    final updatedFriendship = Friendship(
      id: friendship.id,
      userId1: friendship.userId1,
      userId2: friendship.userId2,
      createdAt: friendship.createdAt,
      isBlocked: true,
      blockedBy: _currentUserId,
    );

    await _friendshipsBox!.put(friendshipId, updatedFriendship.toJson());
    notifyListeners();

    debugPrint('Blocked user: $userId');
    return true;
  }

  /// Get number of friends
  int get friendCount => getFriends().length;

  /// Get number of pending requests
  int get pendingRequestCount => getPendingRequests().length;

  /// Dispose resources
  @override
  void dispose() {
    // Don't close boxes here - they're shared across providers
    super.dispose();
  }
}
