# 🧪 API TESTING GUIDE - Hướng dẫn test với Postman

---

## 📥 SETUP POSTMAN

### 1. Import Collection
File có sẵn: `Backend_MiniGameCenter/API_Testing.postman_collection.json`

```bash
# In Postman:
File → Import → Select file → Import
```

### 2. Setup Environment Variables

Tạo environment mới: **MiniGameCenter - Local**

| Variable | Value | Description |
|----------|-------|-------------|
| base_url | http://localhost:3000 | Backend URL |
| token_user1 | (empty) | User 1 token |
| token_user2 | (empty) | User 2 token |
| token_admin | (empty) | Admin token |
| user1_id | (empty) | User 1 ID |
| user2_id | (empty) | User 2 ID |
| post_id | (empty) | Test post ID |
| challenge_id | (empty) | Test challenge ID |

---

## 🔐 AUTHENTICATION FLOW

### Test 1: Register Users

#### Request 1.1: Register User 1
```
POST {{base_url}}/api/auth/register

Body (JSON):
{
  "username": "testuser1",
  "email": "testuser1@example.com",
  "password": "password123"
}

Expected Response (201):
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": {
      "id": "uuid-here",
      "username": "testuser1",
      "email": "testuser1@example.com",
      "role": "USER",
      "createdAt": "2026-01-01T..."
    },
    "token": "jwt-token-here"
  }
}

Post-script:
pm.environment.set("token_user1", pm.response.json().data.token);
pm.environment.set("user1_id", pm.response.json().data.user.id);
```

#### Request 1.2: Register User 2
```
POST {{base_url}}/api/auth/register

Body (JSON):
{
  "username": "testuser2",
  "email": "testuser2@example.com",
  "password": "password123"
}

Post-script:
pm.environment.set("token_user2", pm.response.json().data.token);
pm.environment.set("user2_id", pm.response.json().data.user.id);
```

#### Request 1.3: Register Admin (First User)
**Note:** Chỉ chạy khi database trống (first user = ADMIN)

```
POST {{base_url}}/api/auth/register

Body:
{
  "username": "admin",
  "email": "admin@example.com",
  "password": "admin123"
}

Expected role: "ADMIN"

Post-script:
pm.environment.set("token_admin", pm.response.json().data.token);
```

---

### Test 2: Login

```
POST {{base_url}}/api/auth/login

Body:
{
  "email": "testuser1@example.com",
  "password": "password123"
}

Expected Response (200):
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "...",
      "username": "testuser1",
      "email": "testuser1@example.com",
      "role": "USER",
      "avatarUrl": null,
      "totalGamesPlayed": 0,
      "totalScore": 0
    },
    "token": "jwt-token"
  }
}

Tests:
pm.test("Status is 200", () => pm.response.to.have.status(200));
pm.test("Returns token", () => pm.expect(pm.response.json().data.token).to.be.a('string'));
```

---

### Test 3: Get Current User

```
GET {{base_url}}/api/auth/me

Headers:
Authorization: Bearer {{token_user1}}

Expected Response (200):
{
  "success": true,
  "data": {
    "user": {
      "id": "...",
      "username": "testuser1",
      ...
    }
  }
}
```

---

### Test 4: Forgot & Reset Password

#### 4.1: Request Reset Token
```
POST {{base_url}}/api/auth/forgot-password

Body:
{
  "email": "testuser1@example.com"
}

Response (200):
{
  "success": true,
  "message": "If email exists, a reset token has been generated",
  "resetToken": "123456"  // Only in dev mode
}

Note: Trong production, token gửi qua email
```

#### 4.2: Reset Password
```
POST {{base_url}}/api/auth/reset-password

Body:
{
  "email": "testuser1@example.com",
  "resetToken": "123456",
  "newPassword": "newpassword123"
}

Expected (200):
{
  "success": true,
  "message": "Password reset successful"
}
```

---

## 🎮 GAME SCORES FLOW

### Test 5: Submit Game Score

```
POST {{base_url}}/api/scores

Headers:
Authorization: Bearer {{token_user1}}

Body:
{
  "gameType": "guess_number",
  "score": 8500,
  "difficulty": "hard",
  "attempts": 3,
  "timeSpent": 120
}

Expected (201):
{
  "success": true,
  "message": "Score saved successfully",
  "data": {
    "score": {
      "id": "...",
      "userId": "...",
      "gameType": "guess_number",
      "score": 8500,
      "difficulty": "hard",
      ...
    }
  }
}

Tests:
pm.test("Score saved", () => pm.response.to.have.status(201));
pm.test("Score is correct", () => {
  pm.expect(pm.response.json().data.score.score).to.equal(8500);
});
```

