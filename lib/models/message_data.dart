import './user_profile.dart';

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
