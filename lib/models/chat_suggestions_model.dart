/// Model cho suggestion chip/menu item
class ChatSuggestion {
  final String id;
  final String title;
  final String icon;
  final String? description;
  final List<ChatSuggestion>? subItems;
  final String? fullResponse;

  ChatSuggestion({
    required this.id,
    required this.title,
    required this.icon,
    this.description,
    this.subItems,
    this.fullResponse,
  });

  bool get hasSubItems => subItems != null && subItems!.isNotEmpty;
}

/// Service quản lý suggestions và menu hierarchy
class ChatSuggestionsService {
  /// Get main category suggestions
  static List<ChatSuggestion> getMainSuggestions() {
    return [
      ChatSuggestion(
        id: 'features',
        title: 'Chức năng hệ thống',
        icon: '🎯',
        description: 'Khám phá tất cả tính năng',
        subItems: _getFeatureSuggestions(),
      ),
      ChatSuggestion(
        id: 'games',
        title: 'Hướng dẫn Game',
        icon: '🎮',
        description: 'Luật chơi & tips',
        subItems: _getGameSuggestions(),
      ),
      ChatSuggestion(
        id: 'stats',
        title: 'Thống kê & Thành tích',
        icon: '📊',
        description: 'Xem progress của bạn',
        subItems: _getStatsSuggestions(),
      ),
      ChatSuggestion(
        id: 'help',
        title: 'Trợ giúp',
        icon: '❓',
        description: 'FAQ & Hướng dẫn',
        subItems: _getHelpSuggestions(),
      ),
      ChatSuggestion(
        id: 'about',
        title: 'Về Project',
        icon: '📱',
        description: 'Thông tin chi tiết',
        subItems: _getAboutSuggestions(),
      ),
    ];
  }

