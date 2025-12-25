import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

/// Socket.IO Service for real-time chat functionality
/// Based on backend Socket.IO implementation with JWT authentication
class SocketService {
  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;

  // Callbacks
  Function(String userId, bool isOnline)? onUserStatusChanged;
  Function(Map<String, dynamic> message)? onNewMessage;
  Function(String userId, bool isTyping)? onTypingStatusChanged;
  Function(String messageId)? onMessageRead;
  Function(List<String> onlineUserIds)? onOnlineUsersUpdated;

  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;

  /// Connect to Socket.IO server with JWT token
  void connect({
    required String token,
    required String userId,
    String? baseUrl,
  }) {
    if (_isConnected && _currentUserId == userId) {
      debugPrint('Socket already connected for user: $userId');
      return;
    }

    disconnect(); // Disconnect previous connection

    _currentUserId = userId;
    final url =
        baseUrl ?? (kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000');

    debugPrint('🔌 Connecting to Socket.IO: $url');

    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _setupEventHandlers();
    _socket!.connect();
  }

  /// Setup all event handlers
  void _setupEventHandlers() {
    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('✅ Socket connected! User: $_currentUserId');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('❌ Socket disconnected');
    });

    _socket!.onConnectError((error) {
      debugPrint('🚫 Socket connect error: $error');
    });

    _socket!.onError((error) {
      debugPrint('⚠️ Socket error: $error');
    });

    // User status events
    _socket!.on('user:status', (data) {
      debugPrint('👤 User status: $data');
      if (data is Map<String, dynamic>) {
        final userId = data['userId'] as String?;
        final isOnline = data['online'] as bool? ?? false;
        if (userId != null && onUserStatusChanged != null) {
          onUserStatusChanged!(userId, isOnline);
        }
      }
    });

    // Online users list
    _socket!.on('friends:online', (data) {
      debugPrint('👥 Online friends: $data');
      if (data is List && onOnlineUsersUpdated != null) {
        final userIds = data.map((id) => id.toString()).toList();
        onOnlineUsersUpdated!(userIds);
      }
    });

    // New message received
    _socket!.on('message:new', (data) {
      debugPrint('💬 New message: $data');
      if (data is Map<String, dynamic> && onNewMessage != null) {
        onNewMessage!(data);
      }
    });

    // Typing status
    _socket!.on('typing:start', (data) {
      debugPrint('✍️ User typing: $data');
      if (data is Map<String, dynamic>) {
        final userId = data['userId'] as String?;
        if (userId != null && onTypingStatusChanged != null) {
          onTypingStatusChanged!(userId, true);
        }
      }
    });

    _socket!.on('typing:stop', (data) {
      debugPrint('🛑 User stopped typing: $data');
      if (data is Map<String, dynamic>) {
        final userId = data['userId'] as String?;
        if (userId != null && onTypingStatusChanged != null) {
          onTypingStatusChanged!(userId, false);
        }
      }
    });

    // Message read receipt
    _socket!.on('message:read', (data) {
      debugPrint('👁️ Message read: $data');
      if (data is Map<String, dynamic>) {
        final messageId = data['messageId'] as String?;
        if (messageId != null && onMessageRead != null) {
          onMessageRead!(messageId);
        }
      }
    });
  }

  /// Join a chat room with a friend
  void joinChatRoom(String friendId) {
    if (!_isConnected) {
      debugPrint('⚠️ Cannot join room: Socket not connected');
      return;
    }

    debugPrint('🚪 Joining chat room with: $friendId');
    _socket!.emit('chat:join', {'friendId': friendId});
  }

  /// Leave a chat room
  void leaveChatRoom(String friendId) {
    if (!_isConnected) return;

    debugPrint('🚪 Leaving chat room with: $friendId');
    _socket!.emit('chat:leave', {'friendId': friendId});
  }

  /// Send a message
  void sendMessage({required String friendId, required String content}) {
    if (!_isConnected) {
      debugPrint('⚠️ Cannot send message: Socket not connected');
      return;
    }

    debugPrint('📤 Sending message to $friendId: $content');
    _socket!.emit('message:send', {'friendId': friendId, 'content': content});
  }

  /// Send typing indicator
  void sendTypingStatus({required String friendId, required bool isTyping}) {
    if (!_isConnected) return;

    final event = isTyping ? 'typing:start' : 'typing:stop';
    _socket!.emit(event, {'friendId': friendId});
  }

  /// Mark message as read
  void markMessageAsRead(String messageId) {
    if (!_isConnected) return;

    debugPrint('👁️ Marking message as read: $messageId');
    _socket!.emit('message:read', {'messageId': messageId});
  }

  /// Disconnect from Socket.IO
  void disconnect() {
    if (_socket != null) {
      debugPrint('🔌 Disconnecting socket...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    _currentUserId = null;
  }

  /// Clear all callbacks
  void clearCallbacks() {
    onUserStatusChanged = null;
    onNewMessage = null;
    onTypingStatusChanged = null;
    onMessageRead = null;
    onOnlineUsersUpdated = null;
  }
}
