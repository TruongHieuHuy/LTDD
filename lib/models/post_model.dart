import 'package:hive/hive.dart';

part 'post_model.g.dart';

/// Model cho bài đăng (Facebook-style posts)
@HiveType(typeId: 11)
class Post {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String authorName;

  @HiveField(2)
  final String? authorAvatar;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final int likes;

  @HiveField(6)
  final int comments;

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  final String? authorId;

  Post({
    this.id,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
    required this.timestamp,
    this.authorId,
  });

  /// Create Post from JSON (API response)
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int?,
      authorName: json['authorName'] as String? ?? 'Unknown',
      authorAvatar: json['authorAvatar'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      authorId: json['authorId'] as String?,
    );
  }

  /// Convert Post to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'timestamp': timestamp.toIso8601String(),
      'authorId': authorId,
    };
  }

  /// Create a copy with updated fields
  Post copyWith({
    int? id,
    String? authorName,
    String? authorAvatar,
    String? content,
    String? imageUrl,
    int? likes,
    int? comments,
    DateTime? timestamp,
    String? authorId,
  }) {
    return Post(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      timestamp: timestamp ?? this.timestamp,
      authorId: authorId ?? this.authorId,
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, author: $authorName, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}...)';
  }
}
