import 'base_model.dart';

/// Challenge/PK System suggestions (NEW)
class ChallengeSuggestions {
  static ChatSuggestion getMainCategory() {
    return ChatSuggestion(
      id: 'challenge',
      title: '⚔️ Challenge/PK System',
      icon: '💥',
      description: 'Thách đấu 1v1',
      subItems: getAll(),
    );
  }

  static List<ChatSuggestion> getAll() {
    return [
      _howChallengeWorks(),
      _createChallenge(),
      _viewChallenges(),
      _betting(),
    ];
  }

  static ChatSuggestion _howChallengeWorks() {
    return ChatSuggestion(
      id: 'challenge_how',
      title: '❓ Challenge hoạt động thế nào',
      icon: '📝',
      fullResponse: '''⚔️ **HỆ THỐNG CHALLENGE/PK**

🎯 **Khái niệm:**
Thách đấu bạn bè trong mini games với cược coins

📝 **Flow:**
```
Tạo Challenge → Accept/Reject
  → Chơi game → Tính điểm
  → Winner takes all!
```

💰 **Betting:**
• Min: 10 coins
• Max: 1000 coins
• Winner: 2x bet
• Loser: Mất bet
• Hòa: Hoàn lại

🏆 **Supported Games:**
• Classic: Guess Number, Cows & Bulls, Memory, Quick Math
• New: Caro, Sudoku, Puzzle, Rubik
• Total: 8 games!

📊 **States:**
• **Pending** ⏳: Chờ accept
• **Accepted** ✅: Đang chơi
• **Completed** 🏆: Đã xong
• **Rejected** ❌: Bị từ chối
• **Cancelled** 🚫: Đã hủy

💡 **Tips:**
• Check friend stats trước
• Bet hợp lý
• Pick game bạn giỏi''',
    );
  }

  static ChatSuggestion _createChallenge() {
    return ChatSuggestion(
      id: 'challenge_create',
      title: '➕ Tạo Challenge',
      icon: '⚔️',
      fullResponse: '''➕ **CÁCH TẠO CHALLENGE**

🎯 **Steps:**
1. Mở Create Challenge screen
2. Pick game (8 options)
3. Chọn friend từ list
4. Set bet (10-1000 coins)
5. Confirm & Send!

✅ **Requirements:**
• Phải có bạn bè
• Đủ coins để bet
• Friend phải online (optional)

🎮 **Game Selection:**
Chọn game bạn confident:
• Caro: Nếu giỏi chiến thuật
• Sudoku: Logic tốt
• Puzzle: Spatial reasoning
• Rubik: Memorize algorithms
• Quick Math: Mental math nhanh

💰 **Betting Tips:**
• **Conservative:** 10-50 coins
• **Normal:** 50-200 coins
• **High Stakes:** 200-1000 coins
• Đừng bet all-in!

🔔 **Notifications:**
Friend sẽ nhận thông báo ngay
Can accept/reject trong 24h''',
    );
  }

  static ChatSuggestion _viewChallenges() {
    return ChatSuggestion(
      id: 'challenge_list',
      title: '📋 Xem Challenges',
      icon: '👀',
      fullResponse: '''📋 **DANH SÁCH CHALLENGES**

📂 **3 Tabs:**

**⏳ Pending:**
• Challenges bạn nhận
• Chưa accept/reject
• Click để xem details
• Action: Accept or Reject

**🎮 Active:**
• Đã accept, đang chơi
• Click để continue game
• Xem progress
• Both sides can play

**✅ Completed:**
• Đã finish
• Xem winner/loser
• Coins won/lost
• Stats & history

🔍 **Info hiển thị:**
• Opponent avatar & name
• Game type icon
• Bet amount 💰
• Created time ⏰
• Status badge

💡 **Quick Actions:**
• Swipe left → Reject
• Swipe right → Accept  
• Long press → Details
• Pull down → Refresh''',
    );
  }

  static ChatSuggestion _betting() {
    return ChatSuggestion(
      id: 'challenge_betting',
      title: '💰 Hệ thống Betting',
      icon: '💸',
      fullResponse: '''💰 **BETTING TRONG CHALLENGE**

📊 **Mechanics:**

**Winner Takes All:**
```
Bet: 100 coins
Winner gets: +100 (tổng 200)
Loser loses: -100
Net transfer: 100 coins
```

**Draw/Tie:**
```
Nếu hòa → Hoàn lại bet
Cả 2 không mất/nhận gì
```

💸 **Bet Ranges:**

**Low Stakes (10-50):**
• Safe cho beginners
• Practice mode
• Low risk

**Medium Stakes (50-200):**
• Normal competitive
• Good risk/reward
• Most popular

**High Stakes (200-1000):**
• High risk, high reward
• For confident players
• Check balance!

⚠️ **Risk Management:**
• Never bet > 10% balance
• Have coins buffer
• Know when to stop
• Track W/L ratio

📈 **EV (Expected Value):**
```
Nếu Win Rate 60%:
EV = (0.6 × +bet) - (0.4 × -bet)
   = 0.2 × bet (profit!)
   
Nếu Win Rate 40%:
EV = (0.4 × +bet) - (0.6 × -bet)
   = -0.2 × bet (loss!)
```

💡 **Pro Tips:**
• Track stats per game
• Bet high khi confident
• Cut losses nếu losing streak
• Bankroll management!''',
    );
  }
}
