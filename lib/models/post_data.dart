import './user_profile.dart';
import './comment_data.dart';

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