---

### Test 6: Get User Scores

```
GET {{base_url}}/api/scores?gameType=guess_number&limit=10

Headers:
Authorization: Bearer {{token_user1}}

Expected (200):
{
  "success": true,
  "data": {
    "scores": [
      {
        "id": "...",
        "score": 8500,
        "gameType": "guess_number",
        "difficulty": "hard",
        ...
      }
    ],
    "total": 1
  }
}
```

---

### Test 7: Get Leaderboard

```
GET {{base_url}}/api/scores/leaderboard?gameType=guess_number&difficulty=hard&limit=10

Expected (200):
{
  "success": true,
  "data": {
    "leaderboard": [
      {
        "id": "...",
        "username": "testuser1",
        "score": 8500,
        "rank": 1,
        ...
      }
    ]
  }
}

Tests:
pm.test("Leaderboard returned", () => {
  pm.expect(pm.response.json().data.leaderboard).to.be.an('array');
});
pm.test("Sorted by score desc", () => {
  const scores = pm.response.json().data.leaderboard.map(s => s.score);
  for (let i = 0; i < scores.length - 1; i++) {
    pm.expect(scores[i]).to.be.at.least(scores[i+1]);
  }
});
```

---

### Test 8: Get User Stats

```
GET {{base_url}}/api/scores/stats

Headers:
Authorization: Bearer {{token_user1}}

Expected (200):
{
  "success": true,
  "data": {
    "statsByGame": [
      {
        "gameType": "guess_number",
        "totalGames": 1,
        "highScore": 8500,
        "avgScore": 8500
      }
    ],
    "overallStats": {
      "totalGames": 1,
      "totalScore": 8500,
      "avgScore": 8500
    }
  }
}
```

---

## 👥 FRIENDS FLOW

### Test 9: Search Users

```
GET {{base_url}}/api/friends/search?query=testuser2

Headers:
Authorization: Bearer {{token_user1}}

Expected (200):
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "{{user2_id}}",
        "username": "testuser2",
        "avatarUrl": null
      }
    ]
  }
}
```

---

### Test 10: Send Friend Request

```
POST {{base_url}}/api/friends/request

Headers:
Authorization: Bearer {{token_user1}}

Body:
{
  "receiverId": "{{user2_id}}",
  "message": "Let's be friends!"
}

Expected (201):
{
  "success": true,
  "message": "Friend request sent",
  "data": {
    "request": {
      "id": "...",
      "senderId": "{{user1_id}}",
      "receiverId": "{{user2_id}}",
      "status": "pending",
      ...
    }
  }
}

Post-script:
pm.environment.set("friend_request_id", pm.response.json().data.request.id);
```

---

### Test 11: Get Friend Requests (User 2)

```
GET {{base_url}}/api/friends/requests

Headers:
Authorization: Bearer {{token_user2}}

Expected (200):
{
  "success": true,
  "data": {
    "requests": [
      {
        "id": "...",
        "sender": {
          "id": "{{user1_id}}",
          "username": "testuser1"
        },
        "status": "pending",
        "message": "Let's be friends!",
        ...
      }
    ]
  }
}
```

---

### Test 12: Accept Friend Request

```
POST {{base_url}}/api/friends/accept/{{friend_request_id}}

Headers:
Authorization: Bearer {{token_user2}}

Expected (200):
{
  "success": true,
  "message": "Friend request accepted",
  "data": {
    "friendship": {
      "id": "...",
      "userId1": "...",
      "userId2": "...",
      ...
    }
  }
}
```

---

### Test 13: Get Friends List

```
GET {{base_url}}/api/friends

Headers:
Authorization: Bearer {{token_user1}}

Expected (200):
{
  "success": true,
  "data": {
    "friends": [
      {
        "id": "{{user2_id}}",
        "username": "testuser2",
        "avatarUrl": null,
        "totalScore": 0,
        "isFriend": true
      }
    ]
  }
}
```

---

## 💬 MESSAGES FLOW

### Test 14: Send Message

```
POST {{base_url}}/api/messages

Headers:
Authorization: Bearer {{token_user1}}

Body:
{
  "receiverId": "{{user2_id}}",
  "content": "Hey! How are you?"
}

Expected (201):
{
  "success": true,
  "message": "Message sent",
  "data": {
    "message": {
      "id": "...",
      "senderId": "{{user1_id}}",
      "receiverId": "{{user2_id}}",
      "content": "Hey! How are you?",
      "isRead": false,
      "sentAt": "..."
    }
  }
}
```

