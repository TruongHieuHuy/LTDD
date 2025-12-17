import 'package:hive/hive.dart';

part 'friendship_model.g.dart';

/// Model for friend requests (Zalo-style)
@HiveType(typeId: 7)
class FriendRequest extends HiveObject {
  @HiveField(0)
  String id; // Unique request ID

  @HiveField(1)
  String senderId; // MSSV of sender

  @HiveField(2)
  String receiverId; // MSSV of receiver

  @HiveField(3)
  DateTime sentAt; // When request was sent

  @HiveField(4)
  String status; // 'pending', 'accepted', 'rejected'

  @HiveField(5)
  DateTime? respondedAt; // When receiver responded

  @HiveField(6)
  String? message; // Optional message with request

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.sentAt,
    this.status = 'pending',
    this.respondedAt,
    this.message,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'sentAt': sentAt.toIso8601String(),
    'status': status,
    'respondedAt': respondedAt?.toIso8601String(),
    'message': message,
  };

  /// Create from JSON
  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
    id: json['id'] as String,
    senderId: json['senderId'] as String,
    receiverId: json['receiverId'] as String,
    sentAt: DateTime.parse(json['sentAt'] as String),
    status: json['status'] as String? ?? 'pending',
    respondedAt: json['respondedAt'] != null
        ? DateTime.parse(json['respondedAt'] as String)
        : null,
    message: json['message'] as String?,
  );
}

/// Model for confirmed friendships
@HiveType(typeId: 8)
class Friendship extends HiveObject {
  @HiveField(0)
  String id; // Unique friendship ID (format: userId1_userId2)

  @HiveField(1)
  String userId1; // MSSV of first user (smaller)

  @HiveField(2)
  String userId2; // MSSV of second user (larger)

  @HiveField(3)
  DateTime createdAt; // When friendship was established

  @HiveField(4)
  bool isBlocked; // If one user blocked the other

  @HiveField(5)
  String? blockedBy; // MSSV of blocker (if blocked)

  Friendship({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.createdAt,
    this.isBlocked = false,
    this.blockedBy,
  });

  /// Get friendship ID from two user IDs (always sorted)
  static String getFriendshipId(String userIdA, String userIdB) {
    final users = [userIdA, userIdB]..sort();
    return '${users[0]}_${users[1]}';
  }

  /// Check if user is part of this friendship
  bool hasUser(String userId) => userId == userId1 || userId == userId2;

  /// Get the other user in the friendship
  String getOtherUserId(String currentUserId) {
    return currentUserId == userId1 ? userId2 : userId1;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId1': userId1,
    'userId2': userId2,
    'createdAt': createdAt.toIso8601String(),
    'isBlocked': isBlocked,
    'blockedBy': blockedBy,
  };

  /// Create from JSON
  factory Friendship.fromJson(Map<String, dynamic> json) => Friendship(
    id: json['id'] as String,
    userId1: json['userId1'] as String,
    userId2: json['userId2'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isBlocked: json['isBlocked'] as bool? ?? false,
    blockedBy: json['blockedBy'] as String?,
  );
}
