/// Model for P2P messages between users
class PeerMessage {
  final String id;
  final String senderId; // MSSV of sender
  final String receiverId; // MSSV of receiver
  final String message;
  final DateTime timestamp;
  final String messageType; // 'text', 'image'
  final bool isRead;
  final String? imageUrl;

  PeerMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.messageType = 'text',
    this.isRead = false,
    this.imageUrl,
  });

  /// Get chat room ID (format: smaller_mssv_larger_mssv)
  static String getChatRoomId(String userId1, String userId2) {
    final users = [userId1, userId2]..sort();
    return '${users[0]}_${users[1]}';
  }

  /// Check if this user is sender
  bool isSender(String currentUserId) => senderId == currentUserId;

  /// Copy with method for updating
  PeerMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    DateTime? timestamp,
    String? messageType,
    bool? isRead,
    String? imageUrl,
  }) {
    return PeerMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'messageType': messageType,
    'isRead': isRead,
    'imageUrl': imageUrl,
  };

  /// Create from JSON
  factory PeerMessage.fromJson(Map<String, dynamic> json) => PeerMessage(
    id: json['id'] as String,
    senderId: json['senderId'] as String,
    receiverId: json['receiverId'] as String,
    message: json['message'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    messageType: json['messageType'] as String? ?? 'text',
    isRead: json['isRead'] as bool? ?? false,
    imageUrl: json['imageUrl'] as String?,
  );
}

/// Model for chat conversation summary
class ChatConversation {
  final String chatRoomId;
  final String userId1;
  final String userId2;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatConversation({
    required this.chatRoomId,
    required this.userId1,
    required this.userId2,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  /// Get the other user's ID
  String getOtherUserId(String currentUserId) {
    return currentUserId == userId1 ? userId2 : userId1;
  }

  /// Copy with method
  ChatConversation copyWith({
    String? chatRoomId,
    String? userId1,
    String? userId2,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatConversation(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'chatRoomId': chatRoomId,
    'userId1': userId1,
    'userId2': userId2,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime?.toIso8601String(),
    'unreadCount': unreadCount,
  };

  /// Create from JSON
  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      ChatConversation(
        chatRoomId: json['chatRoomId'] as String,
        userId1: json['userId1'] as String,
        userId2: json['userId2'] as String,
        lastMessage: json['lastMessage'] as String?,
        lastMessageTime: json['lastMessageTime'] != null
            ? DateTime.parse(json['lastMessageTime'] as String)
            : null,
        unreadCount: json['unreadCount'] as int? ?? 0,
      );
}