  /// Feature suggestions
  static List<ChatSuggestion> _getFeatureSuggestions() {
    return [
      ChatSuggestion(
        id: 'features_games',
        title: '🎲 Mini Games',
        icon: '🎮',
        fullResponse: '''🎮 **MINI GAMES - TRÒ CHƠI TRÍ TUỆ**

📦 **Bao gồm 4 game chính:**

**1. 🎲 Đoán Số (Guess Number)**
• Đoán số bí mật trong ít lượt nhất
• 3 độ khó: Easy (1-50), Normal (1-100), Hard (1-200)
• Sử dụng chiến thuật Binary Search để tối ưu
• Điểm cao khi đoán với ít lượt nhất

**2. 🐮 Bò & Bê (Cows & Bulls)**
• Đoán mã 4 chữ số bí mật
• Nhận gợi ý: Bò (đúng vị trí) và Bê (đúng số sai vị trí)
• Tối đa 10 lượt đoán
• Cần logic và chiến thuật phân tích

**3. 🧩 Memory Match (Lật Thẻ)**
• Tìm các cặp thẻ giống nhau
• Lưới 4×4 với 8 cặp thẻ
• Hard mode: Double Coding (icon + màu phải khớp!)
• Tính điểm theo moves và time

**4. ⚡ Quick Math (Toán Nhanh)**
• Trả lời phép tính trong 10 giây
• 3 HP, mỗi câu sai/hết giờ mất 1 HP
• Power-ups: Time Freeze, Skip, 50-50
• Streak bonus: ≥5 câu đúng → +2 điểm/câu

🏆 **Tính năng đặc biệt:**
• Leaderboard - bảng xếp hạng toàn cầu
• Achievement System - hệ thống huy hiệu
• Statistics - theo dõi tiến độ chi tiết
• Multiple difficulties - 3 độ khó mỗi game

💡 **Mục đích:**
Rèn luyện tư duy logic, trí nhớ, tính toán nhanh và khả năng giải quyết vấn đề!''',
      ),
      ChatSuggestion(
        id: 'features_ai',
        title: '🤖 Kajima AI',
        icon: '💬',
        fullResponse: '''🤖 **KAJIMA AI - GAME CONSULTANT THÔNG MINH**

🎯 **Khả năng của AI:**

**1. Hỗ trợ Game**
• Giải thích luật chơi chi tiết
• Đưa ra tips & strategies
• Phân tích lỗi sai thường gặp
• Gợi ý cách cải thiện kỹ năng

**2. Thống kê & Phân tích**
• Đọc và giải thích stats của bạn
• So sánh với top players
• Đưa ra roadmap cải thiện
• Tracking progress theo thời gian

**3. Tư vấn Achievements**
• Liệt kê huy hiệu chưa unlock
• Hướng dẫn cách đạt được
• Ước tính thời gian hoàn thành
• Tips farming điểm nhanh

**4. Giải đáp thắc mắc**
• Trả lời mọi câu hỏi về game
• Giải thích mechanics phức tạp
• Debug chiến thuật không hiệu quả
• Recommend next steps

🌟 **Đặc điểm:**
• Offline-first: Hoạt động không cần internet
• Instant response: Trả lời ngay lập tức
• Context-aware: Hiểu ngữ cảnh câu hỏi
• Multilingual: Hỗ trợ tiếng Việt tốt

💡 **Công nghệ:**
• Gemini AI API (khi online)
• Intelligent Fallback System (offline)
• Natural Language Processing
• Game Context Integration''',
      ),
      ChatSuggestion(
        id: 'features_p2p',
        title: '💬 P2P Chat',
        icon: '🗨️',
        fullResponse: '''💬 **P2P CHAT - NHẮN TIN NỘI BỘ**

🎯 **Tính năng chính:**

**1. Chat 1-1**
• Nhắn tin riêng tư với từng thành viên
• Tin nhắn mới nhất hiển thị ở dưới cùng
• Tự động scroll đến tin nhắn mới
• Real-time messaging

**2. Quản lý tin nhắn**
• Long press để chọn tin nhắn
• Xóa nhiều tin nhắn cùng lúc
• Selection mode với checkbox
• Confirmation dialog khi xóa

**3. Danh sách bạn bè**
• Xem tất cả thành viên trong team
• Badge hiển thị số tin nhắn chưa đọc
• Click vào bạn để mở chat
• Thông tin chi tiết: MSSV, số điện thoại

**4. UI/UX**
• Message bubbles phân biệt sender/receiver
• Timestamp cho mỗi tin nhắn
• Empty state khi chưa có tin nhắn
• Smooth animations

🔔 **Thông báo:**
• Mark as read khi vào chat
• Unread count tự động cập nhật
• Visual indicators rõ ràng

💾 **Lưu trữ:**
• Hive database local storage
• Chat history persistent
• Không mất dữ liệu khi restart app
• Fast query performance

🔒 **Bảo mật:**
• Local-only (không upload server)
• Privacy-first approach
• No data collection

💡 **Tips sử dụng:**
• Long press tin nhắn để xóa nhiều
• Scroll tự động đến tin nhắn mới
• Check unread badge để không bỏ lỡ tin nhắn''',
      ),
      ChatSuggestion(
        id: 'features_social',
        title: '👥 Kết bạn & Nhóm',
        icon: '🤝',
        fullResponse: '''👥 **KẾT BẠN & TẠO NHÓM**

🎯 **Tính năng social:**

**1. Kết bạn**
• Gửi lời mời kết bạn
• Chấp nhận/Từ chối friend request
• Danh sách bạn bè
• Unfriend nếu cần

**2. Tạo & Quản lý nhóm**
• Tạo nhóm mới
• Thêm thành viên vào nhóm
• Rời khỏi nhóm
• Admin controls

**3. Friend Requests**
• Xem lời mời kết bạn đang pending
• Accept/Reject nhanh
• Notification badges
• Request history

**4. Group Management**
• Xem tất cả nhóm đã tham gia
• Member list trong nhóm
• Group chat (upcoming)
• Group stats & activities

🔔 **Notifications:**
• Friend request notification
• Group invitation alerts
• Activity updates
• Badge counters

💾 **Data sync:**
• Hive database local
• FriendProvider & GroupProvider
• Real-time state management
• No data loss

🎨 **UI/UX:**
• Material Design 3
• Card-based layouts
• Smooth animations
• Intuitive interactions

💡 **Test features:**
• Social Test Screen để thử nghiệm
• Mock data có sẵn
• Debug mode helpers

📝 **How to use:**
1. Vào Social Test Screen
2. Thêm bạn bằng email
3. Accept/Reject requests
4. Tạo nhóm và mời bạn tham gia''',
      ),
      ChatSuggestion(
        id: 'features_tools',
        title: '🛠️ Công cụ tiện ích',
        icon: '⚙️',
        fullResponse: '''🛠️ **CÔNG CỤ TIỆN ÍCH - SMART TOOLS**

📦 **Bộ công cụ hỗ trợ học tập:**

**1. 📝 Dịch thuật (Translator)**
• Dịch đa ngôn ngữ
• Hỗ trợ văn bản dài
• Text-to-Speech
• Copy nhanh kết quả

**2. ⏰ Báo thức (Alarm)**
• Đặt nhiều báo thức
• Custom âm thanh
• Snooze & repeat
• Smart scheduling

**3. ▶️ Xem video (YouTube)**
• Phát video YouTube trong app
• Picture-in-Picture mode
• Playlist management
• Offline download (coming soon)

**4. 🤖 Kajima AI**
• Chat với AI consultant
• Quick Actions
• History tracking
• Smart suggestions

🎯 **Thiết kế:**
• Material Design 3
• Intuitive interface
• Dark/Light mode
• Smooth animations

💡 **Tích hợp:**
• Native Android features
• Cloud sync (coming soon)
• Cross-device support
• Offline-first approach''',
      ),
      ChatSuggestion(
        id: 'features_profile',
        title: '👤 Quản lý Profile',
        icon: '📋',
        fullResponse: '''👤 **QUẢN LÝ PROFILE & NHÓM**

📦 **Tính năng Profile:**

**1. Thông tin cá nhân**
• Họ tên, MSSV, Lớp
• Số điện thoại, Email
• Avatar & Cover photo
• Edit profile dễ dàng

**2. Tiện ích nhanh**
• 📞 Gọi khẩn cấp (Emergency Call)
• 🤖 Chat với Kajima AI
• Truy cập nhanh các chức năng quan trọng

**3. Quản lý Nhóm (Team)**
• Xem danh sách thành viên
• Chỉnh sửa thông tin member
• Xóa thành viên (chỉ leader)
• Sync thông tin 2 chiều

**4. Đồng bộ dữ liệu**
• Auto-sync giữa Profile và Group
• Update realtime
• UserDataService quản lý tập trung
• Không lo mất dữ liệu

🎨 **UI/UX:**
• Gradient header đẹp mắt
• Avatar overlay design
• Card-based layout
• Responsive & smooth

💡 **Bảo mật:**
• Local storage với Hive
• Encrypted data (coming soon)
• Backup & restore
• Privacy controls''',
      ),
      ChatSuggestion(
        id: 'features_themes',
        title: '🎨 Giao diện',
        icon: '🌈',
        fullResponse: '''🎨 **HỆ THỐNG GIAO DIỆN**

🌈 **Theme Options:**

**1. 🌞 Light Mode**
• Sáng sủa, dễ nhìn ban ngày
• High contrast cho văn bản
• Màu pastel dịu mắt
• Phù hợp môi trường sáng

**2. 🌙 Dark Mode**
• Giảm mỏi mắt ban đêm
• Tiết kiệm pin OLED
• Màu accent nổi bật
• Aesthetic & modern

**3. 🤖 System Default**
• Tự động theo hệ thống
• Switch theo giờ
• Seamless transition
• Best of both worlds

🎯 **Material Design 3:**
• Dynamic colors
• Smooth animations
• Elevation & shadows
• Rounded corners

💡 **Tính năng:**
• Instant theme switching
• No lag or flash
• Persistent preference
• Consistent across screens

🎨 **Color Palette:**
• Primary: Blue gradient
• Secondary: Purple accent
• Success: Green
• Warning: Orange
• Error: Red
• Neutral: Grays

✨ **Effects:**
• Ripple animations
• Blur backgrounds
• Gradient overlays
• Glass morphism''',
      ),
    ];
  }

