/// Intelligent offline chatbot - works without API
class IntelligentFallbackService {
  /// Get intelligent response based on user query
  static String getIntelligentResponse(String userMessage) {
    final msg = userMessage.toLowerCase().trim();

    // Game Rules
    if (_containsAny(msg, [
      'đoán số',
      'guess number',
      'cách chơi đoán',
      'luật đoán',
    ])) {
      return _getGuessNumberRules();
    }

    if (_containsAny(msg, [
      'bò',
      'bê',
      'cows',
      'bulls',
      'mastermind',
      'cách chơi bò',
    ])) {
      return _getCowsBullsRules();
    }

    // Tips & Strategy
    if (_containsAny(msg, [
      'tips',
      'mẹo',
      'chiến thuật',
      'cách chơi tốt',
      'chơi giỏi',
    ])) {
      return _getTips(msg);
    }

    // Stats & Progress
    if (_containsAny(msg, [
      'thống kê',
      'stats',
      'điểm',
      'score',
      'xếp hạng',
      'rank',
    ])) {
      return _getStats();
    }

    // Achievements
    if (_containsAny(msg, [
      'huy hiệu',
      'achievement',
      'unlock',
      'thành tích',
    ])) {
      return _getAchievements();
    }

    // Leaderboard
    if (_containsAny(msg, [
      'bảng xếp hạng',
      'leaderboard',
      'top player',
      'hạng mấy',
    ])) {
      return _getLeaderboard();
    }

    // Difficulty
    if (_containsAny(msg, [
      'độ khó',
      'difficulty',
      'dễ',
      'khó',
      'easy',
      'medium',
      'hard',
    ])) {
      return _getDifficulty();
    }

    // Project Info
    if (_containsAny(msg, [
      'project',
      'dự án',
      'app',
      'ứng dụng',
      'tính năng',
      'feature',
    ])) {
      return _getProjectInfo();
    }

    // About AI
    if (_containsAny(msg, [
      'bạn là ai',
      'ai',
      'giới thiệu',
      'kajima',
      'chatbot',
    ])) {
      return _getAboutAI();
    }

    // Help
    if (_containsAny(msg, ['help', 'giúp', 'hướng dẫn', 'hỏi gì'])) {
      return _getHelp();
    }

    // Greeting
    if (_containsAny(msg, ['xin chào', 'chào', 'hello', 'hi', 'hey'])) {
      return _getGreeting();
    }

    // Generic fallback
    return _getGenericResponse(msg);
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  static String _getGuessNumberRules() {
    return '''🎲 **LUẬT CHƠI ĐOÁN SỐ**

📋 **Mục tiêu:** Đoán đúng số bí mật trong ít lượt nhất

🎯 **Cách chơi:**
1. Máy chọn ngẫu nhiên 1 số (tùy độ khó)
2. Bạn đoán 1 số
3. Máy gợi ý: "Cao hơn" hoặc "Thấp hơn"
4. Tiếp tục đoán cho đến khi đúng

📊 **Độ khó:**
• **Easy**: 1-50 (ít lượt)
• **Medium**: 1-100 (trung bình)
• **Hard**: 1-1000 (nhiều lượt)

💡 **Tips:**
- Dùng chiến thuật "chia đôi" (binary search)
- Ví dụ: với 1-100, đoán 50 trước
- Sau đó chia đôi phạm vi còn lại

🏆 **Tính điểm:**
- Điểm = 1000 - (số lượt × 10)
- Đoán càng nhanh, điểm càng cao!''';
  }

  static String _getCowsBullsRules() {
    return '''🐮🐄 **LUẬT CHƠI BÒ & BÊ (MASTERMIND)**

📋 **Mục tiêu:** Đoán đúng mã số bí mật

🎯 **Cách chơi:**
1. Máy tạo mã gồm **4 chữ số khác nhau** (0-9)
2. Bạn đoán 1 mã 4 số
3. Máy phản hồi:
   • 🐄 **Bò (Bulls)**: Số đúng vị trí
   • 🐮 **Bê (Cows)**: Số đúng nhưng sai vị trí

📝 **Ví dụ:**
- Mã bí mật: **1234**
- Bạn đoán: **1456**
- Kết quả: **1 Bò, 1 Bê**
  * 1 Bò: số 1 đúng vị trí
  * 1 Bê: số 4 đúng số nhưng sai vị trí

💡 **Chiến thuật:**
1. Đoán thử với 4 số khác nhau
2. Dựa vào Bò/Bê để loại trừ
3. Xác định từng số một
4. Sắp xếp đúng vị trí

🏆 **Điều kiện thắng:**
- Đạt **4 Bò** = Đoán đúng hoàn toàn!
- Càng ít lượt càng tốt

⏱️ **Giới hạn:** 10 lượt đoán''';
  }

  static String _getTips(String msg) {
    if (msg.contains('đoán số') || msg.contains('guess')) {
      return '''💡 **TIPS CHƠI ĐOÁN SỐ**

🎯 **Chiến thuật Binary Search:**
1. Luôn đoán số ở **giữa** phạm vi
2. Ví dụ: 1-100 → đoán 50
3. Nếu "Cao hơn" → phạm vi mới: 51-100 → đoán 75
4. Nếu "Thấp hơn" → phạm vi mới: 1-49 → đoán 25

📊 **Tối ưu theo độ khó:**
• Easy (1-50): Tối đa 6 lượt
• Medium (1-100): Tối đa 7 lượt  
• Hard (1-1000): Tối đa 10 lượt

🏆 **Để đạt điểm cao:**
- Đoán càng nhanh càng tốt
- Tránh đoán ngẫu nhiên
- Luôn dùng logic để thu hẹp phạm vi''';
    }

    if (msg.contains('bò') ||
        msg.contains('bê') ||
        msg.contains('bull') ||
        msg.contains('cow')) {
      return '''💡 **TIPS CHƠI BÒ & BÊ**

🎯 **Bước 1: Khám phá các số**
- Đoán: 0123, 4567, 8901
- Mục tiêu: Tìm ra 4 số có trong mã

🧠 **Bước 2: Xác định vị trí**
- Khi biết 4 số rồi, thử hoán vị
- Ví dụ: Biết có 1,2,3,4 → thử 1234, 1243, 1324...

📊 **Phân tích thông minh:**
- **0 Bò, 0 Bê**: Loại bỏ tất cả 4 số
- **1 Bò, 0 Bê**: 1 số đúng vị trí, 3 số sai
- **0 Bò, 2 Bê**: 2 số đúng nhưng sai vị trí

🏆 **Chiến thuật Pro:**
1. Lượt 1-3: Tìm các số
2. Lượt 4-6: Xác định vị trí
3. Lượt 7-10: Tinh chỉnh''';
    }

    return '''💡 **TIPS CHUNG CHO TẤT CẢ GAME**

🎮 **Nguyên tắc vàng:**
1. **Chơi hàng ngày** để maintain streak
2. **Thử tất cả độ khó** để unlock achievements
3. **Phân tích lỗi sai** sau mỗi ván

📈 **Cải thiện kỹ năng:**
• Luyện tập logic và tư duy
• Ghi nhớ các pattern
• Học từ top players

🏆 **Farming điểm:**
- Chơi Easy mode nhiều lần
- Hoàn thành daily challenges
- Unlock tất cả achievements''';
  }

  static String _getStats() {
    return '''📊 **THỐNG KÊ & TIẾN TRÌNH**

🎮 **Xem chi tiết:**
1. Vào màn hình **Leaderboard**
2. Nhấn nút **"Thống kê của tôi"**

📈 **Các chỉ số quan trọng:**
• **Tổng số ván**: Số game đã chơi
• **Tỷ lệ thắng**: Win rate %
• **Điểm cao nhất**: Highest score
• **Streak hiện tại**: Winning streak
• **Hạng hiện tại**: Your rank

🏆 **Cách tăng điểm:**
1. Chơi nhiều ván hơn
2. Giảm số lượt đoán
3. Chơi độ khó cao hơn
4. Maintain winning streak

💎 **Achievements:**
- Unlock huy hiệu để tăng rank
- Hoàn thành challenges đặc biệt''';
  }

  static String _getAchievements() {
    return '''🏆 **HỆ THỐNG HUY HIỆU**

💎 **Các loại huy hiệu:**

🎯 **Beginner (Người mới):**
• Chơi 1 ván đầu tiên
• Đoán đúng lần đầu

🔥 **Streak Master:**
• Win streak 5 ván liên tiếp
• Win streak 10 ván
• Win streak 50 ván

⚡ **Speed Demon:**
• Hoàn thành trong < 5 lượt
• Hoàn thành trong < 3 lượt

🎮 **Game Master:**
• Chiến thắng tất cả độ khó
• Chơi 100 ván
• Chơi 500 ván

🏅 **Collector (Thu thập):**
• Mở khóa 5000 điểm
• Mở khóa 10 achievements
• Mở khóa tất cả achievements

📍 **Xem chi tiết:**
Vào **Achievements** → Xem progress từng huy hiệu''';
  }

  static String _getLeaderboard() {
    return '''🏆 **BẢNG XẾP HẠNG**

📊 **Hệ thống ranking:**
1. **Top 10**: Elite players
2. **Top 50**: Advanced players
3. **Top 100**: Intermediate players
4. **Còn lại**: Beginners

🎯 **Cách tính điểm:**
- **Đoán Số**: 1000 - (lượt × 10)
- **Bò & Bê**: 1000 - (lượt × 15)
- **Bonus**: Streak, độ khó, speed

📈 **Leo rank:**
1. Chơi nhiều ván
2. Tăng win rate
3. Chơi độ khó cao
4. Maintain streak
5. Unlock achievements

💡 **Tips:**
- Xem profile top players để học
- So sánh stats với họ
- Luyện tập đều đặn

🌟 **Rewards:**
- Top 1: Champion badge
- Top 10: Gold badge
- Top 50: Silver badge
- Top 100: Bronze badge''';
  }

  static String _getDifficulty() {
    return '''📊 **CÁC MỨC ĐỘ KHÓ**

🟢 **EASY (Dễ)**
• **Đoán Số**: 1-50
• **Bò & Bê**: Gợi ý nhiều
• **Điểm thưởng**: 1x
• **Phù hợp**: Người mới bắt đầu

🟡 **MEDIUM (Trung bình)**
• **Đoán Số**: 1-100
• **Bò & Bê**: Gợi ý bình thường
• **Điểm thưởng**: 1.5x
• **Phù hợp**: Người có kinh nghiệm

🔴 **HARD (Khó)**
• **Đoán Số**: 1-1000
• **Bò & Bê**: Ít gợi ý
• **Điểm thưởng**: 2x
• **Phù hợp**: Chuyên gia

💡 **Lời khuyên:**
- Bắt đầu với Easy để làm quen
- Lên Medium khi win rate > 70%
- Thử Hard khi đã master Medium
- Mỗi độ khó có achievement riêng!''';
  }

  static String _getProjectInfo() {
    return '''📱 **TRUONG HIEU HUY - SMART STUDENT TOOLS**

🎮 **Tính năng chính:**

**1. Mini Games** 🎲
• Đoán Số (Guess Number)
• Bò & Bê (Mastermind)
• Leaderboard & Achievements

**2. Kajima AI** 🤖
• Trợ lý game thông minh
• Giải thích luật chơi
• Đưa ra tips & tricks
• Phân tích stats

**3. Công cụ hữu ích** 🛠️
• Dịch thuật (Translator)
• Báo thức (Alarm)
• Xem video (YouTube)

**4. Quản lý** 📊
• Profile cá nhân
• Thông tin nhóm
• Settings & themes

🎨 **UI/UX:**
• Material Design 3
• Dark/Light mode
• Smooth animations
• Responsive layout

💻 **Technology Stack:**
• Flutter 3.38.1 + Dart 3.10
• Provider state management
• Hive database
• Gemini AI API''';
  }

  static String _getAboutAI() {
    return '''🤖 **KAJIMA AI - GAME CONSULTANT**

👋 **Giới thiệu:**
Tôi là trợ lý AI của game này, được thiết kế để giúp bạn chơi tốt hơn!

💡 **Tôi có thể giúp gì:**
• Giải thích luật chơi chi tiết
• Đưa ra tips & strategies
• Phân tích thống kê
• Hướng dẫn unlock achievements
• Trả lời mọi thắc mắc về game

🎯 **Điểm mạnh:**
- Hiểu rõ tất cả game mechanics
- Cung cấp tips từ basic đến advanced
- Phân tích dữ liệu và đưa ra lời khuyên
- Hỗ trợ 24/7 mà không mệt mỏi!

💬 **Cách sử dụng:**
1. Hỏi bất kỳ câu hỏi nào về game
2. Dùng Quick Actions để tra cứu nhanh
3. Xem lịch sử chat để ôn lại tips

🌟 **Được phát triển bởi:**
Trương Hiếu Huy - 22DTHA2
Với công nghệ AI tiên tiến!''';
  }

  static String _getHelp() {
    return '''❓ **HƯỚNG DẪN SỬ DỤNG**

💬 **Hỏi về game:**
• "Cách chơi Đoán Số?"
• "Luật Bò & Bê là gì?"
• "Tips để chơi tốt hơn?"

📊 **Xem thống kê:**
• "Thống kê của tôi?"
• "Điểm số hiện tại?"
• "Tôi xếp hạng mấy?"

🏆 **Achievements:**
• "Còn huy hiệu nào chưa unlock?"
• "Cách mở khóa achievements?"

⚡ **Quick Actions:**
Các nút phía trên cho phép:
• Xem luật chơi nhanh
• Xem thống kê
• Nhận tips
• Xem achievements

🎯 **Tips sử dụng:**
- Hỏi câu ngắn gọn, rõ ràng
- Dùng Quick Actions để tra cứu nhanh
- Xem lịch sử chat để tham khảo lại

💡 **Lưu ý:**
Tôi là AI ngoại tuyến, nên có thể không trả lời được các câu hỏi phức tạp. Tuy nhiên, tôi hiểu rất rõ về game!''';
  }

  static String _getGreeting() {
    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour < 12) {
      timeGreeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      timeGreeting = 'Chào buổi chiều';
    } else {
      timeGreeting = 'Chào buổi tối';
    }

    return '''👋 **$timeGreeting!**

🤖 Tôi là **Kajima AI** - Game Consultant của bạn!

🎮 **Tôi có thể giúp bạn:**
• Giải thích luật chơi Đoán Số & Bò Bê
• Đưa ra tips & tricks để chơi tốt hơn
• Phân tích thống kê và thành tích
• Hướng dẫn unlock achievements
• Trả lời mọi câu hỏi về games

💡 **Hãy thử hỏi tôi:**
- "Cách chơi Đoán Số?"
- "Tips để thắng Bò & Bê?"
- "Thống kê của tôi thế nào?"
- "Còn huy hiệu nào chưa unlock?"

⚡ Hoặc dùng **Quick Actions** (các nút phía trên) để nhận thông tin nhanh chóng!

Chúc bạn chơi game vui vẻ! 🎯''';
  }

