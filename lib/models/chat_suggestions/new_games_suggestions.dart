import 'base_model.dart';

/// New games suggestions (Caro, Sudoku, Puzzle, Rubik)
class NewGamesSuggestions {
  static List<ChatSuggestion> getAll() {
    return [
      _caroRules(),
      _sudokuRules(),
      _puzzleRules(),
      _rubikRules(),
    ];
  }

  static ChatSuggestion _caroRules() {
    return ChatSuggestion(
      id: 'game_caro_rules',
      title: '📖 Luật Caro',
      icon: '⭕',
      fullResponse: '''⭕❌ **LUẬT CHƠI CARO (TIC-TAC-TOE 15x15)**

📋 **Mục tiêu:** Tạo 5 quân liên tiếp

🎯 **Cách chơi:**
• Bàn cờ 15x15
• X vs O (Player vs AI/Player)
• 5 liên tiếp (→, ↓, ↗, ↘) = Thắng!

📊 **2 Chế độ:**
**🎮 PvP:** Chơi với bạn, điểm: 1500
**🤖 PvE:** Đấu AI (Easy/Medium/Hard)

🤖 **AI Levels:**
🟢 Easy: Random + basic block (1000 pts)
🟡 Medium: Minimax depth 2 (2000 pts)
🔴 Hard: Minimax depth 4 (4000 pts)

💡 **Chiến thuật:**
1. **Opening:** Kiểm soát TÂM (H8)
2. **Fork:** Tạo 2 hàng 3 đồng thời
3. **Defense:** BLOCK hàng 3 ngay
4. **Pattern:** Nhận biết tất thắng
5. **Think Head:** Nghĩ 2-3 nước trước

🏆 **Scoring:**
Base + Time Bonus - Move Penalty''',
    );
  }

  static ChatSuggestion _sudokuRules() {
    return ChatSuggestion(
      id: 'game_sudoku_rules',
      title: '📖 Luật Sudoku',
      icon: '🔢',
      fullResponse: '''🔢 **LUẬT CHƠI SUDOKU**

📋 **Mục tiêu:** Điền 1-9 vào lưới 9x9

📐 **3 Luật:**
1. **Hàng:** 1-9 không trùng
2. **Cột:** 1-9 không trùng  
3. **Ô 3x3:** 1-9 không trùng

📊 **Độ khó:**
🟢 Easy: 40-45 số cho (1000 pts)
🟡 Medium: 30-35 số cho (2000 pts)
🔴 Hard: 25-30 số cho (3000 pts)

🎮 **Features:**
• Pencil marks (ghi chú)
• Hint system (3 lần)
• Auto-check errors
• Undo/Redo

💡 **Techniques:**
**Lvl 1:** Naked Singles (ô 1 số duy nhất)
**Lvl 2:** Hidden Singles (số 1 vị trí)
**Lvl 3:** Elimination (loại trừ)
**Lvl 4:** Pencil marks strategy
**Lvl 5:** Pairs/Triples

🏆 **Scoring:**
Base - Hints×50 + Time - Mistakes×20''',
    );
  }

  static ChatSuggestion _puzzleRules() {
    return ChatSuggestion(
      id: 'game_puzzle_rules',
      title: '📖 Luật Puzzle',
      icon: '🧩',
      fullResponse: '''🧩 **LUẬT CHƠI PUZZLE (SLIDING)**

📋 **Mục tiêu:** Sắp xếp lại ảnh

🎯 **Mechanics:**
• Ảnh cắt NxN mảnh
• 1 ô trống để trượt
• Click tile kề ô trống
• Sắp xếp đúng vị trí

📊 **Grid Sizes:**
🟢 3x3: 8 tiles + 1 empty (easy)
🟡 4x4: 15 tiles + 1 empty (medium)
🔴 5x5: 24 tiles + 1 empty (hard)

📊 **Shuffle Difficulty:**
🟢 Easy: 20 moves
🟡 Medium: 50 moves
🔴 Hard: 100 moves

💡 **Strategy (Layer by Layer):**
**Step 1:** Top row (khóa hàng 1)
**Step 2:** Left column (khóa cột 1)
**Step 3:** Solve 2x2 còn lại

🔹 **Corner Algorithm:**
→ ↓ ← ↑ (repeat pattern)

⚠️ **Avoid:**
• Phá layer đã solve
• Random moves
• Stuck in loop

🏆 **Scoring:**
Base + Time Bonus - Move Penalty''',
    );
  }

  static ChatSuggestion _rubikRules() {
    return ChatSuggestion(
      id: 'game_rubik_rules',
      title: '📖 Luật Rubik Cube',
      icon: '🎲',
      fullResponse: '''🎲 **LUẬT CHƠI RUBIK CUBE**

📋 **Mục tiêu:** Mỗi mặt cùng màu

🎯 **Structure:**
**6 Mặt:**
F (Front), B (Back), L (Left)
R (Right), U (Up), D (Down)

**Sizes:** 2x2, 3x3, 4x4

🔄 **Notation:**
• F: Front 90° CW
• F': Front 90° CCW  
• F2: Front 180°

📊 **Levels:**
🟢 2x2: Đơn giản (1000 pts)
🟡 3x3: Classic (2000 pts)
🔴 4x4: Advanced (4000 pts)

💡 **Beginner Method (Layer by Layer):**
**Step 1:** White Cross (bottom)
**Step 2:** White Corners
**Step 3:** Middle Layer Edges
**Step 4:** Yellow Cross (top)
**Step 5:** Orient Corners
**Step 6:** Final Permute

🎓 **Learning Path:**
Week 1-2: Notation + moves
Week 3-4: White layer
Week 5-6: Full solve
Week 7+: Speed up!

⚠️ **Mistakes:**
• Phá layer đã solve
• Sai notation (R ≠ R')
• Rush cubing
• Không hiểu logic

🏆 **Milestones:**
First solve: ~30-60 min
Practice: ~5-10 min
Intermediate: ~2-3 min
Advanced: <1 min
Speedcuber: <15s!

💎 **Fun Fact:**
• 43 quintillion combinations!
• God's Number = 20 moves
• World record <4 seconds!''',
    );
  }
}
