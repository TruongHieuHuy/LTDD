import './user_profile.dart';

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