  static String _getGenericResponse(String msg) {
    // Analyze question type
    if (msg.contains('?') ||
        msg.contains('sao') ||
        msg.contains('thế nào') ||
        msg.contains('như thế nào') ||
        msg.contains('làm sao')) {
      return '''🤔 **Tôi chưa hiểu rõ câu hỏi của bạn.**

💡 **Tôi có thể giúp bạn về:**
• 🎲 Luật chơi game (Đoán Số, Bò & Bê)
• 💡 Tips & chiến thuật
• 📊 Thống kê và điểm số
• 🏆 Achievements và huy hiệu
• 📱 Tính năng của app

❓ **Hãy thử hỏi:**
- "Cách chơi Đoán Số?"
- "Tips để chơi Bò & Bê tốt hơn?"
- "Thống kê của tôi?"
- "Giới thiệu về app?"

⚡ **Hoặc dùng Quick Actions** bên trên để được hỗ trợ nhanh!''';
    }

    return '''💬 **Cảm ơn bạn đã chat với tôi!**

🤖 Tôi là **Kajima AI** - Game Consultant.

❓ **Tôi có thể giúp bạn:**
• Giải thích luật chơi các game
• Đưa ra tips và chiến thuật
• Phân tích thống kê
• Hướng dẫn unlock achievements
• Trả lời câu hỏi về app

💡 **Gợi ý câu hỏi:**
- "Cách chơi game X?"
- "Tips để thắng?"
- "Thống kê của tôi?"
- "Còn huy hiệu nào chưa unlock?"

⚡ **Quick Actions** (nút phía trên) giúp bạn tra cứu nhanh hơn!

🎮 Chúc bạn chơi game vui vẻ!''';
  }
}