---

### Test 15: Get Messages with Friend

```
GET {{base_url}}/api/messages/{{user2_id}}?limit=20

Headers:
Authorization: Bearer {{token_user1}}

Expected (200):
{
  "success": true,
  "data": {
    "messages": [
      {
        "id": "...",
        "senderId": "{{user1_id}}",
        "receiverId": "{{user2_id}}",
        "content": "Hey! How are you?",
        "isRead": false,
        "sentAt": "..."
      }
    ],
    "total": 1
  }
}
```

---

### Test 16: Get Conversations List

```
GET {{base_url}}/api/messages/conversations/list

Headers:
Authorization: Bearer {{token_user2}}

Expected (200):
{
  "success": true,
  "data": {
    "conversations": [
      {
        "friendId": "{{user1_id}}",
        "friend": {
          "id": "{{user1_id}}",
          "username": "testuser1",
          "avatarUrl": null
        },
        "lastMessage": {
          "content": "Hey! How are you?",
          "sentAt": "...",
          "isRead": false
        },
        "unreadCount": 1
      }
    ]
  }
}
```

---

## 📝 POSTS FLOW

### Test 17: Create Post

```
POST {{base_url}}/api/posts

Headers:
Authorization: Bearer {{token_user1}}

Body:
{
  "content": "Just beat the hard level in Guess Number! 🎉",
  "category": "guess_number",
  "visibility": "public"
}

Expected (201):
{
  "success": true,
  "message": "Post created",
  "data": {
    "post": {
      "id": "...",
      "userId": "{{user1_id}}",
      "content": "Just beat the hard level...",
      "category": "guess_number",
      "visibility": "public",
      "likeCount": 0,
      "commentCount": 0,
      ...
    }
  }
}

Post-script:
pm.environment.set("post_id", pm.response.json().data.post.id);
```

---

### Test 18: Get Posts Feed

```
GET {{base_url}}/api/posts?limit=20&category=guess_number

Headers:
Authorization: Bearer {{token_user2}}

Expected (200):
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "{{post_id}}",
        "user": {
          "id": "{{user1_id}}",
          "username": "testuser1"
        },
        "content": "Just beat the hard level...",
        "likeCount": 0,
        "commentCount": 0,
        "hasLiked": false,
        "hasSaved": false,
        ...
      }
    ],
    "total": 1
  }
}
```

---

### Test 19: Like Post

```
POST {{base_url}}/api/posts/{{post_id}}/like

Headers:
Authorization: Bearer {{token_user2}}

Expected (200):
{
  "success": true,
  "message": "Post liked",
  "data": {
    "liked": true
  }
}

Tests:
pm.test("Post liked", () => {
  pm.expect(pm.response.json().data.liked).to.be.true;
});
```

---

### Test 20: Comment on Post

```
POST {{base_url}}/api/posts/{{post_id}}/comments

Headers:
Authorization: Bearer {{token_user2}}

Body:
{
  "content": "Congrats! That's awesome! 👏"
}

Expected (201):
{
  "success": true,
  "message": "Comment added",
  "data": {
    "comment": {
      "id": "...",
      "postId": "{{post_id}}",
      "userId": "{{user2_id}}",
      "content": "Congrats! That's awesome! 👏",
      ...
    }
  }
}
```

---

### Test 21: Save Post

```
POST {{base_url}}/api/posts/{{post_id}}/save

Headers:
Authorization: Bearer {{token_user2}}

Expected (200):
{
  "success": true,
  "message": "Post saved",
  "data": {
    "saved": true
  }
}
```

---

### Test 22: Get Saved Posts

```
GET {{base_url}}/api/posts/saved/list?limit=20

Headers:
Authorization: Bearer {{token_user2}}

Expected (200):
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "{{post_id}}",
        "content": "Just beat the hard level...",
        "savedAt": "...",
        ...
      }
    ]
  }
}
```

---

## 🏆 ACHIEVEMENTS FLOW

### Test 23: Get All Achievements

```
GET {{base_url}}/api/achievements

Expected (200):
{
  "success": true,
  "data": {
    "achievements": [
      {
        "id": "...",
        "name": "First Game",
        "description": "Play your first game",
        "icon": "🎮",
        "category": "general",
        "points": 10,
        "requirement": {
          "type": "total_games",
          "value": 1
        }
      },
      // ... more achievements
    ]
  }
}
```

---

### Test 24: Get User Achievements

