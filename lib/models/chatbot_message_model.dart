import 'package:hive/hive.dart';

part 'chatbot_message_model.g.dart';

/// Model for chatbot messages
/// Stores chat history in Hive local database
@HiveType(typeId: 6)
class ChatbotMessage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String senderId; // 'USER' or 'BOT'

  @HiveField(2)
  String? message; // Text message (nullable if only image)

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String? imageUri; // Optional image (local file path or URL)

  @HiveField(5)
  bool isSeen;

  @HiveField(6)
  String? messageType; // 'text', 'game_stat', 'achievement', 'tip'

  ChatbotMessage({
    required this.id,
    required this.senderId,
    this.message,
    required this.timestamp,
    this.imageUri,
    this.isSeen = false,
    this.messageType = 'text',
  });

  /// Check if message is from user
  bool get isUserMessage => senderId == 'USER';

  /// Check if message is from bot
  bool get isBotMessage => senderId == 'BOT';

  /// Check if message has image
  bool get hasImage => imageUri != null && imageUri!.isNotEmpty;

  /// Check if message has text
  bool get hasText => message != null && message!.isNotEmpty;

  /// Convert to JSON for debugging
  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'imageUri': imageUri,
    'isSeen': isSeen,
    'messageType': messageType,
  };

  /// Create from JSON
  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      message: json['message'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      imageUri: json['imageUri'] as String?,
      isSeen: json['isSeen'] as bool? ?? false,
      messageType: json['messageType'] as String? ?? 'text',
    );
  }

  @override
  String toString() {
    return 'ChatbotMessage(id: $id, sender: $senderId, message: ${message?.substring(0, 20)}..., time: $timestamp)';
  }
}