  /// Game suggestions
  static List<ChatSuggestion> _getGameSuggestions() {
    return [
      ChatSuggestion(
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
• Đoán càng nhanh, điểm càng cao!
• Bonus: Streak, độ khó, perfect game

💡 **Chiến thuật Binary Search:**
1. Đoán số ở giữa phạm vi
2. Thu hẹp phạm vi dựa trên gợi ý
3. Lặp lại đến khi tìm ra đáp án

**Ví dụ với 1-100:**
• Đoán 50 → "Cao hơn"
• Phạm vi mới: 51-100
• Đoán 75 → "Thấp hơn"
• Phạm vi mới: 51-74
• Đoán 62 → "Cao hơn"
• Phạm vi mới: 63-74
• ...tiếp tục cho đến khi đúng!''',
      ),
      ChatSuggestion(
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

📝 **Ví dụ minh họa:**

**Mã bí mật:** `1234`

| Đoán   | Kết quả      | Giải thích |
|--------|--------------|------------|
| `1456` | 1🐄 1🐮     | 1 đúng vị trí (1), 4 đúng số sai vị trí |
| `5678` | 0🐄 0🐮     | Không có số nào đúng |
| `1243` | 2🐄 2🐮     | 1,2 đúng vị trí; 3,4 đúng số sai vị trí |
| `1234` | 4🐄 0🐮     | **THẮNG!** Tất cả đúng |

💡 **Chiến thuật 3 bước:**

**Bước 1: Tìm các số (lượt 1-3)**
```
Đoán: 0123, 4567, 8901
→ Xác định 4 số có trong mã
```

**Bước 2: Xác định vị trí (lượt 4-6)**
```
Giả sử biết có: 1, 2, 3, 4
Đoán: 1234, 1243, 1324...
→ Dựa vào Bò/Bê để suy luận vị trí
```

**Bước 3: Tinh chỉnh (lượt 7-10)**
```
Hoán vị các số còn không chắc
→ Tìm ra đáp án chính xác
```

🏆 **Điều kiện thắng:**
• Đạt **4🐄 0🐮** = Hoàn hảo!
• Tối đa 10 lượt

⏱️ **Scoring:**
```
Điểm = 1000 - (lượt × 15)
```''',
      ),
      ChatSuggestion(
        id: 'game_memory_rules',
        title: '📖 Luật Memory Match',
        icon: '🧩',
        fullResponse: '''🧩 **LUẬT CHƠI MEMORY MATCH (LẬT THẺ)**

📋 **Mục tiêu:** Tìm tất cả các cặp thẻ giống nhau

🎯 **Cách chơi:**
1. Tất cả thẻ úp ngửa, hiện "?"
2. Click 2 thẻ bất kỳ để lật
3. Nếu 2 thẻ **giống nhau** → Giữ nguyên (matched) ✅
4. Nếu 2 thẻ **khác nhau** → Tự động úp lại ❌
5. Tiếp tục cho đến khi tìm hết tất cả cặp

📊 **3 Độ khó:**

**🟢 Easy:**
• Lưới: 4x4 (16 thẻ = 8 cặp)
• Preview: 5 giây xem trước
• Target time: < 60 giây
• Điểm: moves × 10

**🟡 Normal:**
• Lưới: 4x4 (16 thẻ = 8 cặp)
• Preview: 3 giây xem trước
• Target time: < 45 giây
• Điểm: moves × 15

**🔴 Hard (Double Coding):**
• Lưới: 4x4 (16 thẻ = 8 cặp)
• Preview: 2 giây xem trước
• Challenge: **Cùng icon nhưng khác màu!** 🎨
• Phải khớp cả icon VÀ màu
• Target time: < 90 giây
• Điểm: moves × 20

🏆 **Tính điểm:**
```
Score = moves × difficulty_multiplier
Time bonus = max(0, target_time - actual_time) × 5
Final score = Score + Time bonus
```

💡 **Pro Tips:**
• **Tập trung ở preview phase** - Ghi nhớ vị trí nhiều nhất có thể
• **Lật theo pattern** - Lật tuần tự từ trái → phải, trên → dưới
• **Ghi nhớ thẻ sai** - Khi lật sai, nhớ cả 2 vị trí
• **Minimize moves** - Càng ít lượt, điểm càng cao
• **Speed matters** - Hoàn thành nhanh = time bonus

🎮 **Tính năng đặc biệt:**
• Beautiful icons: 50+ Material Design Icons
• Smooth animations: 3D flip perspective
• Hint system: Glow effect cho gợi ý
• Sound effects: Haptic feedback khi match''',
      ),
      ChatSuggestion(
        id: 'game_quickmath_rules',
        title: '📖 Luật Quick Math',
        icon: '⚡',
        fullResponse: '''⚡ **LUẬT CHƠI QUICK MATH (TOÁN NHANH)**

📋 **Mục tiêu:** Trả lời đúng càng nhiều phép tính trong thời gian giới hạn

🎯 **Cách chơi:**
1. Bạn có **3 HP** (trái tim) ❤️❤️❤️
2. Mỗi câu hỏi có **10 giây** và 4 đáp án
3. Chọn đáp án đúng → +1 điểm, giữ nguyên HP ✅
4. Chọn sai HOẶC hết giờ → Mất 1 HP ❌
5. Hết HP = Game Over 💀

📊 **3 Độ khó:**

**🟢 Easy:**
• Phép tính: +, - trong phạm vi 1-50
• Ví dụ: 15 + 23 = ?
• Time: 10s/câu
• Điểm mỗi câu: 1

**🟡 Normal:**
• Phép tính: +, -, ×, ÷ trong phạm vi 1-100
• Ví dụ: 8 × 7 = ?
• Time: 10s/câu
• Điểm mỗi câu: 1

**🔴 Hard:**
• Phép tính: Tất cả trong phạm vi 1-200
• Bao gồm: Phân số, % (upcoming)
• Time: 10s/câu
• Điểm mỗi câu: 1

⚡ **3 Power-ups (mỗi loại 2 lần):**

• **⏸️ Time Freeze**: Đóng băng timer 3 giây
• **⏭️ Skip**: Bỏ qua câu khó, không mất HP
• **50-50**: Ẩn 2 đáp án sai, chỉ còn 2 lựa chọn

🏆 **Hệ thống Level & Streak:**
```
Điểm tích lũy → Tăng level vô hạn
Streak ≥ 5 câu đúng liên tiếp → Bonus +2 điểm/câu
```

💡 **Pro Strategies:**
• **Accuracy > Speed**: Đúng quan trọng hơn nhanh (vì mất HP = game over)
• **Power-up management**: 
  - Time Freeze cho phép nhân/chia khó
  - Skip khi còn 1 HP và câu quá khó
  - 50-50 khi không chắc chắn
• **Streak focus**: Cố gắng giữ streak ≥5 để double điểm
• **Mental math**: Luyện tập tính nhẩm để nhanh hơn
• **Division tip**: Tất cả phép chia đều chia hết (no remainder)

🎮 **UI/UX Features:**
• Visual HP hearts: ❤️❤️❤️ → 💔💔💔
• Animated timer bar: Xanh → Đỏ khi < 30%
• Squash animation: Button bóp khi tap
• Celebration effects: Khi streak ≥5''',
      ),
      ChatSuggestion(
        id: 'game_tips',
        title: '💡 Tips & Tricks',
        icon: '✨',
        fullResponse: '''💡 **TIPS & TRICKS CHO TẤT CẢ 4 GAME**

🎯 **Đoán Số - Pro Tips:**

**1. Binary Search Algorithm**
• Luôn chia đôi phạm vi
• Đoán số ở giữa
• Thu hẹp phạm vi sau mỗi lượt

**2. Tối ưu theo độ khó**
• Easy (1-50): ≤ 6 lượt
• Medium (1-100): ≤ 7 lượt
• Hard (1-1000): ≤ 10 lượt

**3. Mental Math**
• Nhớ phạm vi hiện tại
• Tính toán nhanh số giữa
• Không đoán ngẫu nhiên

---

🐮 **Bò & Bê - Advanced Tactics:**

**1. Elimination Strategy**
```
Lượt 1-3: Tìm ra 4 số
Lượt 4-6: Xác định vị trí
Lượt 7-10: Fine-tuning
```

**2. Pattern Recognition**
• Ghi nhớ các feedback
• Loại trừ các khả năng không hợp lệ
• Ưu tiên các vị trí có Bò

**3. Logical Deduction**
```
Nếu 1234 → 2🐄 1🐮
và 1243 → 1🐄 2🐮
→ Số 1 đúng vị trí 1
→ Số 4 không ở vị trí 2 và 4
```

---

🧩 **Memory Match - Memory Tactics:**

**1. Preview Phase Strategy**
• Scan từ trái → phải, trên → dưới
• Nhóm thẻ theo vị trí (top-left, center, etc.)
• Focus vào các icon đặc biệt/dễ nhớ

**2. Flip Pattern**
```
Optimal: Lật theo hàng ngang
Row 1: Cards 1-4
Row 2: Cards 5-8
Row 3: Cards 9-12
Row 4: Cards 13-16
```

**3. Failed Match Memory**
• Khi lật sai, GHI NHỚ CẢ 2 vị trí
• Ví dụ: Card 3 (🌟) và Card 11 (🎮) không match
• Sau này thấy 🌟 → biết cặp ở vị trí nào

**4. Hard Mode (Double Coding)**
• Màu quan trọng hơn icon!
• Nhóm theo màu: Red icons, Blue icons, etc.
• Không vội, kiểm tra kỹ cả icon VÀ màu

---

⚡ **Quick Math - Speed Tactics:**

**1. Accuracy First Mindset**
```
Sai 1 câu = -1 HP (chỉ có 3 HP!)
Đúng chậm > Sai nhanh
```

**2. Power-up Priority**
• **Time Freeze**: Dùng cho nhân/chia 2 chữ số
• **Skip**: Dùng khi còn 1 HP và câu rất khó
• **50-50**: Khi không chắc, tăng odds từ 25% → 50%

**3. Mental Math Tricks**
```
Nhân với 5: × 10 rồi ÷ 2
Ví dụ: 24 × 5 = 240 ÷ 2 = 120

Chia cho 5: × 2 rồi ÷ 10
Ví dụ: 85 ÷ 5 = 170 ÷ 10 = 17

Gần 10: Adjust
Ví dụ: 19 + 28 = (20-1) + (30-2) = 50 - 3 = 47
```

**4. Streak Protection**
• Khi có streak ≥5, chơi cẩn thận hơn
• Bonus +2 điểm/câu rất lớn
• Không rush khi đang trong streak

---

🏆 **Farming Điểm Tổng Quát:**

**1. Daily Routine**
• Chơi mỗi game ít nhất 2 ván/ngày
• Maintain winning streak
• Complete daily challenges (upcoming)

**2. Difficulty Progression**
• Master Easy: Win rate > 80%
• Upgrade Medium: Win rate > 70%
• Challenge Hard: Khi confident

**3. Achievement Hunting**
• Focus vào huy hiệu gần đạt (check %)
• Chơi theo mục tiêu cụ thể
• Track progress trong Achievements screen

**4. Game Selection Strategy**
• **Morning**: Quick Math (brain warm-up)
• **Afternoon**: Memory Match (focus training)
• **Evening**: Đoán Số, Bò & Bê (logic games)

💎 **Mindset:**
• Kiên nhẫn và tập trung
• Học từ mỗi ván thua
• Phân tích lỗi sai
• Practice makes perfect!''',
      ),
      ChatSuggestion(
        id: 'game_difficulty',
        title: '📊 Độ khó',
        icon: '⚡',
        fullResponse: '''📊 **HỆ THỐNG ĐỘ KHÓ - 4 GAMES**

🎮 **Chi tiết từng mức:**

---

🟢 **EASY (Dễ) - Người Mới Bắt Đầu**

**🎲 Đoán Số:**
• Phạm vi: 1-50
• Lượt tối ưu: ≤ 6
• Điểm: moves × 10

**🐮 Bò & Bê:**
• Mã: 4 số khác nhau
• Gợi ý: Detailed feedback
• Thời gian: Không giới hạn
• Điểm: moves × 10

**🧩 Memory Match:**
• Lưới: 4×4 (8 cặp)
• Preview: 5 giây
• Target: < 60s
• Điểm: moves × 10

**⚡ Quick Math:**
• Phép tính: +, - (1-50)
• Time: 10s/câu
• HP: 3 trái tim
• Điểm: +1/câu đúng

💡 **Phù hợp:** Học cách chơi, làm quen mechanics

---

🟡 **NORMAL (Trung Bình) - Có Kinh Nghiệm**

**🎲 Đoán Số:**
• Phạm vi: 1-100
• Lượt tối ưu: ≤ 7
• Điểm: moves × 15

**🐮 Bò & Bê:**
• Mã: 4 số phức tạp
• Gợi ý: Standard
• Thời gian: < 5 phút
• Điểm: moves × 15

**🧩 Memory Match:**
• Lưới: 4×4 (8 cặp)
• Preview: 3 giây
• Target: < 45s
• Điểm: moves × 15

**⚡ Quick Math:**
• Phép tính: +, -, ×, ÷ (1-100)
• Time: 10s/câu
• HP: 3 trái tim
• Điểm: +1/câu đúng

💡 **Phù hợp:** Đã nắm vững luật, cần thử thách

---

🔴 **HARD (Khó) - Chuyên Gia**

**🎲 Đoán Số:**
• Phạm vi: 1-1000
• Lượt tối ưu: ≤ 10
• Điểm: moves × 20

**🐮 Bò & Bê:**
• Mã: Maximum difficulty
• Gợi ý: Minimal
• Thời gian: Pressure mode
• Điểm: moves × 20

**🧩 Memory Match (Double Coding):**
• Lưới: 4×4 (8 cặp)
• Preview: 2 giây
• **Challenge: Icon + Color match!** 🎨
• Target: < 90s
• Điểm: moves × 20

**⚡ Quick Math:**
• Phép tính: Tất cả (1-200)
• Time: 10s/câu
• HP: 3 trái tim
• Điểm: +1/câu đúng

💡 **Phù hợp:** Master game, muốn top leaderboard

---

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

🏆 **Benefits mỗi độ khó:**
• Unique achievements
• Higher score multiplier
• Better rewards
• Prestige & bragging rights

💡 **Game-Specific Tips:**

**Đoán Số & Bò Bê:**
• Easy → Medium: Big jump in range
• Hard: Chỉ dành cho experts

**Memory Match:**
• Easy → Normal: Ít preview time hơn
• Hard (Double Coding): Thử thách tối thượng!

**Quick Math:**
• Easy: Làm quen phép tính cơ bản
• Normal: Thêm nhân/chia
• Hard: Speed + Accuracy cả 2

🎯 **Recommendation:**
• Chơi Easy để làm quen (2-3 ván)
• Practice ở Normal (main difficulty)
• Challenge ở Hard (when ready)
• Mix cả 3 để unlock tất cả achievements!''',
      ),
    ];
  }

