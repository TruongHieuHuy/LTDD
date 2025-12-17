/// Extension models for group chat functionality
/// These models work alongside existing PeerMessage to support group chats

/// Model for group chat messages
class GroupMessage {
  final String id;
  final String groupId; // Group ID instead of receiverId
  final String senderId; // MSSV of sender
  final String message;
  final DateTime timestamp;
  final String messageType; // 'text', 'image', 'system'
  final Map<String, bool> readBy; // Map of userId -> read status
  final String? imageUrl;
  final String?
  systemAction; // For system messages: 'member_added', 'member_removed', etc.

  GroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.message,
    required this.timestamp,
    this.messageType = 'text',
    Map<String, bool>? readBy,
    this.imageUrl,
    this.systemAction,
  }) : readBy = readBy ?? {};

  /// Check if message was read by user
  bool isReadBy(String userId) => readBy[userId] ?? false;

  /// Mark as read by user
  GroupMessage markReadBy(String userId) {
    final updatedReadBy = Map<String, bool>.from(readBy);
    updatedReadBy[userId] = true;
    return copyWith(readBy: updatedReadBy);
  }

  /// Copy with method for updating
  GroupMessage copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? message,
    DateTime? timestamp,
    String? messageType,
    Map<String, bool>? readBy,
    String? imageUrl,
    String? systemAction,
  }) {
    return GroupMessage(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      readBy: readBy ?? this.readBy,
      imageUrl: imageUrl ?? this.imageUrl,
      systemAction: systemAction ?? this.systemAction,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'groupId': groupId,
    'senderId': senderId,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'messageType': messageType,
    'readBy': readBy,
    'imageUrl': imageUrl,
    'systemAction': systemAction,
  };

  /// Create from JSON
  factory GroupMessage.fromJson(Map<String, dynamic> json) => GroupMessage(
    id: json['id'] as String,
    groupId: json['groupId'] as String,
    senderId: json['senderId'] as String,
    message: json['message'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    messageType: json['messageType'] as String? ?? 'text',
    readBy: json['readBy'] != null
        ? Map<String, bool>.from(json['readBy'] as Map)
        : {},
    imageUrl: json['imageUrl'] as String?,
    systemAction: json['systemAction'] as String?,
  );

  /// Create system message
  factory GroupMessage.system({
    required String groupId,
    required String senderId,
    required String message,
    required String systemAction,
  }) {
    return GroupMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      groupId: groupId,
      senderId: senderId,
      message: message,
      timestamp: DateTime.now(),
      messageType: 'system',
      systemAction: systemAction,
    );
  }
}

/// Model for chat room summary (both P2P and group)
class ChatRoom {
  final String id; // chatRoomId or groupId
  final String type; // 'peer' or 'group'
  final String? name; // Group name (null for P2P)
  final List<String> participantIds; // List of MSSVs
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final String? avatarUrl; // Group avatar (null for P2P)

  ChatRoom({
    required this.id,
    required this.type,
    this.name,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.avatarUrl,
  });

  bool get isPeerChat => type == 'peer';
  bool get isGroupChat => type == 'group';

  /// Copy with method
  ChatRoom copyWith({
    String? id,
    String? type,
    String? name,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    String? avatarUrl,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'name': name,
    'participantIds': participantIds,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime?.toIso8601String(),
    'unreadCount': unreadCount,
    'avatarUrl': avatarUrl,
  };

  /// Create from JSON
  factory ChatRoom.fromJson(Map<String, dynamic> json) => ChatRoom(
    id: json['id'] as String,
    type: json['type'] as String,
    name: json['name'] as String?,
    participantIds: (json['participantIds'] as List).cast<String>(),
    lastMessage: json['lastMessage'] as String?,
    lastMessageTime: json['lastMessageTime'] != null
        ? DateTime.parse(json['lastMessageTime'] as String)
        : null,
    unreadCount: json['unreadCount'] as int? ?? 0,
    avatarUrl: json['avatarUrl'] as String?,
  );

  /// Create P2P chat room
  factory ChatRoom.peer({
    required String userId1,
    required String userId2,
    String? lastMessage,
    DateTime? lastMessageTime,
    int unreadCount = 0,
  }) {
    final users = [userId1, userId2]..sort();
    return ChatRoom(
      id: '${users[0]}_${users[1]}',
      type: 'peer',
      participantIds: [userId1, userId2],
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
    );
  }

  /// Create group chat room
  factory ChatRoom.group({
    required String groupId,
    required String groupName,
    required List<String> memberIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    int unreadCount = 0,
    String? avatarUrl,
  }) {
    return ChatRoom(
      id: groupId,
      type: 'group',
      name: groupName,
      participantIds: memberIds,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      avatarUrl: avatarUrl,
    );
  }
}
