# 🏗️ BACKEND ARCHITECTURE DESIGN - OFFLINE-FIRST

> ⚠️ **CẢNH BÁO**: Viết Sync thủ công cực kỳ dễ sinh bug!
> 🎯 **Chiến lược**: Giữ logic đơn giản nhất - **Server luôn thắng**

**Dự án**: Game Mobile - TruongHieuHuy  
**Ngày**: 18/12/2025  
**Mục tiêu**: Thiết kế kiến trúc Offline-First với Backend Sync (Version ĐƠN GIẢN HÓA)

---

## 📋 MỤC LỤC
1. [Tổng quan kiến trúc](#1-tổng-quan-kiến-trúc)
2. [Database Schema](#2-database-schema)
3. [Sync Strategy](#3-sync-strategy)
4. [API Endpoints](#4-api-endpoints)
5. [Implementation Guide](#5-implementation-guide)

---

## 1. TỔNG QUAN KIẾN TRÚC

### 1.1 Architectural Pattern: Offline-First

```
┌────────────────────────────────────────────────────────┐
│                    FLUTTER APP                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │              UI Layer (Widgets)                   │  │
│  └───────────────────┬──────────────────────────────┘  │
│                      │                                  │
│  ┌───────────────────▼──────────────────────────────┐  │
│  │         State Management (Provider)               │  │
│  └───────────────────┬──────────────────────────────┘  │
│                      │                                  │
│  ┌───────────────────▼──────────────────────────────┐  │
│  │          Business Logic Layer                     │  │
│  │  ┌─────────────┐  ┌──────────────┐              │  │
│  │  │Game Services│  │ Sync Manager  │              │  │
│  │  └─────────────┘  └──────────────┘              │  │
│  └────────┬─────────────────────┬───────────────────┘  │
│           │                     │                       │
│  ┌────────▼────────┐   ┌───────▼────────┐             │
│  │  Local Storage  │   │  API Client     │             │
│  │  (Hive NoSQL)   │   │  (HTTP + WS)    │             │
│  └─────────────────┘   └────────┬────────┘             │
└──────────────────────────────────┼────────────────────-┘
                                   │
                        ┌──────────▼───────────┐
                        │   INTERNET (WiFi)    │
                        └──────────┬───────────┘
                                   │
┌──────────────────────────────────▼────────────────────┐
│                   BACKEND SERVER                       │
│  ┌─────────────────────────────────────────────────┐  │
│  │              API Gateway (Express.js)            │  │
│  └────┬─────────────────────────────────┬──────────┘  │
│       │                                 │              │
│  ┌────▼──────────┐            ┌────────▼─────────┐   │
│  │  REST API     │            │  WebSocket (WS)   │   │
│  │  (CRUD ops)   │            │  (Real-time)      │   │
│  └────┬──────────┘            └────────┬─────────┘   │
│       │                                 │              │
│  ┌────▼─────────────────────────────────▼─────────┐   │
│  │         Business Logic Layer (Services)         │   │
│  │  - GameService  - UserService  - SyncService   │   │
│  │  - ChatService  - ChallengeService              │   │
│  └─────────────────────┬───────────────────────────┘   │
│                        │                               │
│  ┌─────────────────────▼───────────────────────────┐   │
│  │        MongoDB (Database)                        │   │
│  │  Collections: users, games, scores, chats,      │   │
│  │               challenges, sync_queue             │   │
│  └──────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────┘
```

### 1.2 Key Principles

1. **Local First**: App hoạt động 100% offline
2. **Background Sync**: Tự động sync khi có mạng
3. **Conflict Resolution**: Last-Write-Wins + Custom logic
4. **Optimistic UI**: Update UI ngay, sync sau
5. **Queue Management**: Queue failed syncs để retry

---

## 2. DATABASE SCHEMA

### 2.1 Local Database (Hive) - Enhanced Schema

#### **GameScore Model** (Updated)
```dart
@HiveType(typeId: 3)
class GameScoreModel {
  @HiveField(0) String id;               // UUID
  @HiveField(1) String userId;           // User ID (NEW)
  @HiveField(2) String gameType;         // 'rubik', 'sudoku', 'caro', 'puzzle'
  @HiveField(3) int score;
  @HiveField(4) int attempts;
  @HiveField(5) DateTime timestamp;
  @HiveField(6) String difficulty;
  @HiveField(7) int timeSpent;
  
  // Sync metadata (NEW)
  @HiveField(8) bool isSynced;           // Đã sync lên server chưa?
  @HiveField(9) DateTime? lastSynced;    // Lần sync cuối
  @HiveField(10) String syncStatus;      // 'pending', 'synced', 'failed'
  @HiveField(11) int version;            // Version cho conflict resolution
  @HiveField(12) String? conflictData;   // JSON data nếu có conflict
}
```

#### **User Model** (NEW)
```dart
@HiveType(typeId: 12)
class UserModel {
  @HiveField(0) String id;               // Server-generated ID
  @HiveField(1) String username;
  @HiveField(2) String email;
  @HiveField(3) String? avatarUrl;
  @HiveField(4) DateTime createdAt;
  @HiveField(5) DateTime lastLoginAt;
  
  // Auth
  @HiveField(6) String? accessToken;
  @HiveField(7) String? refreshToken;
  @HiveField(8) DateTime? tokenExpiry;
  
  // Stats
  @HiveField(9) int totalGamesPlayed;
  @HiveField(10) int totalScore;
  @HiveField(11) List<String> unlockedAchievements;
}
```

#### **SyncQueue Model** (NEW)
```dart
@HiveType(typeId: 13)
class SyncQueueItem {
  @HiveField(0) String id;               // UUID
  @HiveField(1) String operation;        // 'CREATE', 'UPDATE', 'DELETE'
  @HiveField(2) String entityType;       // 'GameScore', 'Achievement', etc.
  @HiveField(3) String entityId;         // ID của entity cần sync
  @HiveField(4) String jsonData;         // Serialized entity data
  @HiveField(5) DateTime createdAt;
  @HiveField(6) int retryCount;          // Số lần retry
  @HiveField(7) String status;           // 'pending', 'processing', 'failed'
  @HiveField(8) String? error;           // Error message nếu failed
}
```

### 2.2 Backend Database (MongoDB) - Schema

#### **Users Collection**
```javascript
{
  _id: ObjectId,
  username: String,          // Unique
  email: String,             // Unique
  passwordHash: String,      // bcrypt hash
  avatarUrl: String?,
  createdAt: Date,
  lastLoginAt: Date,
  
  // Stats
  totalGamesPlayed: Number,
  totalScore: Number,
  achievements: [String],    // Array of achievement IDs
  
  // Social
  friends: [ObjectId],       // Array of user IDs
  blockedUsers: [ObjectId],
  
  // Metadata
  deviceId: String?,
  fcmToken: String?,         // For push notifications
}
```

#### **GameScores Collection**
```javascript
{
  _id: ObjectId,
  userId: ObjectId,          // Ref to Users
  gameType: String,          // 'rubik', 'sudoku', 'caro', 'puzzle'
  score: Number,
  attempts: Number,
  difficulty: String,
  timeSpent: Number,
  timestamp: Date,
  
  // Game-specific data
  gameData: {
    // Rubik: moves[], finalState
    // Sudoku: solution, hints used
    // Caro: boardSize, opponent (AI/human)
    // Puzzle: pieces, completionRate
  },
  
  // Sync metadata
  version: Number,           // For optimistic locking
  lastModified: Date,
  createdBy: String,         // 'mobile_app' or 'web'
}
```

#### **Achievements Collection**
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  achievementId: String,     // 'first_win', 'rubik_master', etc.
  unlockedAt: Date,
  progress: Number,          // 0-100 (for progressive achievements)
  
  // Sync
  version: Number,
  lastModified: Date,
}
```

#### **ChatMessages Collection**
```javascript
{
  _id: ObjectId,
  roomId: String,            // 'user1_user2' or 'challenge_123'
  senderId: ObjectId,
  receiverId: ObjectId?,     // Null for group chats
  message: String,
  messageType: String,       // 'text', 'image', 'game_invite'
  timestamp: Date,
  isRead: Boolean,
  
  // Attachments
  attachments: [{
    type: String,            // 'image', 'game_result'
    url: String,
    metadata: Object,
  }],
}
```

#### **Challenges Collection**
```javascript
{
  _id: ObjectId,
  challengerId: ObjectId,
  opponentId: ObjectId,
  gameType: String,
  difficulty: String,
  status: String,            // 'pending', 'accepted', 'rejected', 'completed'
  
  // Game state
  gameState: Object,         // Game-specific state
  challengerScore: Number?,
  opponentScore: Number?,
  winner: ObjectId?,
  
  // Timestamps
  createdAt: Date,
  acceptedAt: Date?,
  completedAt: Date?,
  expiresAt: Date,           // Auto-cancel after 24h
}
```

#### **SyncLog Collection** (For debugging)
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  operation: String,         // 'PULL', 'PUSH'
  entityType: String,
  entityId: String,
  status: String,            // 'success', 'conflict', 'error'
  conflictResolution: String?, // 'server_win', 'client_win', 'merged'
  timestamp: Date,
  errorMessage: String?,
}
```

---

## 3. SYNC STRATEGY

### 3.1 Sync Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    SYNC LIFECYCLE                        │
└─────────────────────────────────────────────────────────┘

USER ACTION (e.g., Finish game)
    │
    ▼
┌──────────────────────────┐
│ 1. Save to Local Hive    │  ← Instant, offline-first
│    isSynced = false      │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ 2. Add to SyncQueue      │  ← Queue for background sync
│    operation = 'CREATE'  │
└──────────┬───────────────┘
           │
           ▼
     [Has Internet?]
           │
     ┌─────┴─────┐
    YES          NO
     │            │
     │            ▼
     │     ┌──────────────────┐
     │     │ Wait for network │
     │     │ (Background job) │
     │     └──────────────────┘
     │
     ▼
┌──────────────────────────┐
│ 3. POST to Backend API   │
│    /api/scores/sync      │
└──────────┬───────────────┘
           │
     ┌─────┴─────┐
   Success     Conflict
     │            │
     ▼            ▼
┌─────────┐  ┌──────────────────────┐
│Update   │  │ 4. Conflict Resolution│
│Local:   │  │    - Compare versions │
│isSynced │  │    - Apply strategy   │
│= true   │  │    - Update local DB  │
└─────────┘  └──────────────────────┘
```

### 3.2 Conflict Resolution Strategies

> ⚠️ **QUAN TRỌNG**: ĐừNG làm phức tạp! Chỉ dùng Strategy 1 cho dự án này.

#### **Strategy 1: Last-Write-Wins (RECOMMENDED - Duy nhất cần dùng)**
✅ **Ưu điểm**: Simple, stable, dễ debug  
✅ **Logic**: Server timestamp luôn thắng  
✅ **Phù hợp**: 90% trường hợp game mobile  

```dart
class ConflictResolver {
  static T resolve<T>(T localData, T serverData) {
    // SIMPLE: Server always wins
    return serverData;
    
    // OR: Last modified wins
    // if (serverData.lastModified.isAfter(localData.lastModified)) {
    //   return serverData;
    // }
    // return localData;
  }
}
```

#### **❌ Strategy 2: Version-Based (KHÔNG khuyến khích)**
⚠️ **Rủi ro**: Phức tạp, dễ sinh bug khi network unstable  
⚠️ **Khi nào dùng**: Chỉ khi **DƯ THỜI GIAN** sau khi hoàn thành 4 game  

```javascript
// Backend logic (KHÔNG cần implement giai đoạn đầu)
if (clientVersion !== serverVersion) {
  return {
    status: 'conflict',
    serverData: currentData,
    clientData: incomingData
  };
}
```

#### **❌ Strategy 3: Field-Level Merge (KHÔNG LÀM)**
⚠️ **Rủi ro**: Quá phức tạp, dễ sinh bug logic  
⚠️ **Kết luận**: **BỎ QUA** hoàn toàn cho dự án này  

~~Field-Level Merge code removed to avoid confusion~~

### 3.3 Sync Manager Implementation

```dart
class SyncManager {
  final ApiClient _apiClient;
  final Box<SyncQueueItem> _syncQueue;
  Timer? _syncTimer;

  // Start background sync every 30 seconds
  void startPeriodicSync() {
    _syncTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => syncAll(),
    );
  }

  Future<void> syncAll() async {
    if (!await _hasInternet()) return;

    final pendingItems = _syncQueue.values
        .where((item) => item.status == 'pending')
        .toList();

    for (var item in pendingItems) {
      try {
        await _syncItem(item);
      } catch (e) {
        item.retryCount++;
        item.status = 'failed';
        item.error = e.toString();
        await _syncQueue.put(item.id, item);
      }
    }
  }

  Future<void> _syncItem(SyncQueueItem item) async {
    switch (item.operation) {
      case 'CREATE':
        await _apiClient.post('/sync', body: item.jsonData);
        break;
      case 'UPDATE':
        await _apiClient.put('/sync/${item.entityId}', body: item.jsonData);
        break;
      case 'DELETE':
        await _apiClient.delete('/sync/${item.entityId}');
        break;
    }

    // Mark as synced
    item.status = 'synced';
    await _syncQueue.put(item.id, item);
  }

  Future<bool> _hasInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity != ConnectivityResult.none;
  }
}
```

---

## 4. API ENDPOINTS

### 4.1 Authentication APIs

```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/refresh-token
POST   /api/auth/logout
GET    /api/auth/me
```

### 4.2 Game APIs

```
POST   /api/games/scores         # Create new score
GET    /api/games/scores         # Get user's scores
GET    /api/games/leaderboard    # Global leaderboard
POST   /api/games/sync           # Bulk sync scores
```

### 4.3 Achievement APIs

```
GET    /api/achievements         # Get all achievements
POST   /api/achievements/unlock  # Unlock achievement
GET    /api/achievements/progress # Get progress
```

### 4.4 Social APIs

```
POST   /api/chat/send            # Send message
GET    /api/chat/messages/:roomId # Get messages
WS     /api/chat/connect         # WebSocket for real-time

POST   /api/challenges/create    # Create challenge
POST   /api/challenges/:id/accept
GET    /api/challenges/pending   # Get pending challenges
```

### 4.5 Sync APIs

```
POST   /api/sync/pull            # Pull server changes
POST   /api/sync/push            # Push local changes
GET    /api/sync/status          # Check sync status
```

---

## 5. IMPLEMENTATION GUIDE

> 🚨 **LUÔN GHI NHớ**: "Done is better than perfect" - Hoàn thành cơ bản trước khi tối ưu

### 5.1 Phase 1: Backend Setup (Week 1 - Cơ bản nhất)

**Step 1**: Setup Node.js project
```bash
mkdir game-backend
cd game-backend
npm init -y
npm install express mongoose socket.io bcrypt jsonwebtoken
```

**Step 2**: Create server structure
```
backend/
├── src/
│   ├── models/         # Mongoose models
│   ├── routes/         # API routes
│   ├── controllers/    # Business logic
│   ├── middleware/     # Auth, validation
│   ├── services/       # Sync service, etc.
│   └── config/         # DB config, env
├── server.js
└── package.json
```

**Step 3**: Implement Authentication
```javascript
// middleware/auth.js
const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  if (!token) return res.status(401).send('Access denied');
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(400).send('Invalid token');
  }
};
```

### 5.2 Phase 2: Flutter Integration (Week 3)

**Step 1**: Add dependencies
```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
  web_socket_channel: ^2.4.0
  connectivity_plus: ^5.0.0
  workmanager: ^0.5.0  # For background sync