  /// Stats suggestions
  static List<ChatSuggestion> _getStatsSuggestions() {
    return [
      ChatSuggestion(
        id: 'stats_view',
        title: '📊 Xem thống kê',
        icon: '📈',
        fullResponse: '''📊 **XEM THỐNG KÊ CHI TIẾT**

🎯 **Cách truy cập:**
1. Vào màn hình **Leaderboard**
2. Nhấn nút **"Thống kê của tôi"** (My Stats)
3. Xem dashboard đầy đủ

📈 **Các chỉ số theo dõi:**

**1. Tổng quan (Overview)**
• 🎮 Tổng số ván chơi
• 🏆 Số ván thắng
• 📊 Win rate (%)
• ⭐ Điểm trung bình
• 🔥 Streak hiện tại
• 📅 Ngày chơi gần nhất

**2. Theo từng game**

**Đoán Số:**
```
• Games played: 145
• Win rate: 82%
• Best score: 980
• Average turns: 5.2
• Fastest win: 3 turns
• Current streak: 12
```

**Bò & Bê:**
```
• Games played: 89
• Win rate: 67%
• Best score: 925
• Average turns: 6.8
• Fastest win: 4 turns
• Current streak: 5
```

**3. Theo độ khó**
• Easy: X ván (Y% win)
• Medium: X ván (Y% win)
• Hard: X ván (Y% win)

**4. Progress Timeline**
• Chart điểm theo thời gian
• Win/Loss history
• Performance trends
• Improvement rate

**5. Rankings**
• Global rank: #XX
• Country rank: #XX
• Friend rank: #XX
• Percentile: Top X%

**6. Achievements Progress**
• Đã unlock: X/Y
• Gần đạt: Danh sách
• Total achievement points

💡 **Export & Share:**
• Screenshot stats
• Share to social
• Compare with friends
• Set goals

🎯 **Recommendations:**
Dựa trên stats, AI sẽ suggest:
• Games cần cải thiện
• Achievements dễ đạt
• Optimal strategy
• Practice schedule''',
      ),
      ChatSuggestion(
        id: 'stats_achievements',
        title: '🏆 Huy hiệu',
        icon: '🎖️',
        fullResponse: '''🏆 **HỆ THỐNG HUY HIỆU (ACHIEVEMENTS)**

💎 **Các loại huy hiệu:**

---

🎯 **BEGINNER TIER**

**🌟 First Step**
• Hoàn thành ván đầu tiên
• Reward: 50 points

**🎮 Quick Learner**
• Chơi cả 2 games
• Reward: 100 points

**📚 Rule Master**
• Đọc hết luật chơi
• Reward: 75 points

---

🔥 **STREAK TIER**

**🔥 On Fire (5 Streak)**
• Win 5 ván liên tiếp
• Reward: 200 points

**⚡ Unstoppable (10 Streak)**
• Win 10 ván liên tiếp
• Reward: 500 points

**💫 Legendary (50 Streak)**
• Win 50 ván liên tiếp
• Reward: 2000 points
• Badge: 🌟 Legendary

---

⚡ **SPEED TIER**

**🚀 Speed Runner**
• Win < 5 turns (Đoán Số)
• Reward: 300 points

**⚡ Flash**
• Win < 3 turns (Đoán Số)
• Reward: 800 points

**🐆 Cheetah**
• Win < 5 turns (Bò & Bê)
• Reward: 400 points

---

🎮 **MASTERY TIER**

**👑 Easy Master**
• Win 50 games (Easy)
• Reward: 400 points

**🏅 Medium Master**
• Win 30 games (Medium)
• Reward: 600 points

**💎 Hard Master**
• Win 10 games (Hard)
• Reward: 1000 points
• Badge: 💎 Master

**🌟 Triple Master**
• Master all difficulties
• Reward: 3000 points
• Badge: 🌟 Grand Master

---

📊 **VOLUME TIER**

**🎯 Casual Player**
• Play 100 games
• Reward: 500 points

**🎮 Dedicated Gamer**
• Play 500 games
• Reward: 1500 points

**👑 Game Addict**
• Play 1000 games
• Reward: 3000 points
• Badge: 👑 Addiction

---

🏅 **SPECIAL TIER**

**🎨 Theme Collector**
• Try all themes
• Reward: 200 points

**💬 Chatty**
• 50 chats with Kajima AI
• Reward: 300 points

**📱 Feature Explorer**
• Use all app features
• Reward: 500 points

**🌍 Share Master**
• Share 10 times
• Reward: 400 points

---

💰 **POINT TIER**

**💎 5K Club**
• Reach 5000 total points
• Reward: Special badge

**💰 10K Elite**
• Reach 10000 total points
• Reward: Elite badge

**👑 100K Legend**
• Reach 100000 total points
• Reward: Legendary status

---

📊 **Progress Tracking:**

**Xem tiến độ:**
1. Vào **Achievements**
2. Xem % completion
3. Tap vào từng achievement
4. Xem requirements chi tiết

**Gần đạt:**
• Hệ thống highlight achievements gần đạt
• Show tips để hoàn thành
• Estimate time needed

💡 **Tips farming achievements:**
• Focus vào low-hanging fruits
• Chơi daily để maintain streak
• Complete challenges theo thứ tự
• Mix games để unlock đa dạng''',
      ),
      ChatSuggestion(
        id: 'stats_leaderboard',
        title: '🏆 Bảng xếp hạng',
        icon: '👑',
        fullResponse: '''🏆 **BẢNG XẾP HẠNG (LEADERBOARD)**

📊 **Hệ thống ranking:**

**🥇 Top 1 - CHAMPION**
• Crown badge: 👑
• Special theme unlock
• Hall of Fame
• Bragging rights

**🥈 Top 2-10 - ELITE**
• Gold badge: 🥇
• Premium features
• Elite status
• Name in spotlight

**🥉 Top 11-50 - MASTERS**
• Silver badge: 🥈
• Master tier rewards
• Recognition

**🏅 Top 51-100 - ADVANCED**
• Bronze badge: 🥉
• Advanced tier
• Good standing

**📊 Others - PLAYERS**
• Keep climbing!
• Everyone can reach top

---

🎯 **Cách tính điểm tổng:**

```python
Total Score = 
  (Game Scores × Win Rate) 
  + (Achievements × 100)
  + (Streak Bonus × 50)
  + (Difficulty Multiplier)
```

**Breakdown:**
• **Game Scores**: Tổng điểm các ván
• **Win Rate**: % thắng (bonus multiplier)
• **Achievements**: Mỗi huy hiệu = 100 pts
• **Streak**: Mỗi streak = 50 pts
• **Difficulty**: Easy x1, Medium x1.5, Hard x2

---

📈 **Leo rank strategies:**

**1. Volume Strategy (Dễ)**
• Chơi nhiều ván Easy mode
• Focus vào win rate
• Maintain streak
• → Phù hợp beginners

**2. Quality Strategy (Khó)**
• Chơi Hard mode
• Ít ván nhưng điểm cao
• Perfect games
• → Phù hợp experts

**3. Balanced Strategy (Tối ưu)**
• Mix cả 3 độ khó
• Unlock all achievements
• Daily consistency
• → Best long-term

**4. Achievement Rush**
• Focus farming achievements
• Mỗi achievement = +100
• Quick points boost
• → Fast ranking up

---

🔍 **Xem chi tiết top players:**

**Profile view:**
• Total games
• Win rate
• Best scores
• Achievements
• Streak records
• Favorite game
• Play style

**Learn from pros:**
• Study their stats
• Analyze strategies
• Compare with yours
• Set goals

---

📅 **Leaderboard types:**

**1. Global Leaderboard**
• All players worldwide
• Updated realtime
• Most competitive

**2. Country Leaderboard**
• Players from Vietnam
• Local competition
• National pride

**3. Friends Leaderboard**
• Compete with friends
• Most fun
• Friendly rivalry

**4. Weekly Leaderboard**
• Reset every week
• Fresh starts
• More chances to top

---

🎁 **Rewards by rank:**

**Champion (Top 1):**
• 5000 bonus points
• Exclusive crown badge
• Feature on homepage
• Special theme

**Elite (Top 10):**
• 2000 bonus points
• Gold badge
• Premium features
• Recognition

**Masters (Top 50):**
• 1000 bonus points
• Silver badge
• Master status

**Advanced (Top 100):**
• 500 bonus points
• Bronze badge
• Advanced tier

💡 **Pro tip:**
"Consistency > Bursts. Chơi đều 30 phút/ngày tốt hơn 5 giờ cuối tuần!"''',
      ),
    ];
  }

