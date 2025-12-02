# 📱 Smart Student Tools - TruongHieuHuy

**Ứng dụng đa chức năng dành cho sinh viên** với OCR, dịch thuật, báo thức thông minh và hệ thống mini games giải trí.

## 🎯 Tính năng chính

### 1. 🔤 Dịch thuật đa ngôn ngữ
- OCR đa ảnh (chụp hoặc chọn từ gallery)
- Hỗ trợ 50+ ngôn ngữ
- Lịch sử dịch thuật với Hive database
- Text-to-Speech tích hợp

### 2. ⏰ Báo thức thông minh
- Đặt báo thức bằng giọng nói (tiếng Việt)
- Nhận diện tự nhiên: "7 giờ 30 sáng", "sau 2 giờ 15 phút"
- Quản lý nhiều báo thức
- Tùy chỉnh âm thanh, repeat, snooze

### 3. 👥 Quản lý nhóm sinh viên
- Tạo và quản lý nhóm
- Thông tin liên hệ thành viên
- Tích hợp gọi điện, mở YouTube

### 4. 👤 Profile cá nhân
- Thông tin sinh viên
- Liên hệ khẩn cấp (Call, YouTube)
- Truy cập mini games

### 5. 🎮 Hệ thống Mini Games (NEW!)
#### Game 1: Đoán Số 🎲
- 3 độ khó: Easy (1-50), Normal (1-100), Hard (1-200)
- Thinking timer với troll messages
- Screen shake effect
- Patience bar với emoji
- Meme feedback system

#### Game 2: Bò & Bê 🐮
- Mastermind game với 2 levels
- Level 1: 6 digits (8 attempts)
- Level 2: 12 digits (15 attempts) - "Thách Thức Tuyệt Vọng"
- LED ticker animation
- Fake ad popup (troll)
- Bulls (🐂) vs Cows (🤡) feedback

#### Leaderboard 🏆
- Top 10 players
- Animated podium (gold/silver/bronze)
- Filter theo game type
- Hiển thị score, attempts, time

#### Achievement System 🏅
- 10 huy hiệu độc đáo
- 4 rarity levels: Common → Rare → Epic → Legendary
- Auto unlock dựa trên gameplay
- Animated reveal
- Progress tracking

### 6. ⚙️ Cài đặt
- Dark mode toggle
- Notification control
- Biometric authentication
- Multi-language support

## 🏗️ Kiến trúc kỹ thuật

### Tech Stack
- **Flutter**: 3.38.1-stable
- **State Management**: Provider
- **Database**: Hive (NoSQL local)
- **OCR**: Google ML Kit
- **Translation**: Google Translate API
- **Audio**: Native Android (SoundPool)
- **Speech**: Android Speech Recognition

### Cấu trúc dự án
```
lib/
├── models/               # Hive data models
│   ├── alarm_model.dart
│   ├── translation_history_model.dart
│   ├── app_settings_model.dart
│   ├── game_score_model.dart
│   └── achievement_model.dart
├── providers/            # State management
│   ├── alarm_provider.dart
│   ├── translation_provider.dart
│   ├── settings_provider.dart
│   └── game_provider.dart
├── screens/             # UI screens
│   ├── games/           # Game screens
│   ├── translate_screen.dart
│   ├── alarm_screen.dart
│   ├── group_screen.dart
│   ├── profile_screen.dart
│   └── settings_screen.dart
├── widgets/             # Reusable widgets
│   └── game_widgets/    # Game-specific widgets
├── utils/               # Utilities
│   ├── database_service.dart
│   ├── game_audio_service.dart
│   └── game_utils/
└── main.dart

android/
└── app/src/main/kotlin/
    ├── MainActivity.kt         # Method channels
    ├── GameAudioManager.kt     # Native audio
    ├── CallService.kt
    ├── YouTubeService.kt
    └── AlarmService.kt
```

### Database Schema (Hive)
- **TypeId 0**: AlarmModel
- **TypeId 1**: TranslationHistoryModel
- **TypeId 2**: AppSettingsModel
- **TypeId 3**: GameScoreModel
- **TypeId 4**: AchievementModel

## 🎨 Design System

### Game Colors (Neon Theme)
- Neon Yellow (#FFFF00)
- Neon Pink (#FF10F0)
- Neon Cyan (#00FFFF)
- Neon Green (#00FF00)
- Neon Orange (#FF8000)

### Meme System
40+ Vietnamese Gen Z troll quotes với categories:
- tooHigh, tooLow, correct, gameOver
- veryClose, thinking, noBullsNoCows
- cowsBullsWin, surrender

## 🚀 Cài đặt & Chạy

### Yêu cầu
- Flutter SDK 3.38.1+
- Dart SDK 3.10.0+
- Android Studio / VS Code
- Android device/emulator (API 21+)

### Cài đặt dependencies
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Chạy ứng dụng
```bash
flutter run
```

### Build APK
```bash
flutter build apk --release
```

## 📊 Achievements (10 badges)

### Common (2)
- 🎓 Tân Binh - Thắng game đầu tiên
- 🎮 Người Chơi Hệ - Chơi 10 ván

### Rare (3)
- 🍀 Vua May Mắn - Thắng trong 3 lần thử
- 🎭 Thần Troll - Gặp 50 feedback meme
- ⚡ Tốc Độ Ánh Sáng - Thắng trong 30 giây

### Epic (3)
- 💎 Hoàn Hảo - Đoán đúng lần đầu
- 🔥 Cao Thủ Khó - Thắng mode Hard 5 lần
- 🐂 Siêu Não Bò - Thắng Bò Bê 12 số

### Legendary (2)
- 👑 Hacker Tối Thượng - Thắng 10 game liên tiếp
- 🛡️ Kiên Trì Đến Cùng - 50 game không surrender

## 🎵 Audio System

### Native Android Sounds (TODO)
Cần thêm files vào `android/app/src/main/res/raw/`:
- bonk.mp3 - Wrong answer
- bruh.mp3 - Epic fail
- victory.mp3 - Win
- sad_trombone.mp3 - Lose
- error.mp3 - Invalid input
- click.mp3 - Button press
- troll.mp3 - Meme moment

## 📝 Ghi chú

### Tính năng nổi bật
- ✅ Multi-image OCR với ML Kit
- ✅ Voice-controlled alarm (Vietnamese)
- ✅ Gen Z meme aesthetic games
- ✅ Animated achievement system
- ✅ Hive local database
- ✅ Provider state management
- ✅ Native Android integration

### Known Issues
- Sound files chưa được thêm (placeholder)
- Win streak tracking cần cải thiện
- Player name input cần dialog thay vì hardcode

## 👨‍💻 Tác giả

**Trương Hiếu Huy**
- MSSV: 2280601273
- Lớp: 22DTHA2
- Email: truonghieuhuy1401@gmail.com
- Phone: 0948677191

## 📜 License

This project is created for educational purposes.

## 🔗 Links

- [Documentation](./GAME_SYSTEM_DOCS.md)
- [Implementation Summary](./IMPLEMENTATION_SUMMARY.md)

---

**Version**: 1.0.0  
**Last Updated**: December 3, 2025  
**Flutter**: 3.38.1-stable