```
GET {{base_url}}/api/achievements/user/{{user1_id}}

Expected (200):
{
  "success": true,
  "data": {
    "achievements": [
      {
        "id": "...",
        "name": "First Game",
        "description": "Play your first game",
        "progress": 100,
        "isUnlocked": true,
        "unlockedAt": "2026-01-01T..."
      },
      {
        "id": "...",
        "name": "High Scorer",
        "description": "Reach 5000 points",
        "progress": 85,
        "isUnlocked": false,
        "unlockedAt": null
      }
    ],
    "stats": {
      "total": 20,
      "unlocked": 3,
      "totalPoints": 30
    }
  }
}
```

---

### Test 25: Check Achievements (Trigger Unlock)

```
POST {{base_url}}/api/achievements/check

Headers:
Authorization: Bearer {{token_user1}}

Expected (200):
{
  "success": true,
  "message": "Achievements checked",
  "data": {
    "newlyUnlocked": [
      {
        "id": "...",
        "name": "First Game",
        "points": 10
      }
    ]
  }
}

Tests:
pm.test("New achievements unlocked", () => {
  pm.expect(pm.response.json().data.newlyUnlocked).to.be.an('array');
});
```

---

## 🎯 CHALLENGE FLOW (NEW)

### Test 26: Create Challenge

```
POST {{base_url}}/api/challenges

Headers:
Authorization: Bearer {{token_user1}}

Body:
{
  "targetId": "{{user2_id}}"
}

Expected (201):
{
  "success": true,
  "message": "Challenge created",
  "data": {
    "challenge": {
      "id": "...",
      "initiatorId": "{{user1_id}}",
      "targetId": "{{user2_id}}",
      "status": "pending",
      "currentGame": 1,
      ...
    }
  }
}

Post-script:
pm.environment.set("challenge_id", pm.response.json().data.challenge.id);
```

---

### Test 27: Get Pending Challenges

```
GET {{base_url}}/api/challenges/pending

Headers:
Authorization: Bearer {{token_user2}}

Expected (200):
{
  "success": true,
  "data": {
    "challenges": [
      {
        "id": "{{challenge_id}}",
        "initiator": {
          "id": "{{user1_id}}",
          "username": "testuser1"
        },
        "status": "pending",
        "createdAt": "..."
      }
    ]
  }
}
```

---

### Test 28: Accept Challenge

```
POST {{base_url}}/api/challenges/{{challenge_id}}/accept

Headers:
Authorization: Bearer {{token_user2}}

Expected (200):
{
  "success": true,
  "message": "Challenge accepted",
  "data": {
    "challenge": {
      "id": "{{challenge_id}}",
      "status": "voting1",
      ...
    }
  }
}
```

---

### Test 29: Vote for Game (User 1)

```
POST {{base_url}}/api/challenges/{{challenge_id}}/vote

Headers:
Authorization: Bearer {{token_user1}}

Body:
{
  "gameType": "guess_number"
}

Expected (200):
{
  "success": true,
  "message": "Vote recorded",
  "data": {
    "challenge": {
      "game1InitiatorVote": "guess_number",
      "status": "voting1"  // Still voting until both vote
    }
  }
}
```

---

### Test 30: Vote for Game (User 2)

```
POST {{base_url}}/api/challenges/{{challenge_id}}/vote

Headers:
Authorization: Bearer {{token_user2}}

Body:
{
  "gameType": "guess_number"
}

Expected (200):
{
  "success": true,
  "message": "Both voted, game selected",
  "data": {
    "challenge": {
      "game1Type": "guess_number",  // Same vote
      "status": "playing1"          // Changed to playing
    }
  }
}
```

---

### Test 31: Submit Game Score (User 1)

```
POST {{base_url}}/api/challenges/{{challenge_id}}/submit-score

Headers:
Authorization: Bearer {{token_user1}}

Body:
{
  "gameNumber": 1,
  "score": 8500
}

Expected (200):
{
  "success": true,
  "message": "Score submitted",
  "data": {
    "challenge": {
      "game1InitiatorScore": 8500,
      "status": "playing1"  // Still playing until both submit
    }
  }
}
```

---

### Test 32: Submit Game Score (User 2)

```
POST {{base_url}}/api/challenges/{{challenge_id}}/submit-score

Headers:
Authorization: Bearer {{token_user2}}

Body:
{
  "gameNumber": 1,
  "score": 7200
}

Expected (200):
{
  "success": true,
  "message": "Game 1 completed",
  "data": {
    "challenge": {
      "game1TargetScore": 7200,
      "initiatorScore": 1,  // User 1 wins
      "targetScore": 0,
      "status": "voting2",  // Move to game 2
      "currentGame": 2
    }
  }
}
```

