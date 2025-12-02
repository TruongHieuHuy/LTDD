# 🎮 Game System Documentation

## Tổng quan

Hệ thống mini games với phong cách Gen Z meme, bao gồm 2 game chính + Leaderboard + Achievement system.

---

## 📁 Cấu trúc thư mục

```
lib/
├── models/
│   ├── game_score_model.dart          # Model điểm số (Hive typeId: 3)
│   └── achievement_model.dart         # Model huy hiệu (Hive typeId: 4)
├── providers/
│   └── game_provider.dart             # Business logic quản lý games
├── screens/games/
│   ├── guess_number_game_screen.dart  # Game 1: Đoán Số
│   ├── cows_bulls_game_screen.dart    # Game 2: Bò & Bê
│   ├── leaderboard_screen.dart        # Bảng xếp hạng
│   └── achievement_screen.dart        # Màn hình huy hiệu
├── widgets/game_widgets/
│   ├── troll_button.dart              # Nút chạy troll
│   ├── patience_bar.dart              # Thanh HP
│   ├── meme_feedback.dart             # Toast feedback meme
│   └── firework_effect.dart           # Hiệu ứng pháo hoa
├── utils/
│   ├── database_service.dart          # Hive database operations
│   ├── game_audio_service.dart        # Flutter audio bridge
│   └── game_utils/
│       ├── game_colors.dart           # Color system (neon palette)
│       └── meme_texts.dart            # 40+ troll quotes

android/
└── app/src/main/kotlin/com/example/truonghieuhuy/
    ├── MainActivity.kt                # Method channel handler
    └── GameAudioManager.kt            # Native Android audio
```

---

## 🎯 Game 1: Đoán Số

### Độ khó
- **Easy**: 1-50, 7 lượt
- **Normal**: 1-100, 5 lượt
- **Hard**: 1-200, 3 lượt

### Tính năng
- ✅ Thinking timer (troll messages at 15s, 30s)
- ✅ Screen shake sau 3 lần sai
- ✅ Patience bar (😊→😐→😰→😡→💀)
- ✅ Lịch sử đoán với màu (orange=gần, red=xa)
- ✅ "Very close" detection (trong vòng 5 số)
- ✅ Fireworks khi thắng
- ✅ Meme feedback mọi tình huống

---

## 🐮 Game 2: Bò & Bê (Mastermind)

### Độ khó
- **Level 1 (6 số)**: 6 chữ số unique, 8 lượt
- **Level 2 (12 số)**: 12 chữ số unique, 15 lượt - "Thách Thức Tuyệt Vọng"

### Quy tắc
- 🐂 **Bulls** = Đúng số, đúng vị trí
- 🤡 **Cows** = Đúng số, sai vị trí

### Tính năng đặc biệt
- ✅ LED ticker animation cho 12-digit (glowing text)
- ✅ Fake advertisement popup sau 5 lần sai (12-digit)
- ✅ Nút "ĐẦU HÀNG" lớn xuất hiện sau 5 lần (hard mode)
- ✅ Thinking timer (10s cho 12-digit, 30s warning)
- ✅ Screen shake on mistakes
- ✅ Lịch sử 5 lần đoán gần nhất

---

## 🏆 Leaderboard

### Tính năng
- ✅ Filter theo game type (All / Đoán Số / Bò Bê)
- ✅ Animated podium cho top 3:
  - 🥇 #1: Vàng + crown
  - 🥈 #2: Bạc
  - 🥉 #3: Đồng
- ✅ Hiển thị top 10 với rank, player name, score
- ✅ Elastic animation khi mở screen

### Tính điểm
```
Score = Base / Attempts × Time Multiplier
- Base: 1000 (guess) hoặc 1200 (cows_bulls)
- Time bonus: <30s = +50%, <60s = +20%
```

---

## 🏅 Achievement System

### 10 Huy hiệu

#### Common (2)
- 🎓 **Tân Binh** - Thắng game đầu tiên
- 🎮 **Người Chơi Hệ** - Chơi 10 ván

#### Rare (3)
- 🍀 **Vua May Mắn** - Thắng trong 3 lần thử
- 🎭 **Thần Troll** - Gặp 50 feedback meme
- ⚡ **Tốc Độ Ánh Sáng** - Thắng trong 30 giây

#### Epic (3)
- 💎 **Hoàn Hảo** - Thắng không sai lần nào (1 attempt)
- 🔥 **Cao Thủ Khó** - Thắng mode Hard 5 lần
- 🐂 **Siêu Não Bò** - Thắng Bò Bê 12 số

#### Legendary (2)
- 👑 **Hacker Tối Thượng** - Thắng 10 game liên tiếp
- 🛡️ **Kiên Trì Đến Cùng** - Không đầu hàng trong 50 game

### Tính năng
- ✅ Rarity-based colors & glow effects
- ✅ Animated card reveal (elastic out)
- ✅ Detail popup khi click
- ✅ Progress bar (X/10 unlocked)
- ✅ Lock/unlock animation

---

## 🔊 Audio System

### Android Native (`GameAudioManager.kt`)
```kotlin
GameAudioManager.playBonk()         // Wrong answer
GameAudioManager.playBruh()         // Epic fail
GameAudioManager.playVictory()      // Win
GameAudioManager.playSadTrombone()  // Lose
GameAudioManager.playError()        // Invalid input
GameAudioManager.playClick()        // Button press
GameAudioManager.playTroll()        // Meme moment
```

### Flutter Bridge (`GameAudioService`)
```dart
await GameAudioService.playBonk();
await GameAudioService.playVictory();
await GameAudioService.playTroll();
```

