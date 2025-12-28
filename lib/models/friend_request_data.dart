import './user_profile.dart';

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
