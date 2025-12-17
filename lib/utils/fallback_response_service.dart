/// Service for handling offline/fallback responses
class FallbackResponseService {
  /// Get fallback response for quick actions when API fails
  static String? getFallbackResponse(String action) {
    switch (action) {
      case 'rules_guess':
        return '''# 🎲 CÁCH CHƠI GAME ĐOÁN SỐ

**Mục tiêu:** Đoán đúng số bí mật trong ít lượt nhất!

## 📋 Luật Chơi:

### 🟢 Mức Easy (1-50)
- Phạm vi: 1 đến 50
- Số lượt tối đa: 7 lượt
- Điểm thưởng: 100 điểm/game thắng

### 🟡 Mức Medium (1-100)
- Phạm vi: 1 đến 100  
- Số lượt tối đa: 10 lượt
- Điểm thưởng: 200 điểm/game thắng

### 🔴 Mức Hard (1-200)
- Phạm vi: 1 đến 200
- Số lượt tối đa: 12 lượt
- Điểm thưởng: 300 điểm/game thắng

## 💡 Cách Chơi:
1. Chọn mức độ
2. Nhập số dự đoán
3. Xem gợi ý: "Cao hơn" hoặc "Thấp hơn"
4. Tiếp tục đoán cho đến khi đúng!

## 🏆 Thắng Game:
- Đoán đúng số trong giới hạn lượt
- Càng ít lượt → Càng nhiều điểm

**Chúc may mắn!** 🍀''';

      case 'rules_cowsbulls':
        return '''# 🐮 CÁCH CHƠI BÒ & BÊ (MASTERMIND)

**Mục tiêu:** Đoán đúng mã số 4 chữ số!

## 📋 Luật Chơi:

### 🟢 Mức Easy (4 chữ số, không trùng)
- Mã bí mật: 4 chữ số khác nhau (0-9)
- Ví dụ: 1234, 5678, 9021
- Số lượt tối đa: 12 lượt

### 🔴 Mức Hard (4 chữ số, có thể trùng)
- Mã bí mật: 4 chữ số bất kỳ (0-9)
- Ví dụ: 1123, 5555, 9090
- Số lượt tối đa: 15 lượt

## 🎯 Gợi Ý:

### 🐮 Bò (Bulls)
- Số đúng vị trí và giá trị
- Ví dụ: Mã là 1234, đoán 1567 → 1 Bò (số 1)

### 🐄 Bê (Cows)  
- Số đúng giá trị nhưng sai vị trí
- Ví dụ: Mã là 1234, đoán 4567 → 1 Bê (số 4)

## 💡 Chiến Thuật:
1. Thử các số khác nhau ở lượt đầu
2. Ghi nhớ kết quả Bò/Bê
3. Loại trừ các số không có
4. Thu hẹp phạm vi dần

## 🏆 Thắng Game:
- Đoán đúng: 4 Bò, 0 Bê
- Càng ít lượt → Càng cao điểm!

**Chúc thành công!** 🎉''';

      case 'stats':
      case 'my_stats':
        return '''# 📊 XEM THỐNG KÊ CHI TIẾT

## 🎮 **Cách Xem Stats Của Bạn:**

### 📱 Trong App:
1. **Bảng Xếp Hạng** 🏅
   - Menu chính → Leaderboard
   - Xem vị trí của bạn
   - So sánh với top players

2. **Màn Hình Achievements** 🏆  
   - Menu chính → Achievements
   - Xem progress và huy hiệu

3. **Trong Game**
   - Stats hiển thị khi chơi
   - Theo dõi tiến độ real-time

---

## 📈 **Stats Bao Gồm:**

### 🎲 Đoán Số:
- Tổng games: X games
- Win rate: X%
- Avg attempts: X lượt
- Best score: X điểm
- Rank: #X

### 🐮 Bò & Bê:
- Tổng games: X games  
- Win rate: X%
- Avg attempts: X lượt
- Best score: X điểm
- Rank: #X

### 🏆 Tổng Quan:
- Total playtime: X giờ
- Achievements: X/10 unlocked
- Total score: X điểm
- Global rank: #X

---

💡 **Lưu ý:** Tôi cần bạn chơi thêm vài games để phân tích stats chi tiết hơn!

_Dùng Quick Actions để xem info nhanh hơn!_ ⚡''';

      case 'tips':
        return '''# 💡 TIPS & TRICKS CHƠI GAME

## 🎲 ĐOÁN SỐ

### Chiến Thuật Binary Search:
1. **Bắt đầu ở giữa**
   - Easy (1-50): Thử 25
   - Medium (1-100): Thử 50
   - Hard (1-200): Thử 100

2. **Chia đôi phạm vi**
   - Cao hơn → Tìm nửa trên
   - Thấp hơn → Tìm nửa dưới

3. **Ví dụ (1-50):**
   - Thử 25 → "Cao hơn"
   - Thử 37 → "Thấp hơn"
   - Thử 31 → "Cao hơn"
   - Thử 34 → Đúng! ✅

### Tips Nâng Cao:
- Ghi nhớ phạm vi còn lại
- Luôn chọn số ở giữa
- Tránh đoán ngẫu nhiên

---

## 🐮 BÒ & BÊ

### Chiến Thuật Khởi Đầu:
1. **Lượt 1: Thử 0123**
   - Xác định có những số nào

2. **Lượt 2: Thử 4567**
   - Tìm thêm số còn lại

3. **Lượt 3-5: Xác định vị trí**
   - Hoán đổi vị trí các số đã biết

### Tips Nâng Cao:
- Ghi chép kết quả mỗi lượt
- Loại trừ số không có
- Tập trung vào Bò trước
- Với Hard: Cẩn thận số trùng

---

## 🏆 TIPS CHUNG

### Kiếm Điểm Cao:
- ✅ Hoàn thành càng nhanh càng tốt
- ✅ Dùng ít lượt hơn
- ✅ Chơi liên tục (combo)

### Mở Khóa Achievements:
- 🎯 **First Win:** Thắng game đầu tiên
- 🔥 **Win Streak:** Thắng 3 games liên tiếp
- ⚡ **Speed Demon:** Thắng < 5 lượt
- 💯 **Perfect Score:** Điểm tối đa

**Chúc bạn chơi game vui vẻ!** 🎮✨''';

      case 'achievements':
        return '''# 🏆 DANH SÁCH ACHIEVEMENTS

## 🎯 CÁC HUY HIỆU CÓ THỂ MỞ KHÓA:

### 🌟 Huy Hiệu Cơ Bản
1. **🎮 First Blood**
   - Thắng game đầu tiên
   - Điểm: 50

2. **🔟 Veteran**
   - Chơi 10 games
   - Điểm: 100

3. **💯 Century**
   - Chơi 100 games
   - Điểm: 500

### 🔥 Huy Hiệu Thành Tích
4. **🏆 Winner**
   - Thắng 10 games
   - Điểm: 200

5. **⚡ Speed Demon**
   - Thắng game < 5 lượt (Đoán Số)
   - Điểm: 300

6. **🎯 Perfect Score**
   - Đạt điểm tối đa 1 game
   - Điểm: 400

### 🚀 Huy Hiệu Cao Cấp
7. **🔥 Win Streak**
   - Thắng 3 games liên tiếp
   - Điểm: 500

8. **💎 Master**
   - Tỷ lệ thắng > 70%
   - Điểm: 1000

9. **👑 Legend**
   - Top 3 Leaderboard
   - Điểm: 2000

10. **🌈 Collector**
    - Mở khóa tất cả achievements khác
    - Điểm: 5000

## 💡 Tips Mở Khóa:
- Chơi đều đặn mỗi ngày
- Thử cả 2 game (Đoán Số & Bò Bê)
- Thử tất cả mức độ (Easy/Medium/Hard)
- Học chiến thuật để thắng nhanh

**Bạn đã mở khóa bao nhiêu huy hiệu rồi?** 🎖️''';

      case 'leaderboard':
        return '''# 🏅 BẢNG XẾP HẠNG

## 📊 CÁCH XẾP HẠNG:

### Điểm Được Tính:
- 🎲 **Đoán Số:** Điểm từ games
- 🐮 **Bò & Bê:** Điểm từ games  
- 🏆 **Achievements:** Điểm từ huy hiệu
- **Tổng điểm = Game Points + Achievement Points**

### Hạng Hiện Tại:
- 🥇 **Rank 1-3:** 🌟 Legend (Vàng)
- 🥈 **Rank 4-10:** 💎 Master (Bạc)
- 🥉 **Rank 11-20:** ⚡ Expert (Đồng)
- 📊 **Rank 21+:** 🎮 Player (Xám)

## 🎯 CÁCH LEO RANK:

### 1️⃣ Chơi Nhiều Games
- Mỗi game thắng = Điểm
- Càng khó → Càng nhiều điểm

### 2️⃣ Mở Khóa Achievements  
- Mỗi achievement = Bonus điểm lớn
- Ưu tiên các achievement dễ trước

### 3️⃣ Duy Trì Win Rate Cao
- Thắng nhiều hơn thua
- Ảnh hưởng đến rank

### 4️⃣ Chơi Mức Khó
- Hard mode = Điểm x1.5
- Rủi ro cao nhưng lợi nhuận cao

## 💡 Tips Leo Top:
- ✅ Chơi đều đặn mỗi ngày
- ✅ Focus vào achievements dễ
- ✅ Học chiến thuật chơi tốt
- ✅ Tránh thua streak

**Xem leaderboard trong app để biết rank của bạn!** 🏆

Bạn đang ở hạng mấy? Hãy chơi game để tôi biết chính xác!''';

      case 'rules_memory':
        return '''# 🧩 CÁCH CHƠI MEMORY MATCH (LẬT THẺ)

**Mục tiêu:** Tìm tất cả các cặp thẻ giống nhau!

## 📋 Luật Chơi:

### 🎯 Cách Chơi:
1. Tất cả thẻ úp ngửa, hiển thị "?"
2. Click 2 thẻ bất kỳ để lật
3. Nếu **giống nhau** → Giữ nguyên ✅
4. Nếu **khác nhau** → Tự động úp lại ❌
5. Tiếp tục đến khi tìm hết 8 cặp

## 📊 3 Độ Khó:

### 🟢 Easy
- Lưới: 4×4 (16 thẻ = 8 cặp)
- Preview: 5 giây xem trước
- Target: < 60 giây
- Điểm: moves × 10

### 🟡 Normal
- Lưới: 4×4 (16 thẻ = 8 cặp)
- Preview: 3 giây xem trước
- Target: < 45 giây
- Điểm: moves × 15

### 🔴 Hard (Double Coding)
- Lưới: 4×4 (16 thẻ = 8 cặp)
- Preview: 2 giây xem trước
- **Challenge: Icon + Màu phải khớp!** 🎨
- Target: < 90 giây
- Điểm: moves × 20

## 🏆 Tính Điểm:
```
Score = moves × difficulty_multiplier
Time bonus = max(0, target - actual) × 5
Final = Score + Time bonus
```

## 💡 Pro Tips:
- **Tập trung preview phase** - Ghi nhớ nhiều nhất
- **Lật theo pattern** - Trái→phải, trên→dưới
- **Nhớ thẻ sai** - Khi sai, nhớ cả 2 vị trí
- **Minimize moves** - Ít lượt = điểm cao
- **Speed matters** - Nhanh = time bonus

**Chúc bạn có trí nhớ siêu phàm!** 🧠✨''';

      case 'rules_quickmath':
        return '''# ⚡ CÁCH CHƠI QUICK MATH (TOÁN NHANH)

**Mục tiêu:** Trả lời đúng nhiều phép tính nhất!

## 📋 Luật Chơi:

### 🎯 Cơ Chế:
1. Bạn có **3 HP** (trái tim) ❤️❤️❤️
2. Mỗi câu có **10 giây** + 4 đáp án
3. Đúng → +1 điểm, giữ HP ✅
4. Sai/Hết giờ → Mất 1 HP ❌
5. Hết HP = Game Over 💀

## 📊 3 Độ Khó:

### 🟢 Easy
- Phép tính: +, - (1-50)
- Ví dụ: 15 + 23 = ?
- Time: 10s/câu
- Điểm: 1 điểm/câu

### 🟡 Normal
- Phép tính: +, -, ×, ÷ (1-100)
- Ví dụ: 8 × 7 = ?
- Time: 10s/câu
- Điểm: 1 điểm/câu

### 🔴 Hard
- Phép tính: Tất cả (1-200)
- Phức tạp hơn
- Time: 10s/câu
- Điểm: 1 điểm/câu

## ⚡ 3 Power-ups (2 lần mỗi loại):

**⏸️ Time Freeze**
- Đóng băng timer 3 giây
- Dùng cho phép khó

**⏭️ Skip**
- Bỏ qua câu, không mất HP
- Dùng khi còn 1 HP

**50-50**
- Ẩn 2 đáp án sai
- Tăng odds 25% → 50%

## 🔥 Streak Bonus:
```
≥5 câu đúng liên tiếp → +2 điểm/câu
```

## 💡 Pro Strategies:
- **Accuracy > Speed** - Đúng quan trọng hơn nhanh
- **Save power-ups** - Dùng khi thật sự cần
- **Protect streak** - Khi ≥5, chơi cẩn thận
- **Mental math tricks** - Nhân 5 = ×10 rồi ÷2

**Chúc bạn tính toán nhanh như chớp!** ⚡🧮''';

      case 'about_ai':
        return '''# 🤖 VỀ KAJIMA AI CHATBOT

**Kajima AI** - Trợ lý thông minh của bạn!

## 🎯 Khả Năng:

### 1. Hỗ Trợ Game
- Giải thích luật chơi chi tiết
- Tips & strategies
- Phân tích lỗi sai
- Gợi ý cải thiện

### 2. Thống Kê & Phân Tích
- Đọc và giải thích stats
- So sánh với top players
- Roadmap cải thiện
- Tracking progress

### 3. Tư Vấn Achievements
- Liệt kê huy hiệu chưa unlock
- Hướng dẫn cách đạt
- Ước tính thời gian
- Tips farming điểm

### 4. Giải Đáp Thắc Mắc
- Trả lời câu hỏi về game
- Giải thích mechanics
- Debug strategies
- Recommend next steps

## 🌟 Đặc Điểm:

**Offline-First**
- Hoạt động không cần internet
- Instant response
- No waiting time

**Context-Aware**
- Hiểu ngữ cảnh câu hỏi
- Nhớ lịch sử chat
- Smart suggestions

**Multilingual**
- Tiếng Việt tự nhiên
- Hiểu slang & viết tắt
- Friendly tone

## 💡 Công Nghệ:

**Online Mode:**
- Gemini AI API
- Advanced NLP
- Real-time processing

**Offline Mode:**
- Intelligent Fallback
- Pre-trained responses
- Context integration

## 🎮 Quick Actions:
- Trả lời ngay - không chờ
- 9 actions có sẵn
- Tap để sử dụng

**Chat ngay để trải nghiệm!** 💬✨''';

      case 'about_p2p':
        return '''# 💬 VỀ P2P CHAT

**P2P Chat** - Nhắn tin nội bộ với team!

## 🎯 Tính Năng:

### 1. Chat 1-1
- Nhắn tin riêng tư
- Real-time messaging
- Tin nhắn mới ở dưới cùng
- Auto scroll to latest

### 2. Quản Lý Tin Nhắn
- Long press để chọn
- Xóa nhiều tin nhắn
- Selection mode
- Confirm trước khi xóa

### 3. Danh Sách Bạn Bè
- Xem tất cả members
- Unread badge count
- Thông tin chi tiết
- Click để chat

### 4. UI/UX
- Message bubbles đẹp
- Phân biệt sender/receiver
- Timestamp rõ ràng
- Smooth animations

## 🔔 Notifications:

**Mark as Read**
- Tự động khi vào chat
- Badge count update
- Visual indicators

**Unread Count**
- Hiển thị số tin chưa đọc
- Badge trên avatar
- Real-time update

## 💾 Lưu Trữ:

**Local Database**
- Hive storage
- Chat history persist
- Không mất khi restart
- Fast query

**Privacy**
- Local-only storage
- Không upload server
- Privacy-first
- No tracking

## 🎨 Interface:

**Modern Design**
- Material 3
- Card layouts
- Emoji support
- Dark/Light theme

**Responsive**
- Smooth scroll
- Quick reply
- Input validation
- Error handling

## 💡 Tips:

- Long press để xóa nhiều
- Check badge để không bỏ lỡ
- Chat history được lưu

**Bắt đầu nhắn tin ngay!** 💬🚀''';

      default:
        return null;
    }
  }

  /// Get error message when API is unavailable
  static String getApiUnavailableMessage() {
    return '''🔌 **Không thể kết nối API**

Hiện tại tôi không thể kết nối đến Gemini AI.

**Bạn vẫn có thể:**
- ✅ Sử dụng **Quick Actions** (các nút phía trên)
- ✅ Xem thông tin về game
- ✅ Nhận tips và hướng dẫn

**Các câu hỏi tùy chỉnh:**
- ❌ Tạm thời không khả dụng
- 🔄 Vui lòng thử lại sau 5-10 phút

💡 **Gợi ý:** Hãy tap vào Quick Actions để nhận thông tin ngay lập tức!''';
  }
}
