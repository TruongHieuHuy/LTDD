import 'base_model.dart';

/// Classic games suggestions (Original 4 games)
class ClassicGamesSuggestions {
  static List<ChatSuggestion> getAll() {
    return [
      _guessNumberRules(),
      _cowsBullsRules(),
      _memoryMatchRules(),
      _quickMathRules(),
      _gamesTips(),
      _gamesDifficulty(),
    ];
  }

  static ChatSuggestion _guessNumberRules() {
    return ChatSuggestion(
      id: 'game_guess_rules',
      title: '📖 Luật Đoán Số',
      icon: '🎲',
      fullResponse: '''🎲 **LUẬT CHƠI ĐOÁN SỐ**

📋 **Mục tiêu:** Đoán đúng số bí mật trong ít lượt nhất

🎯 **Cách chơi:**
1. Máy chọn ngẫu nhiên 1 số (tùy độ khó)
2. Bạn đoán 1 số
3. Máy gợi ý: "Cao hơn" ⬆️ hoặc "Thấp hơn" ⬇️
4. Tiếp tục đoán cho đến khi đúng ✅

📊 **Độ khó:**
• **Easy** 🟢: 1-50 (6 lượt tối ưu)
• **Medium** 🟡: 1-100 (7 lượt tối ưu)
• **Hard** 🔴: 1-1000 (10 lượt tối ưu)

🏆 **Tính điểm:**
```
Điểm = 1000 - (số lượt × 10)
```

💡 **Chiến thuật Binary Search:**
1. Đoán số ở giữa phạm vi
2. Thu hẹp phạm vi dựa trên gợi ý
3. Lặp lại đến khi tìm ra đáp án''',
    );
  }

  static ChatSuggestion _cowsBullsRules() {
    return ChatSuggestion(
      id: 'game_bulls_rules',
      title: '📖 Luật Bò & Bê',
      icon: '🐮',
      fullResponse: '''🐮🐄 **LUẬT CHƠI BÒ & BÊ (MASTERMIND)**

📋 **Mục tiêu:** Đoán đúng mã số bí mật 4 chữ số

🎯 **Cách chơi:**
1. Máy tạo mã gồm **4 chữ số khác nhau** (0-9)
2. Bạn đoán 1 mã 4 số
3. Máy phản hồi:
   • 🐄 **Bò (Bulls)**: Số đúng vị trí
   • 🐮 **Bê (Cows)**: Số đúng nhưng sai vị trí

💡 **Chiến thuật 3 bước:**
**Bước 1:** Tìm 4 số (lượt 1-3)
**Bước 2:** Xác định vị trí (lượt 4-6)
**Bước 3:** Tinh chỉnh (lượt 7-10)

🏆 **Điều kiện thắng:**
• Đạt **4🐄 0🐮** = Hoàn hảo!
• Tối đa 10 lượt''',
    );
  }

  static ChatSuggestion _memoryMatchRules() {
    return ChatSuggestion(
      id: 'game_memory_rules',
      title: '📖 Luật Memory Match',
      icon: '🧩',
      fullResponse: '''🧩 **LUẬT CHƠI MEMORY MATCH (LẬT THẺ)**

📋 **Mục tiêu:** Tìm tất cả các cặp thẻ giống nhau

🎯 **Cách chơi:**
1. Tất cả thẻ úp ngửa
2. Click 2 thẻ để lật
3. Nếu giống → Giữ nguyên ✅
4. Nếu khác → Tự động úp lại ❌

📊 **3 Độ khó:**

**🟢 Easy:**
• Lưới: 4x4, Preview: 5s
• Target: < 60s

**🟡 Normal:**
• Lưới: 4x4, Preview: 3s  
• Target: < 45s

**🔴 Hard (Double Coding):**
• Challenge: Cùng icon nhưng khác màu!
• Phải khớp cả icon VÀ màu
• Preview: 2s, Target: < 90s

💡 **Pro Tips:**
• Tập trung ở preview phase
• Lật theo pattern
• Ghi nhớ thẻ sai''',
    );
  }

  static ChatSuggestion _quickMathRules() {
    return ChatSuggestion(
      id: 'game_quickmath_rules',
      title: '📖 Luật Quick Math',
      icon: '⚡',
      fullResponse: '''⚡ **LUẬT CHƠI QUICK MATH (TOÁN NHANH)**

📋 **Mục tiêu:** Trả lời đúng càng nhiều phép tính

🎯 **Cách chơi:**
1. Bạn có **3 HP** ❤️❤️❤️
2. Mỗi câu: 10 giây, 4 đáp án
3. Đúng → +1 điểm ✅
4. Sai/Hết giờ → -1 HP ❌
5. Hết HP = Game Over 💀

⚡ **3 Power-ups (2 lần/loại):**
• **⏸️ Time Freeze**: Đóng băng 3s
• **⏭️ Skip**: Bỏ qua không mất HP
• **50-50**: Ẩn 2 đáp án sai

🏆 **Streak System:**
```
Streak ≥ 5 → Bonus +2 điểm/câu
```

💡 **Pro Tips:**
• Accuracy > Speed
• Power-up khi cần
• Giữ streak ≥5''',
    );
  }

  static ChatSuggestion _gamesTips() {
    return ChatSuggestion(
      id: 'game_tips',
      title: '💡 Tips & Tricks',
      icon: '✨',
      fullResponse: '''💡 **TIPS & TRICKS CHO TẤT CẢ GAMES**

🎯 **Đoán Số:**
• Binary Search Algorithm
• Chia đôi phạm vi
• Đoán số ở giữa

🐮 **Bò & Bê:**
• Elimination Strategy
• Pattern Recognition
• Logical Deduction

🧩 **Memory Match:**
• Preview Phase Strategy
• Flip Pattern
• Failed Match Memory

⚡ **Quick Math:**
• Accuracy First
• Power-up Priority
• Mental Math Tricks

🏆 **Farming Điểm:**
• Daily Routine (2 ván/game/ngày)
• Difficulty Progression
• Achievement Hunting''',
    );
  }

  static ChatSuggestion _gamesDifficulty() {
    return ChatSuggestion(
      id: 'game_difficulty',
      title: '📊 Độ khó',
      icon: '⚡',
      fullResponse: '''📊 **HỆ THỐNG ĐỘ KHÓ - CLASSIC GAMES**

🟢 **EASY:** Người mới bắt đầu
🟡 **NORMAL:** Practice chính
🔴 **HARD:** Master level

📈 **PROGRESSION PATH:**
```
Easy (Win rate > 80%)
  ↓
Normal (Win rate > 70%)
  ↓
Hard (Master level)
  ↓
Leaderboard Top 10
```

💡 **Recommendation:**
• Chơi Easy để làm quen
• Practice ở Normal
• Challenge ở Hard khi ready
• Mix cả 3 để unlock achievements!''',
    );
  }
}