```

**Step 2**: Create API Client
```dart
// lib/services/api_client.dart
class ApiClient {
  static const baseUrl = 'https://your-api.com/api';
  final http.Client _client = http.Client();

  Future<Response> post(String path, {required String body}) async {
    final token = await _getToken();
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    return response;
  }

  Future<String> _getToken() async {
    final user = DatabaseService.getUser();
    return user?.accessToken ?? '';
  }
}
```

**Step 3**: Implement SyncManager (as shown in 3.3)

### 5.3 Phase 3: Testing (Week 6-7 - Chỉ khi có thời gian)

**Unit Tests**:
```dart
test('SyncManager should queue operations offline', () async {
  final syncManager = SyncManager();
  await syncManager.addToQueue(
    operation: 'CREATE',
    entityType: 'GameScore',
    data: testScore,
  );
  
  expect(syncManager.queueLength, 1);
});
```

**Integration Tests**:
- Test sync flow end-to-end
- Test conflict resolution
- Test offline → online transition

---

## 📎 NEXT STEPS

1. ✅ Review this architecture design
2. ⏭️ Read [GAME_IMPLEMENTATION_PLAN.md](GAME_IMPLEMENTATION_PLAN.md)
3. ⏭️ Read [SOCIAL_FEATURES_DESIGN.md](SOCIAL_FEATURES_DESIGN.md)
4. 🚀 Start implementation

---

**Version**: 1.0  
**Last Updated**: 18/12/2025