  /// Help suggestions
  static List<ChatSuggestion> _getHelpSuggestions() {
    return [
      ChatSuggestion(
        id: 'help_faq',
        title: '❓ FAQ',
        icon: '💭',
        fullResponse: '''❓ **FREQUENTLY ASKED QUESTIONS (FAQ)**

---

**Q1: App này làm được gì?** 🤔

A: Smart Student Tools là ứng dụng tổng hợp:
• 🎮 Mini games (Đoán Số, Bò & Bê)
• 🤖 AI chatbot consultant
• 🛠️ Công cụ học tập (Dịch, Báo thức, Video)
• 📊 Tracking & statistics
• 🏆 Achievement system

---

**Q2: Chatbot có cần internet không?** 🌐

A: **Không bắt buộc!**
• Online: Sử dụng Gemini AI API
• Offline: Intelligent Fallback System
• → Hoạt động mượt mà cả 2 trường hợp

---

**Q3: Làm sao tăng điểm nhanh?** 🚀

A: Top 3 strategies:
1. **Chơi Hard mode** → 2x points
2. **Maintain streak** → Bonus multiplier
3. **Farm achievements** → 100 pts/huy hiệu

---

**Q4: Tại sao tôi không leo rank?** 📈

A: Check:
• Win rate có > 60%?
• Có chơi đều hàng ngày?
• Đã unlock achievements chưa?
• Có maintain streak?

---

**Q5: Game nào dễ hơn?** 🎮

A: **Đoán Số** dễ hơn vì:
• Luật đơn giản
• Có algorithm rõ ràng (Binary Search)
• Ít RNG hơn

**Bò & Bê** khó hơn vì:
• Cần logic phức tạp
• Nhiều khả năng hơn
• Strategy phụ thuộc feedback

---

**Q6: Mất bao lâu để master games?** ⏱️

A: Thời gian trung bình:
• **Đoán Số Easy**: 2-3 ngày
• **Đoán Số Hard**: 1-2 tuần
• **Bò & Bê**: 2-3 tuần
• **Top 100**: 1-2 tháng
• **Top 10**: 3-6 tháng

---

**Q7: Achievements có expire không?** 🏆

A: **Không!** Achievements vĩnh viễn.
• Unlock 1 lần, giữ mãi
• Không có time limit
• Hoàn thành theo pace riêng

---

**Q8: Data có bị mất không?** 💾

A: **An toàn tuyệt đối!**
• Lưu local với Hive database
• Auto-save sau mỗi game
• Không cần đăng ký account
• Future: Cloud backup

---

**Q9: App có free 100%?** 💰

A: **Hoàn toàn FREE!**
• Không có ads
• Không có in-app purchase
• Không có paywall
• Open for all

---

**Q10: Làm sao report bug?** 🐛

A: Contact:
• Email: truonghieuhuy1401@gmail.com
• GitHub Issues
• In-app feedback (coming soon)

---

**Q11: Sẽ có thêm games?** 🎲

A: **Có!** Roadmap:
• Chess
• Sudoku
• Tic Tac Toe AI
• Card games
• → Vote game bạn muốn!

---

**Q12: Tại sao app tên "Smart Student Tools"?** 📱

A: Vì:
• Được thiết kế cho sinh viên
• Tools hỗ trợ học tập
• Games rèn luyện trí tuệ
• Practical & educational

---

💡 **Còn câu hỏi khác?**
Hỏi trực tiếp tôi hoặc xem docs chi tiết!''',
      ),
      ChatSuggestion(
        id: 'help_guide',
        title: '📖 Hướng dẫn sử dụng',
        icon: '📚',
        fullResponse: '''📖 **HƯỚNG DẪN SỬ DỤNG APP**

🚀 **Getting Started:**

**1. Khởi động lần đầu**
• Mở app
• Xem welcome screen
• Explore bottom navigation
• Try all features

**2. Bottom Navigation** (4 tabs)
```
🛠️ Công cụ → Tools menu
🎮 Giải trí → Games & chat
👤 Hồ sơ → Profile & group
⚙️ Cài đặt → Settings
```

---

🎮 **Chơi Games:**

**Bước 1: Vào Games Hub**
• Tap tab "Giải trí"
• Chọn "Trò chơi"

**Bước 2: Chọn game**
• 🎲 Đoán Số
• 🐮 Bò & Bê

**Bước 3: Chọn độ khó**
• Easy / Medium / Hard

**Bước 4: Chơi!**
• Nhập số → Submit
• Xem feedback
• Tiếp tục đoán

**Bước 5: Kết quả**
• Xem điểm
• Unlock achievements
• Save to leaderboard

---

💬 **Chat với Kajima AI:**

**Cách 1: Từ Profile**
• Vào Profile
• Tap nút "Kajima AI"

**Cách 2: Từ Công cụ**
• Tap "Công cụ"
• Chọn "Kajima AI"

**Cách 3: Direct**
• Navigate to Chatbot screen

**Trong chat:**
• ⚡ Quick Actions → Instant answers
• 💬 Type message → Smart response
• 📜 History → View past chats
• 🗑️ Clear → Reset conversation

---

🛠️ **Sử dụng Tools:**

**Dịch thuật:**
• Input text
• Select languages
• Translate
• Copy result

**Báo thức:**
• Set time
• Choose sound
• Set repeat
• Save alarm

**YouTube:**
• Paste URL
• Play video
• PiP mode
• Playlist

---

👤 **Quản lý Profile:**

**Edit profile:**
• Tap icon ✏️ góc phải
• Update info
• Save
• → Auto sync to group

**View group:**
• Tap "Nhóm"
• See members
• Edit member (nếu leader)
• Delete member

---

⚙️ **Settings:**

**Theme:**
• Toggle Light/Dark
• Or System default

**Notifications:**
• Enable/disable
• Choose types

**Language:**
• Tiếng Việt
• English (coming soon)

**About:**
• Version info
• Credits
• Contact

---

📊 **Xem Stats:**

**Leaderboard:**
• Tap "Leaderboard" in Games
• View rankings
• See top players
• Check your rank

**My Stats:**
• In Leaderboard
• Tap "My Stats"
• View dashboard
• Analyze performance

**Achievements:**
• Tap "Achievements"
• See progress
• Track unlock status
• Get tips

---

💡 **Tips tối ưu:**

**Performance:**
• Close unused tabs
• Clear cache định kỳ
• Update app thường xuyên

**Better experience:**
• Use Quick Actions
• Enable notifications
• Customize theme
• Explore all features

**Master games:**
• Read rules carefully
• Practice daily
• Learn from mistakes
• Watch top players

---

🆘 **Troubleshooting:**

**App lag:**
• Restart app
• Clear cache
• Check RAM

**Feature không hoạt động:**
• Update app
• Check permissions
• Restart device

**Data mất:**
• Kiểm tra Hive storage
• Restore from backup
• Contact support

💬 **Cần help thêm?**
Chat với tôi hoặc xem FAQ!''',
      ),
    ];
  }

