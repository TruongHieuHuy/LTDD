import './user_profile.dart';
import './message_data.dart';

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