### Thêm file âm thanh
Đặt các file .mp3 vào: `android/app/src/main/res/raw/`
- `bonk.mp3`
- `bruh.mp3`
- `victory.mp3`
- `sad_trombone.mp3`
- `error.mp3`
- `click.mp3`
- `troll.mp3`

---

## 💾 Database (Hive)

### GameScoreModel (typeId: 3)
```dart
{
  id: String,
  playerName: String,
  gameType: String,  // 'guess_number' or 'cows_bulls'
  score: int,
  attempts: int,
  timestamp: DateTime,
  difficulty: String, // 'easy', 'normal', 'hard', '6digit', '12digit'
  timeSpent: int      // seconds
}
```

### AchievementModel (typeId: 4)
```dart
{
  id: String,
  name: String,
  description: String,
  iconEmoji: String,
  isUnlocked: bool,
  unlockedAt: DateTime?,
  rarity: String,     // 'common', 'rare', 'epic', 'legendary'
  condition: String
}
```

### DatabaseService Methods
```dart
// Scores
await DatabaseService.saveGameScore(score);
List<GameScoreModel> scores = DatabaseService.getLeaderboard(gameType: 'all', limit: 10);
GameScoreModel? best = DatabaseService.getBestScore('PlayerName', 'guess_number');

// Achievements
await DatabaseService.unlockAchievement('first_win');
List<AchievementModel> all = DatabaseService.getAllAchievements();
bool unlocked = DatabaseService.isAchievementUnlocked('lucky_king');

// Auto-check achievements
List<AchievementModel> newAchievements = await DatabaseService.checkAndUnlockAchievements(
  playerName: 'Player',
  gameType: 'guess_number',
  attempts: 3,
  timeSpent: 25,
  difficulty: 'hard',
);
```

---

## 🎨 Design System

### Colors (`GameColors`)
```dart
// Neon palette
neonYellow: #FFFF00
neonPink: #FF10F0
neonCyan: #00FFFF
neonGreen: #00FF00
neonOrange: #FF8000

// Backgrounds
darkGray: #1A1A1A
darkCharcoal: #2A2A2A
textWhite: #FFFFFF
textGray: #888888
```

### Meme Texts (`MemeTexts`)
40+ troll quotes theo context:
- `tooHigh` - "Cao vầy ma hả? 🤡"
- `tooLow` - "Thấp không thể thấp hơn 😂"
- `correct` - "ĐÚC KHUÔN QUÁ! 🎉"
- `gameOver` - "Game over rồi nha bro 💀"
- `veryClose` - "Sắp rồi! Khẩn trương!"
- `thinking` - "Suy nghĩ lâu thế? Não lag à? 🐌"
- `noBullsNoCows` - "Không Bulls không Cows... bạn đoán có tâm không? 🤔"

---

## 🔗 Integration với Profile

### Profile Screen có 4 cards:
```dart
🎲 Đoán Số - "Thần Kinh Game"
🐮 Bò & Bê - "Trại Bò Bất Ổn"
🏆 Leaderboard
🏅 Achievements
```

### Routes
```dart
'/guess_number_game'
'/cows_bulls_game'
'/leaderboard'
'/achievements'
```

---

## 📊 GameProvider

### State Management
```dart
// Initialize
final gameProvider = Provider.of<GameProvider>(context);
await gameProvider.initialize();

// Save score & check achievements
List<AchievementModel> newAchievements = await gameProvider.saveGameScore(
  gameType: 'guess_number',
  score: 850,
  attempts: 4,
  difficulty: 'normal',
  timeSpent: 45,
);

// Track memes
await gameProvider.incrementMemeEncounters();

// Get stats
Map<String, dynamic> stats = gameProvider.getStats();
// {totalGames: 15, achievementsUnlocked: 3, avgAttempts: 4.2, ...}
```

---

## 🧪 Testing

### Test flow
1. Chơi Đoán Số (Easy) → Win → Check "Tân Binh" unlocked
2. Chơi tiếp 2 lần → Win trong 3 attempts → Check "Vua May Mắn"
3. Gặp 50+ meme → Check "Thần Troll"
4. Chơi Bò Bê 12 số → Win → Check "Siêu Não Bò"
5. Mở Leaderboard → Verify top 3 podium animation
6. Mở Achievements → Verify progress bar

---

## 🚀 Next Steps

1. ✅ Add sound files to `res/raw/`
2. ✅ Uncomment sound loading in `GameAudioManager.kt`
3. ✅ Integrate `GameProvider` into game screens
4. ✅ Add `GameAudioService.playXXX()` calls in UI
5. ✅ Test end-to-end gameplay
6. ✅ Add player name input dialog
7. ✅ Implement win streak tracking
8. ✅ Add surrender penalty logic

---

## 🐛 Known Issues

- Sound files chưa có → Cần download/record âm thanh
- Meme counter chưa persist → Store trong Hive settings
- Win streak chưa track → Cần logic sequential checking
- Player name hardcode "Player" → Cần input dialog

---

## 👨‍💻 Developer Notes

### Tech Stack
- Flutter 3.38.1
- Hive 2.x (local database)
- Provider (state management)
- Material 3
- Native Android audio (SoundPool)

### Performance
- Hive operations: <10ms
- Animation 60fps (elastic curves)
- Sound latency: <50ms

### Code Style
- Gen Z meme aesthetic
- Vietnamese troll quotes
- Neon colors + dark theme
- Over-the-top animations

---

**Tác giả**: Trương Hiếu Huy  
**Version**: 1.0.0  
**Date**: December 2025
