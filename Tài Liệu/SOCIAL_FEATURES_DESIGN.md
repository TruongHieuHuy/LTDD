# 💬 SOCIAL FEATURES DESIGN

> ⚠️ **QUAN TRỌNG**: Chat Realtime là "Nice to have", KHÔNG bắt buộc!
> 🎯 **ƯU TIÊN**: Leaderboard > Challenge > Friend > Chat
> 🚨 **NHẬ**: Giáo viên sẽ chấm rớt nếu 4 game chưa chạy!

**Dự án**: Game Mobile - Social & Challenge System  
**Ngày**: 18/12/2025  
**Features**: Real-time Chat (OPTIONAL), 1v1 Challenges, Friend System

---

## 📋 MỤC LỤC
1. [Real-time Chat System](#1-real-time-chat-system)
2. [Challenge System](#2-challenge-system)
3. [Friend System](#3-friend-system)
4. [Notifications](#4-notifications)

---

## 1. REAL-TIME CHAT SYSTEM (❌ OPTIONAL - LÀM CUỐI CÙNG)

> ⚠️ **KHÔNG ƯU TIÊN**: Chỉ làm khi đã hoàn thành 4 game + Challenge
> 💭 **Lý do**: WebSocket phức tảp, dễ bug, không nhất thiết cho game mobile

### 1.1 Architecture (Chỉ tham khảo)

```
┌─────────────────────────────────────────────────┐
│              CHAT ARCHITECTURE                   │
└─────────────────────────────────────────────────┘

Flutter App                    Backend Server
     │                              │
     │  1. Connect WebSocket        │
     ├─────────────────────────────>│
     │  ws://api.com/chat/connect   │
     │                              │
     │  2. Authenticate             │
     │<─────────────────────────────┤
     │  { token: "jwt_token" }      │
     │                              │
     │  3. Join Rooms               │
     ├─────────────────────────────>│
     │  { action: "join", roomId }  │
     │                              │
     │  4. Send Message             │
     ├─────────────────────────────>│
     │  { type: "text", content }   │
     │                              │
     │  5. Receive Message          │
     │<─────────────────────────────┤
     │  { from, message, timestamp }│
     │                              │
     │  6. Save to Local DB         │
     ├─────> Hive                   │
     │                              │
```

### 1.2 Data Models

```dart
// lib/models/chat_message_model.dart
@HiveType(typeId: 15)
class ChatMessage {
  @HiveField(0) String id;              // UUID
  @HiveField(1) String roomId;          // 'user1_user2' or 'challenge_123'
  @HiveField(2) String senderId;
  @HiveField(3) String senderName;
  @HiveField(4) String? senderAvatar;
  @HiveField(5) String receiverId;
  @HiveField(6) String message;
  @HiveField(7) String messageType;     // 'text', 'image', 'game_invite'
  @HiveField(8) DateTime timestamp;
  @HiveField(9) bool isRead;
  @HiveField(10) bool isSentByMe;
  
  // Sync metadata
  @HiveField(11) bool isSynced;
  @HiveField(12) String syncStatus;     // 'pending', 'sent', 'delivered', 'read'
  
  // Optional attachments
  @HiveField(13) Map<String, dynamic>? attachmentData;
}

// lib/models/chat_room_model.dart
@HiveType(typeId: 16)
class ChatRoom {
  @HiveField(0) String id;              // 'user1_user2'
  @HiveField(1) String participantId;   // Other user's ID
  @HiveField(2) String participantName;
  @HiveField(3) String? participantAvatar;
  @HiveField(4) String? lastMessage;
  @HiveField(5) DateTime? lastMessageTime;
  @HiveField(6) int unreadCount;
  @HiveField(7) bool isOnline;          // Other user's online status
}
```

### 1.3 WebSocket Service

```dart
// lib/services/chat_websocket_service.dart
class ChatWebSocketService {
  IOWebSocketChannel? _channel;
  final _messageController = StreamController<ChatMessage>.broadcast();
  
  Stream<ChatMessage> get messages => _messageController.stream;
  
  Future<void> connect(String token) async {
    final uri = Uri.parse('ws://your-api.com/chat/connect');
    _channel = IOWebSocketChannel.connect(uri);
    
    // Authenticate
    _send({
      'action': 'authenticate',
      'token': token,
    });
    
    // Listen for messages
    _channel!.stream.listen(
      (data) => _handleMessage(jsonDecode(data)),
      onError: (error) => _handleError(error),
      onDone: () => _handleDisconnect(),
    );
  }
  
  void _handleMessage(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'message':
        final message = ChatMessage.fromJson(data['data']);
        _messageController.add(message);
        _saveToLocalDB(message);
        break;
      case 'read_receipt':
        _updateMessageStatus(data['messageId'], 'read');
        break;
      case 'user_online':
        _updateUserStatus(data['userId'], true);
        break;
      case 'user_offline':
        _updateUserStatus(data['userId'], false);
        break;
    }
  }
  
  Future<void> sendMessage(ChatMessage message) async {
    // Save to local first (optimistic UI)
    await DatabaseService.chatMessagesBox.put(message.id, message);
    
    // Send via WebSocket
    _send({
      'action': 'send_message',
      'data': message.toJson(),
    });
  }
  
  void _send(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }
  
  void disconnect() {
    _channel?.sink.close();
    _messageController.close();
  }
}
```

### 1.4 Chat UI Screen

```dart
// lib/screens/chat/chat_screen.dart
class ChatScreen extends StatefulWidget {
  final String roomId;
  final String participantName;
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  late StreamSubscription _messageSubscription;
  
  @override
  void initState() {
    super.initState();
    _loadLocalMessages();
    _subscribeToNewMessages();
  }
  
  Future<void> _loadLocalMessages() async {
    final messages = DatabaseService.chatMessagesBox.values
        .where((m) => m.roomId == widget.roomId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    setState(() => _messages = messages);
  }
  
  void _subscribeToNewMessages() {
    _messageSubscription = ChatWebSocketService.instance.messages
        .where((msg) => msg.roomId == widget.roomId)
        .listen((message) {
      setState(() {
        _messages.insert(0, message);
      });
      _scrollToBottom();
    });
  }
  
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = ChatMessage(
      id: Uuid().v4(),
      roomId: widget.roomId,
      senderId: DatabaseService.getUser()!.id,
      senderName: DatabaseService.getUser()!.username,
      receiverId: widget.participantId,
      message: _messageController.text.trim(),
      messageType: 'text',
      timestamp: DateTime.now(),
      isRead: false,
      isSentByMe: true,
      isSynced: false,
      syncStatus: 'pending',
    );
    
    await ChatWebSocketService.instance.sendMessage(message);
    
    setState(() {
      _messages.insert(0, message);
      _messageController.clear();
    });
    
    _scrollToBottom();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(child: Text(widget.participantName[0])),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.participantName),
                Text('Online', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isSentByMe 
          ? Alignment.centerRight 
          : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isSentByMe 
              ? Colors.blue 
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: message.isSentByMe ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
                if (message.isSentByMe) ...[
                  SizedBox(width: 4),
                  Icon(
                    message.isRead 
                        ? Icons.done_all 
                        : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.blue : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
```

---

## 2. CHALLENGE SYSTEM

### 2.1 Challenge Flow

```
User A (Challenger)            Backend              User B (Opponent)
       │                          │                         │
       │ 1. Create Challenge      │                         │
       ├─────────────────────────>│                         │
       │  POST /api/challenges    │                         │
       │                          │                         │
       │                          │  2. Send Notification   │
       │                          ├────────────────────────>│
       │                          │  (Push + In-app)        │
       │                          │                         │
       │                          │  3. Accept Challenge    │
       │                          │<────────────────────────┤
       │                          │                         │
       │  4. Notify Accepted      │                         │
       │<─────────────────────────┤                         │
       │                          │                         │
       │ 5. Play Game             │  6. Play Game           │
       │  (Record score)          │     (Record score)      │
       │                          │                         │
       │ 7. Submit Score          │                         │
       ├─────────────────────────>│                         │
       │                          │  8. Submit Score        │
       │                          │<────────────────────────┤
       │                          │                         │
       │                          │  9. Calculate Winner    │
       │                          │                         │
       │ 10. Notify Result        │  11. Notify Result      │
       │<─────────────────────────┼────────────────────────>│
```

### 2.2 Data Model

```dart
// lib/models/challenge_model.dart
@HiveType(typeId: 17)
class Challenge {
  @HiveField(0) String id;
  @HiveField(1) String challengerId;
  @HiveField(2) String challengerName;
  @HiveField(3) String opponentId;
  @HiveField(4) String opponentName;
  @HiveField(5) String gameType;         // 'rubik', 'sudoku', 'caro', 'puzzle'
  @HiveField(6) String difficulty;
  @HiveField(7) String status;           // 'pending', 'accepted', 'rejected', 'playing', 'completed'
  @HiveField(8) DateTime createdAt;
  @HiveField(9) DateTime? acceptedAt;
  @HiveField(10) DateTime? completedAt;
  @HiveField(11) DateTime expiresAt;     // Auto-cancel after 24h
  
  // Game results
  @HiveField(12) int? challengerScore;
  @HiveField(13) int? opponentScore;
  @HiveField(14) String? winnerId;
  @HiveField(15) Map<String, dynamic>? challengerGameData;
  @HiveField(16) Map<String, dynamic>? opponentGameData;
}
```

### 2.3 Challenge Service

```dart
// lib/services/challenge_service.dart
class ChallengeService {
  final ApiClient _apiClient;
  
  Future<Challenge> createChallenge({
    required String opponentId,
    required String gameType,
    required String difficulty,
  }) async {
    final response = await _apiClient.post('/challenges/create', body: {
      'opponentId': opponentId,
      'gameType': gameType,
      'difficulty': difficulty,
    });
    
    final challenge = Challenge.fromJson(response.data);
    
    // Save to local DB
    await DatabaseService.challengesBox.put(challenge.id, challenge);
    
    return challenge;
  }
  
  Future<void> acceptChallenge(String challengeId) async {
    await _apiClient.post('/challenges/$challengeId/accept');
    
    final challenge = DatabaseService.challengesBox.get(challengeId);
    challenge!.status = 'accepted';
    challenge.acceptedAt = DateTime.now();
    await DatabaseService.challengesBox.put(challengeId, challenge);
  }
  
  Future<void> submitChallengeScore({
    required String challengeId,
    required int score,
    required Map<String, dynamic> gameData,
  }) async {
    await _apiClient.post('/challenges/$challengeId/submit', body: {
      'score': score,
      'gameData': gameData,
    });
    
    // Update local challenge
    final challenge = DatabaseService.challengesBox.get(challengeId);
    if (challenge != null) {
      final userId = DatabaseService.getUser()!.id;
      if (challenge.challengerId == userId) {
        challenge.challengerScore = score;
        challenge.challengerGameData = gameData;
      } else {
        challenge.opponentScore = score;
        challenge.opponentGameData = gameData;
      }
      
      // Check if both submitted
      if (challenge.challengerScore != null && 
          challenge.opponentScore != null) {
        challenge.status = 'completed';
        challenge.completedAt = DateTime.now();
        challenge.winnerId = _determineWinner(challenge);
      }
      
      await DatabaseService.challengesBox.put(challengeId, challenge);
    }
  }
  
  String _determineWinner(Challenge challenge) {
    if (challenge.challengerScore! > challenge.opponentScore!) {
      return challenge.challengerId;
    } else if (challenge.opponentScore! > challenge.challengerScore!) {
      return challenge.opponentId;
    }
    return 'draw';
  }
  
  List<Challenge> getPendingChallenges() {
    final userId = DatabaseService.getUser()!.id;
    return DatabaseService.challengesBox.values
        .where((c) => c.opponentId == userId && c.status == 'pending')
        .toList();
  }
  
  List<Challenge> getActiveChallenges() {
    final userId = DatabaseService.getUser()!.id;
    return DatabaseService.challengesBox.values
        .where((c) => 
          (c.challengerId == userId || c.opponentId == userId) &&
          (c.status == 'accepted' || c.status == 'playing'))
        .toList();
  }
}
```

### 2.4 Challenge UI

```dart
// lib/screens/challenge/challenge_list_screen.dart
class ChallengeListScreen extends StatefulWidget {
  @override
  _ChallengeListScreenState createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen> {
  List<Challenge> _pendingChallenges = [];
  List<Challenge> _activeChallenges = [];
  
  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }
  
  Future<void> _loadChallenges() async {
    final pending = ChallengeService.instance.getPendingChallenges();
    final active = ChallengeService.instance.getActiveChallenges();
    
    setState(() {
      _pendingChallenges = pending;
      _activeChallenges = active;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Challenges')),
      body: ListView(
        children: [
          if (_pendingChallenges.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pending Challenges (${_pendingChallenges.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ..._pendingChallenges.map(_buildPendingChallengeCard),
          ],
          if (_activeChallenges.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Active Challenges (${_activeChallenges.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ..._activeChallenges.map(_buildActiveChallengeCard),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showCreateChallengeDialog,
      ),
    );
  }
  
  Widget _buildPendingChallengeCard(Challenge challenge) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(challenge.challengerName[0]),
        ),
        title: Text('${challenge.challengerName} challenged you!'),
        subtitle: Text(
          '${_getGameName(challenge.gameType)} - ${challenge.difficulty}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: () => _acceptChallenge(challenge.id),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () => _rejectChallenge(challenge.id),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActiveChallengeCard(Challenge challenge) {
    final userId = DatabaseService.getUser()!.id;
    final isChallenger = challenge.challengerId == userId;
    final opponentName = isChallenger 
        ? challenge.opponentName 
        : challenge.challengerName;
    
    final myScore = isChallenger 
        ? challenge.challengerScore 
        : challenge.opponentScore;
    final opponentScore = isChallenger 
        ? challenge.opponentScore 
        : challenge.challengerScore;
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_getGameIcon(challenge.gameType)),
        ),
        title: Text('vs $opponentName'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_getGameName(challenge.gameType)} - ${challenge.difficulty}'),
            SizedBox(height: 4),
            Row(
              children: [
                Text('You: ${myScore ?? '—'}  '),
                Text('$opponentName: ${opponentScore ?? '—'}'),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          child: Text(myScore == null ? 'Play Now' : 'Waiting...'),
          onPressed: myScore == null 
              ? () => _playChallenge(challenge) 
              : null,
        ),
      ),
    );
  }
  
  Future<void> _acceptChallenge(String challengeId) async {
    await ChallengeService.instance.acceptChallenge(challengeId);
    _loadChallenges();
  }
  
  void _playChallenge(Challenge challenge) {
    // Navigate to game screen with challenge context
    Navigator.pushNamed(
      context,
      '/games/${challenge.gameType}',
      arguments: {
        'challengeId': challenge.id,
        'difficulty': challenge.difficulty,
      },
    );
  }
}
```

---

## 3. FRIEND SYSTEM

### 3.1 Data Model

```dart
@HiveType(typeId: 18)
class Friendship {
  @HiveField(0) String id;
  @HiveField(1) String userId;           // Current user
  @HiveField(2) String friendId;
  @HiveField(3) String friendName;
  @HiveField(4) String? friendAvatar;
  @HiveField(5) String status;           // 'pending', 'accepted', 'blocked'
  @HiveField(6) DateTime createdAt;
  @HiveField(7) DateTime? acceptedAt;
  @HiveField(8) bool isOnline;
}
```

### 3.2 Friend Service

```dart
class FriendService {
  Future<void> sendFriendRequest(String friendId) async {
    await _apiClient.post('/friends/request', body: {'friendId': friendId});
  }
  
  Future<void> acceptFriendRequest(String friendshipId) async {
    await _apiClient.post('/friends/$friendshipId/accept');
  }
  
  List<Friendship> getFriends() {
    return DatabaseService.friendshipsBox.values
        .where((f) => f.status == 'accepted')
        .toList();
  }
  
  Future<List<UserModel>> searchUsers(String query) async {
    final response = await _apiClient.get('/users/search?q=$query');
    return response.data.map((u) => UserModel.fromJson(u)).toList();
  }
}
```

---

## 4. NOTIFICATIONS

### 4.1 Push Notifications (FCM)

```dart
// lib/services/notification_service.dart
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission();
    
    // Get FCM token
    final token = await _fcm.getToken();
    print('FCM Token: $token');
    
    // Send token to backend
    await _apiClient.post('/users/fcm-token', body: {'token': token});
    
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        data: message.data,
      );
    }
  }
  
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Background message: ${message.messageId}');
  }
  
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final notification = LocalNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      payload: jsonEncode(data),
    );
    
    await FlutterLocalNotificationsPlugin().show(
      notification.id,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'game_channel',
          'Game Notifications',
          importance: Importance.high,
        ),
      ),
      payload: notification.payload,
    );
  }
}
```

---

## 📊 IMPLEMENTATION CHECKLIST (THỨ TỰ ƯU TIÊN)

> 🎯 **Chiến lược**: Làm từ cơ bản đến phức tạp

### ✅ PRIORITY 1: Leaderboard (Tuần 7 - BẮT BUỘC)
- [ ] Global leaderboard API endpoint
- [ ] Hiển thị Top 10/50/100 players
- [ ] Filter theo game type
- [ ] Cache local để xem offline
- **Thời gian**: 1-2 ngày

### ✅ PRIORITY 2: Challenge System (Tuần 7 - QUAN TRỌNG)
- [ ] Create Challenge model & API endpoints
- [ ] Implement ChallengeService (đơn giản hóa)
- [ ] Build Challenge list UI (cơ bản)
- [ ] Integrate với game screens (gửi challenge context)
- [ ] Test challenge flow (tối thiểu)
- **Thời gian**: 3-4 ngày

### ⚠️ PRIORITY 3: Friend System (Nếu có thời gian)
- [ ] Basic friend request/accept
- [ ] User search (simple text search)
- [ ] Friend list UI (minimal)
- **Thời gian**: 2-3 ngày

### ❌ PRIORITY 4: Chat System (KHÔNG BẮT BUỘC)
- [ ] ~~Setup WebSocket server~~ - BỎ QUA nếu không kịp
- [ ] ~~Real-time messaging~~ - Thay bằng simple message board
- [ ] ~~Chat UI~~ - Không cần thiết cho đề tài
- **Kết luận**: Chỉ làm khi **DƯ THỜI GIAN**

### 🔔 Push Notifications (Optional)
- [ ] Setup FCM (nếu có thời gian)
- [ ] Báo thông challenge mới
- **Lưu ý**: Không bắt buộc, có thể dùng local notification

---

**Version**: 1.0  
**Last Updated**: 18/12/2025