---

### Test 33: Get Challenge History

```
GET {{base_url}}/api/challenges/history?limit=10

Headers:
Authorization: Bearer {{token_user1}}

Expected (200):
{
  "success": true,
  "data": {
    "challenges": [
      {
        "id": "{{challenge_id}}",
        "initiator": { ... },
        "target": { ... },
        "status": "voting2",
        "initiatorScore": 1,
        "targetScore": 0,
        ...
      }
    ],
    "total": 1
  }
}
```

---

## 👑 ADMIN FLOW

### Test 34: Get Admin Stats

```
GET {{base_url}}/api/admin/stats

Headers:
Authorization: Bearer {{token_admin}}

Expected (200):
{
  "success": true,
  "data": {
    "totalUsers": 3,
    "totalGames": 5,
    "totalPosts": 1,
    "totalAchievements": 15,
    "activePlayers": 2,
    "gamesByType": {
      "guess_number": 3,
      "cows_bulls": 2
    }
  }
}

Tests:
pm.test("Has admin access", () => pm.response.to.have.status(200));
pm.test("Returns stats", () => {
  pm.expect(pm.response.json().data.totalUsers).to.be.a('number');
});
```

---

### Test 35: Get Users (Admin)

```
GET {{base_url}}/api/admin/users?page=1&limit=20&search=testuser

Headers:
Authorization: Bearer {{token_admin}}

Expected (200):
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "{{user1_id}}",
        "username": "testuser1",
        "email": "testuser1@example.com",
        "role": "USER",
        "totalGamesPlayed": 5,
        "totalScore": 42500,
        "createdAt": "...",
        "lastLoginAt": "..."
      }
    ],
    "total": 2,
    "page": 1,
    "limit": 20
  }
}
```

---

### Test 36: Ban User

```
POST {{base_url}}/api/admin/users/{{user1_id}}/ban

Headers:
Authorization: Bearer {{token_admin}}

Body:
{
  "reason": "Spam behavior"
}

Expected (200):
{
  "success": true,
  "message": "User banned"
}

Tests:
pm.test("User banned", () => pm.response.to.have.status(200));
```

---

### Test 37: Try Banned User Login (Should Fail)

```
POST {{base_url}}/api/auth/login

Body:
{
  "email": "testuser1@example.com",
  "password": "password123"
}

Expected (403):
{
  "success": false,
  "message": "Account is banned: Spam behavior"
}

Tests:
pm.test("Login blocked", () => pm.response.to.have.status(403));
```

---

### Test 38: Unban User

```
POST {{base_url}}/api/admin/users/{{user1_id}}/unban

Headers:
Authorization: Bearer {{token_admin}}

Expected (200):
{
  "success": true,
  "message": "User unbanned"
}
```

---

### Test 39: Delete Post (Admin)

```
DELETE {{base_url}}/api/admin/posts/{{post_id}}

Headers:
Authorization: Bearer {{token_admin}}

Expected (200):
{
  "success": true,
  "message": "Post deleted"
}
```

---

## 🔄 FULL INTEGRATION TEST SEQUENCE

**Run in order:**

1. ✅ Register 3 users (User1, User2, Admin)
2. ✅ Login all users
3. ✅ Submit game scores (User1, User2)
4. ✅ Check leaderboard
5. ✅ User1 sends friend request to User2
6. ✅ User2 accepts
7. ✅ User1 sends message to User2
8. ✅ User2 reads message
9. ✅ User1 creates post
10. ✅ User2 likes and comments
11. ✅ Check achievements
12. ✅ User1 challenges User2
13. ✅ User2 accepts challenge
14. ✅ Both vote for game
15. ✅ Both play and submit scores
16. ✅ Continue for 3 games
17. ✅ Admin checks stats
18. ✅ Admin manages users

---

## 📊 PERFORMANCE TESTING

### Load Test với Postman Runner

1. Select collection
2. Run → Performance
3. Virtual users: 10
4. Duration: 5 minutes
5. Check:
   - Response times < 500ms
   - No 500 errors
   - Rate limiting works

---

## ✅ CHECKLIST

- [ ] All Authentication APIs work
- [ ] Game scores save correctly
- [ ] Leaderboard updates
- [ ] Friend system works
- [ ] Messages send/receive
- [ ] Posts create/like/comment
- [ ] Achievements unlock
- [ ] Challenge system complete flow
- [ ] Admin APIs work
- [ ] Rate limiting triggers
- [ ] Error handling works
- [ ] Socket events fire

---

**Success criteria:** All tests pass with 0 errors. Response times under 500ms average.
