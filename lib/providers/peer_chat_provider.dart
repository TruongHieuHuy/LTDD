import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/peer_message_model.dart';

/// Provider for P2P chat between users (local-only, no backend)
class PeerChatProvider extends ChangeNotifier {
  static const String _messagesBoxName = 'peer_messages';
  static const String _conversationsBoxName = 'peer_conversations';

  Box? _messagesBox;
  Box? _conversationsBox;

  String? _currentUserId; // Current user's MSSV

  // Getters
  String? get currentUserId => _currentUserId;
  bool get isInitialized => _messagesBox != null && _conversationsBox != null;

  /// Initialize provider with current user
  Future<void> initialize(String userId) async {
    _currentUserId = userId;

    // Open Hive boxes
    if (!Hive.isBoxOpen(_messagesBoxName)) {
      _messagesBox = await Hive.openBox(_messagesBoxName);
    } else {
      _messagesBox = Hive.box(_messagesBoxName);
    }

    if (!Hive.isBoxOpen(_conversationsBoxName)) {
      _conversationsBox = await Hive.openBox(_conversationsBoxName);
    } else {
      _conversationsBox = Hive.box(_conversationsBoxName);
    }

    notifyListeners();
  }

  /// Get all conversations for current user
  List<ChatConversation> getConversations() {
    if (_conversationsBox == null || _currentUserId == null) return [];

    return _conversationsBox!.values
        .map(
          (json) => ChatConversation.fromJson(Map<String, dynamic>.from(json)),
        )
        .where(
          (conv) =>
              conv.userId1 == _currentUserId || conv.userId2 == _currentUserId,
        )
        .toList()
      ..sort((a, b) {
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });
  }

  /// Get messages for a specific chat room
  List<PeerMessage> getMessages(String chatRoomId) {
    if (_messagesBox == null) return [];

    return _messagesBox!.values
        .map((json) => PeerMessage.fromJson(Map<String, dynamic>.from(json)))
        .where(
          (msg) =>
              PeerMessage.getChatRoomId(msg.senderId, msg.receiverId) ==
              chatRoomId,
        )
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Send a text message
  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    if (_messagesBox == null ||
        _conversationsBox == null ||
        _currentUserId == null) {
      return;
    }

    final chatRoomId = PeerMessage.getChatRoomId(_currentUserId!, receiverId);
    final now = DateTime.now();

    // Create message
    final peerMessage = PeerMessage(
      id: '${now.millisecondsSinceEpoch}',
      senderId: _currentUserId!,
      receiverId: receiverId,
      message: message,
      timestamp: now,
      messageType: 'text',
      isRead: false,
    );

    // Save message
    await _messagesBox!.put(peerMessage.id, peerMessage.toJson());

    // Update conversation
    await _updateConversation(
      chatRoomId: chatRoomId,
      userId1: _currentUserId!,
      userId2: receiverId,
      lastMessage: message,
      lastMessageTime: now,
    );

    notifyListeners();
  }

  /// Mark messages as read
  Future<void> markAsRead(String chatRoomId) async {
    if (_messagesBox == null || _currentUserId == null) return;

    final messages = getMessages(chatRoomId);
    for (var msg in messages) {
      if (msg.receiverId == _currentUserId && !msg.isRead) {
        final updatedMsg = msg.copyWith(isRead: true);
        await _messagesBox!.put(msg.id, updatedMsg.toJson());
      }
    }

    // Update conversation unread count
    final convJson = _conversationsBox!.get(chatRoomId);
    if (convJson != null) {
      final conversation = ChatConversation.fromJson(
        Map<String, dynamic>.from(convJson),
      );
      await _conversationsBox!.put(
        chatRoomId,
        conversation.copyWith(unreadCount: 0).toJson(),
      );
    }

    notifyListeners();
  }

  /// Update or create conversation
  Future<void> _updateConversation({
    required String chatRoomId,
    required String userId1,
    required String userId2,
    required String lastMessage,
    required DateTime lastMessageTime,
  }) async {
    if (_conversationsBox == null) return;

    final convJson = _conversationsBox!.get(chatRoomId);
    ChatConversation conversation;

    if (convJson == null) {
      // Create new conversation
      conversation = ChatConversation(
        chatRoomId: chatRoomId,
        userId1: userId1,
        userId2: userId2,
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        unreadCount: userId1 == _currentUserId ? 0 : 1,
      );
    } else {
      // Update existing
      final existing = ChatConversation.fromJson(
        Map<String, dynamic>.from(convJson),
      );
      conversation = existing.copyWith(
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        unreadCount: userId1 == _currentUserId
            ? existing.unreadCount
            : existing.unreadCount + 1,
      );
    }

    await _conversationsBox!.put(chatRoomId, conversation.toJson());
  }

  /// Get conversation with specific user
  ChatConversation? getConversationWith(String userId) {
    if (_conversationsBox == null || _currentUserId == null) return null;

    final chatRoomId = PeerMessage.getChatRoomId(_currentUserId!, userId);
    final convJson = _conversationsBox!.get(chatRoomId);
    return convJson != null
        ? ChatConversation.fromJson(Map<String, dynamic>.from(convJson))
        : null;
  }

  /// Delete conversation
  Future<void> deleteConversation(String chatRoomId) async {
    if (_messagesBox == null || _conversationsBox == null) return;

    // Delete all messages
    final messages = getMessages(chatRoomId);
    for (var msg in messages) {
      await _messagesBox!.delete(msg.id);
    }

    // Delete conversation
    await _conversationsBox!.delete(chatRoomId);

    notifyListeners();
  }

  /// Delete a single message
  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    if (_messagesBox == null) return;

    await _messagesBox!.delete(messageId);

    // Update conversation's last message if needed
    final messages = getMessages(chatRoomId);
    if (messages.isNotEmpty) {
      final lastMsg = messages.last;
      final convJson = _conversationsBox!.get(chatRoomId);
      if (convJson != null) {
        final conversation = ChatConversation.fromJson(
          Map<String, dynamic>.from(convJson),
        );
        await _conversationsBox!.put(
          chatRoomId,
          conversation
              .copyWith(
                lastMessage: lastMsg.message,
                lastMessageTime: lastMsg.timestamp,
              )
              .toJson(),
        );
      }
    } else {
      // No messages left, delete conversation
      await _conversationsBox!.delete(chatRoomId);
    }

    notifyListeners();
  }

  /// Get total unread count
  int getTotalUnreadCount() {
    if (_conversationsBox == null || _currentUserId == null) return 0;

    return getConversations().fold(0, (sum, conv) => sum + conv.unreadCount);
  }

  /// Get user info from member list
  Map<String, dynamic>? getMemberInfo(
    String userId,
    List<Map<String, dynamic>> allMembers,
  ) {
    try {
      return allMembers.firstWhere((m) => m['mssv'] == userId);
    } catch (e) {
      return null;
    }
  }

  /// Clear all data (for testing)
  Future<void> clearAll() async {
    await _messagesBox?.clear();
    await _conversationsBox?.clear();
    notifyListeners();
  }
}