  /// About suggestions
  static List<ChatSuggestion> _getAboutSuggestions() {
    return [
      ChatSuggestion(
        id: 'about_project',
        title: '📱 Về dự án',
        icon: 'ℹ️',
        fullResponse: '''📱 **VỀ DỰ ÁN SMART STUDENT TOOLS**

🎓 **Thông tin cơ bản:**

**Tên dự án:** Smart Student Tools
**Phiên bản:** 1.0.0
**Platform:** Android (Flutter)
**Ngôn ngữ:** Dart
**Framework:** Flutter 3.38.1

---

👨‍💻 **Tác giả:**

**Tên:** Trương Hiếu Huy
**MSSV:** 2280601273
**Lớp:** 22DTHA2
**Email:** truonghieuhuy1401@gmail.com
**Phone:** 0948677191

---

🎯 **Mục đích:**

Dự án được phát triển nhằm:

**1. Giáo dục** 📚
• Học tập Flutter framework
• Thực hành Mobile Development
• Áp dụng kiến thức lý thuyết
• Portfolio project

**2. Giải trí** 🎮
• Tạo mini games trí tuệ
• Rèn luyện tư duy logic
• Competitive gaming
• Social features

**3. Tiện ích** 🛠️
• Tools hỗ trợ học tập
• Productivity features
• Daily use applications
• All-in-one solution

---

💻 **Technology Stack:**

**Frontend:**
• Flutter 3.38.1
• Dart 3.10.0
• Material Design 3
• Responsive UI

**State Management:**
• Provider pattern
• ChangeNotifier
• Reactive programming

**Database:**
• Hive (NoSQL)
• Local storage
• Fast & lightweight

**AI:**
• Gemini AI API
• Intelligent Fallback
• NLP processing

**Native Integration:**
• Kotlin MethodChannel
• Android APIs
• Platform-specific features

**Architecture:**
• MVVM pattern
• Service layer
• Clean code principles
• Modular design

---

🎨 **Features:**

**Core Features:**
✅ Mini Games (Đoán Số, Bò & Bê)
✅ Leaderboard & Rankings
✅ Achievement System
✅ Statistics & Analytics
✅ AI Chatbot (Kajima AI)
✅ Profile Management
✅ Theme Switching
✅ Translator Tool
✅ Alarm System
✅ YouTube Integration

**Advanced Features:**
✅ Offline support
✅ Auto-save progress
✅ Real-time sync
✅ Smart suggestions
✅ Context-aware AI
✅ Smooth animations
✅ Responsive layout

---

📊 **Statistics:**

**Code:**
• **Lines of Code:** ~15,000+
• **Files:** 100+
• **Screens:** 15+
• **Widgets:** 50+
• **Services:** 10+

**Features:**
• **Games:** 2
• **Tools:** 4
• **Achievements:** 30+
• **Themes:** 2

---

🚀 **Roadmap:**

**Version 1.1.0** (Q1 2026)
• [ ] More games
• [ ] Cloud sync
• [ ] User authentication
• [ ] Social features

**Version 1.2.0** (Q2 2026)
• [ ] Multiplayer mode
• [ ] Voice chat
• [ ] Custom themes
• [ ] Widget support

**Version 2.0.0** (Q3 2026)
• [ ] iOS support
• [ ] Web version
• [ ] Desktop apps
• [ ] Cross-platform sync

---

🏆 **Achievements:**

✅ Complete Flutter app
✅ Material Design 3
✅ AI integration
✅ Offline-first approach
✅ Clean architecture
✅ Smooth UX
✅ Comprehensive features
✅ Production-ready

---

📝 **License:**

MIT License - Free to use

---

🙏 **Credits:**

**Libraries:**
• Flutter Team
• Provider package
• Hive database
• Dio HTTP client
• Google Gemini AI

**Inspiration:**
• Material Design
• Modern UI trends
• Popular games
• Student needs

---

💌 **Contact:**

**Bug reports:**
truonghieuhuy1401@gmail.com

**Feature requests:**
GitHub Issues

**Social:**
• GitHub: @TruongHieuHuy
• Email: truonghieuhuy1401@gmail.com

---

⭐ **Support the project:**

• ⭐ Star on GitHub
• 🐛 Report bugs
• 💡 Suggest features
• 📢 Share with friends
• 📝 Write reviews

---

🎉 **Thank you for using Smart Student Tools!**

Made with ❤️ by Trương Hiếu Huy
© 2025 All Rights Reserved''',
      ),
      ChatSuggestion(
        id: 'about_tech',
        title: '💻 Công nghệ',
        icon: '⚙️',
        fullResponse: '''💻 **CÔNG NGHỆ & KIẾN TRÚC**

🏗️ **Architecture Overview:**

```
┌─────────────────────────────────┐
│         UI Layer                │
│  (Screens, Widgets, Themes)     │
└──────────┬──────────────────────┘
           │
┌──────────▼──────────────────────┐
│      Provider Layer             │
│  (State Management, Business)   │
└──────────┬──────────────────────┘
           │
┌──────────▼──────────────────────┐
│      Service Layer              │
│  (API, Database, Utils)         │
└──────────┬──────────────────────┘
           │
┌──────────▼──────────────────────┐
│       Data Layer                │
│  (Models, Repositories)         │
└─────────────────────────────────┘
```

---

📦 **Core Technologies:**

**1. Flutter Framework**
```yaml
Flutter SDK: 3.38.1
Dart: 3.10.0
Channel: Stable
```

**Benefits:**
• Hot reload → Fast development
• Native performance
• Beautiful UI
• Cross-platform ready

**2. State Management - Provider**
```dart
Provider 6.1.1
ChangeNotifier pattern
Reactive updates
Scoped dependencies
```

**Why Provider?**
• Simple & lightweight
• Official recommendation
• Easy to learn
• Efficient rebuilds

**3. Local Database - Hive**
```dart
Hive: 2.2.3
hive_flutter: 1.1.0
Type-safe
NoSQL approach
```

**Advantages:**
• Lightning fast
• No native dependencies
• Encrypted support
• Lazy loading

---

🤖 **AI Integration:**

**Primary: Gemini AI API**
```dart
Model: gemini-1.5-flash
API: REST
Timeout: 30s
Retry: 1 attempt
```

**Features:**
• Natural language understanding
• Context-aware responses
• Multi-turn conversations
• Markdown support

**Fallback: Intelligent System**
```dart
Offline-first
Pattern matching
Intent detection
Rich responses
```

**Flow:**
```
User Query
    ↓
Try Gemini API
    ↓
Success? → Return response
    ↓ No
Intelligent Fallback
    ↓
Pattern match → Response
```

---

🎨 **UI/UX Stack:**

**Material Design 3**
• Dynamic colors
• M3 components
• Adaptive layouts
• Modern aesthetics

**Custom Widgets**
• Reusable components
• Themed consistently
• Animated transitions
• Responsive design

**Themes**
```dart
Light Theme:
  - Primary: Blue
  - Background: White
  - Card: Light gray

Dark Theme:
  - Primary: Blue accent
  - Background: Dark
  - Card: Dark gray
```

---

🔧 **Key Packages:**

```yaml
# Core
flutter: 3.38.1
provider: ^6.1.1
hive: ^2.2.3
hive_flutter: ^1.1.0

# Network
dio: ^5.4.0

# UI
cached_network_image: ^3.3.1
flutter_markdown: ^0.7.3+1

# Utils
intl: ^0.19.0
path: ^1.9.0

# Native
flutter_tts: ^4.1.0
speech_to_text: ^7.0.0
```

---

🏛️ **Project Structure:**

```
lib/
├── main.dart
├── config/
│   ├── api_config.dart
│   ├── navigation_config.dart
│   └── theme_config.dart
├── models/
│   ├── chatbot_message_model.dart
│   ├── game_data_model.dart
│   └── navigation_models.dart
├── screens/
│   ├── chatbot_screen.dart
│   ├── games/
│   ├── profile_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── chatbot/
│   ├── games/
│   └── common/
├── providers/
│   ├── chatbot_provider.dart
│   ├── game_provider.dart
│   └── theme_provider.dart
├── utils/
│   ├── gemini_api_service.dart
│   ├── database_service.dart
│   ├── intelligent_fallback.dart
│   └── user_data_service.dart
└── assets/
    ├── images/
    └── sounds/
```

---

🔐 **Security & Privacy:**

**Data Storage:**
• Local-only (Hive)
• No cloud by default
• Encrypted option
• User-controlled

**API Keys:**
• Server-side only (future)
• Rate limiting
• Timeout protection
• Error handling

**Permissions:**
```xml
- Internet (API calls)
- Phone (Emergency call)
- Storage (Cache)
- Microphone (Coming soon)
```

---

⚡ **Performance Optimizations:**

**1. Lazy Loading**
• Load data on demand
• Pagination for lists
• Image caching
• Efficient queries

**2. State Management**
• Selective rebuilds
• Provider scoping
• Optimized notifiers
• Minimal overhead

**3. Rendering**
• Widget reuse
• Const constructors
• Efficient layouts
• GPU optimization

**4. Database**
• Indexed queries
• Batch operations
• Lazy boxes
• Compaction

---

🧪 **Testing Strategy:**

**Unit Tests**
• Service layer
• Business logic
• Utils functions
• Data models

**Widget Tests**
• UI components
• User interactions
• State changes
• Navigation

**Integration Tests**
• E2E flows
• API calls
• Database ops
• Full features

---

🚀 **Build & Deploy:**

**Debug Build:**
```bash
flutter run --debug
Hot reload enabled
DevTools available
```

**Release Build:**
```bash
flutter build apk --release
Optimized & minified
ProGuard enabled
Size optimized
```

**App Size:**
• Debug: ~45 MB
• Release: ~18 MB

---

📈 **Scalability:**

**Current Capacity:**
• Users: Unlimited (local)
• Games: Infinite plays
• Data: Device storage
• Performance: Smooth

**Future Scale:**
• Cloud backend
• User accounts
• Sync across devices
• Multiplayer support

---

💡 **Best Practices:**

✅ Clean Code
✅ SOLID principles
✅ DRY (Don't Repeat)
✅ Separation of concerns
✅ Error handling
✅ Null safety
✅ Documentation
✅ Code reviews

---

🎓 **Learning Resources:**

**Flutter:**
• flutter.dev
• Flutter docs
• YouTube tutorials
• Flutter community

**Dart:**
• dart.dev
• Effective Dart
• Style guide
• Language tour

**Material Design:**
• material.io
• M3 guidelines
• Component library
• Design tokens

---

🔧 **Development Tools:**

• **IDE:** VS Code / Android Studio
• **Version Control:** Git
• **CI/CD:** GitHub Actions
• **Testing:** Flutter Test
• **Debugging:** DevTools
• **Profiling:** Observatory

---

💪 **Why This Stack?**

**Flutter:** Cross-platform, fast, beautiful
**Provider:** Simple, official, efficient
**Hive:** Fast, offline, easy
**Gemini:** Powerful AI, good API
**Material 3:** Modern, adaptive, consistent

= **Perfect combination for student project!** 🎉''',
      ),
    ];
  }

  /// Get quick suggestions (most common questions)
  static List<String> getQuickSuggestions() {
    return [
      '🎮 Chức năng hệ thống',
      '🎲 Hướng dẫn Game',
      '📊 Thống kê & Thành tích',
      '❓ Trợ giúp',
      '📱 Về Project',
    ];
  }
}
