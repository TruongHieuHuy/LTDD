// lib/utils/game_context_service.dart
import '../models/game_score_model.dart';
import '../models/achievement_model.dart';
import '../providers/game_provider.dart';

/// Service để format game data thành context cho AI
class GameContextService {
  /// Build complete game context for AI prompt
  static String buildGameContext(GameProvider gameProvider) {
    final buffer = StringBuffer();

    // Player info
    buffer.writeln('[USER CONTEXT]');
    buffer.writeln('Player: ${gameProvider.playerName}');
    buffer.writeln('Total games played: ${gameProvider.totalGamesPlayed}');
    buffer.writeln();

    // Guess Number stats
    final guessNumberStats = _getGameTypeStats(
      gameProvider.scores,
      'guess_number',
    );
    if (guessNumberStats.isNotEmpty) {
      buffer.writeln('Đoán Số:');
      buffer.writeln('- Games played: ${guessNumberStats['count']}');
      buffer.writeln(
        '- Average attempts: ${guessNumberStats['avg'].toStringAsFixed(1)}',
      );
      buffer.writeln('- Best score: ${guessNumberStats['best']} attempts');
      buffer.writeln('- Win rate: ${guessNumberStats['winRate']}%');
      buffer.writeln();
    }

    // Cows & Bulls stats
    final cowsBullsStats = _getGameTypeStats(gameProvider.scores, 'cows_bulls');
    if (cowsBullsStats.isNotEmpty) {
      buffer.writeln('Bò & Bê:');
      buffer.writeln('- Games played: ${cowsBullsStats['count']}');
      buffer.writeln(
        '- Average attempts: ${cowsBullsStats['avg'].toStringAsFixed(1)}',
      );
      buffer.writeln('- Best score: ${cowsBullsStats['best']} attempts');
      buffer.writeln('- Win rate: ${cowsBullsStats['winRate']}%');
      buffer.writeln();
    }

    // Memory Match stats
    final memoryMatchStats = _getGameTypeStats(
      gameProvider.scores,
      'memory_match',
    );
    if (memoryMatchStats.isNotEmpty) {
      buffer.writeln('Memory Match (Lật Thẻ):');
      buffer.writeln('- Games played: ${memoryMatchStats['count']}');
      buffer.writeln('- Best score: ${memoryMatchStats['best']} points');
      buffer.writeln(
        '- Average score: ${memoryMatchStats['avg'].toStringAsFixed(0)} points',
      );
      buffer.writeln();
    }

    // Quick Math stats
    final quickMathStats = _getGameTypeStats(gameProvider.scores, 'quick_math');
    if (quickMathStats.isNotEmpty) {
      buffer.writeln('Quick Math (Toán Nhanh):');
      buffer.writeln('- Games played: ${quickMathStats['count']}');
      buffer.writeln('- Highest level: ${quickMathStats['best']}');
      buffer.writeln(
        '- Average level: ${quickMathStats['avg'].toStringAsFixed(1)}',
      );
      buffer.writeln();
    }

    // Achievements
    final unlockedAchievements = gameProvider.unlockedAchievements;
    buffer.writeln(
      'Achievements unlocked: ${unlockedAchievements.length}/${gameProvider.achievements.length}',
    );
    if (unlockedAchievements.isNotEmpty) {
      for (var ach in unlockedAchievements.take(5)) {
        buffer.writeln('- "${ach.name}" (${ach.rarity}) ${ach.iconEmoji}');
      }
    }
    buffer.writeln();

    // Leaderboard position (mock - implement later with actual leaderboard)
    buffer.writeln('Leaderboard positions:');
    buffer.writeln('- Đoán Số: Top 20%');
    buffer.writeln('- Bò & Bê: Top 30%');
    buffer.writeln('- Memory Match: Top 25%');
    buffer.writeln('- Quick Math: Top 15%');

    return buffer.toString();
  }

  /// Get detailed stats for specific game type
  static Map<String, dynamic> _getGameTypeStats(
    List<GameScoreModel> allScores,
    String gameType,
  ) {
    final gameScores = allScores.where((s) => s.gameType == gameType).toList();

    if (gameScores.isEmpty) return {};

    final attempts = gameScores.map((s) => s.attempts).toList();
    final avgAttempts = attempts.reduce((a, b) => a + b) / attempts.length;
    final bestScore = attempts.reduce((a, b) => a < b ? a : b);

    // Calculate win rate (assuming all completed games are wins for now)
    final winRate = 100;

    return {
      'count': gameScores.length,
      'avg': avgAttempts,
      'best': bestScore,
      'winRate': winRate,
    };
  }

  /// Get detailed rules for a specific game
  static String getGameRules(String gameType) {
    switch (gameType.toLowerCase()) {
      case 'guess_number':
      case 'đoán số':
        return '''
🎲 GAME ĐOÁN SỐ - LUẬT CHƠI

📖 Mục tiêu:
Bot nghĩ ra 1 số bí mật, bạn phải đoán cho đúng trong số lần thử giới hạn.

🎯 3 Độ khó:
• Easy: Từ 1-50 (7 lần thử)
• Normal: Từ 1-100 (5 lần thử)  
• Hard: Từ 1-200 (3 lần thử)

🔍 Cơ chế chơi:
1. Chọn độ khó
2. Nhập số đoán
3. Bot phản hồi "Cao hơn" hoặc "Thấp hơn"
4. Tiếp tục đoán dựa trên feedback
5. Đoán đúng = THẮNG! 🎉

⏱️ Tính năng đặc biệt:
- Thinking timer: Bot sẽ troll nếu bạn suy nghĩ quá lâu
- Screen shake: Hiệu ứng rung khi sai nhiều
- Patience bar: Thanh kiên nhẫn với emoji
- Meme feedback: Phản hồi hài hước

💡 Chiến thuật:
- Binary search: Luôn đoán ở giữa khoảng
- Theo dõi min/max: Ghi nhớ phạm vi còn lại
- Tính nhanh: Chia đôi để tối ưu số lần thử
''';

      case 'cows_bulls':
      case 'bò bê':
      case 'bò & bê':
        return '''
🐮 GAME BÒ & BÊ (MASTERMIND) - LUẬT CHƠI

📖 Mục tiêu:
Tìm code bí mật gồm các số không trùng lặp.

🎯 2 Levels:
• Level 1: 6 digits (8 lần thử)
• Level 2: 12 digits (15 lần thử) - "Thách Thức Tuyệt Vọng"

🔍 Cơ chế chơi:
1. Chọn level
2. Nhập code đoán (các số khác nhau)
3. Bot phản hồi Bulls & Cows:
   • Bulls (🐂): Số đúng và đúng vị trí
   • Cows (🤡): Số đúng nhưng sai vị trí
4. Dùng logic để suy luận
5. Tìm đúng code = THẮNG! 🎉

⏱️ Tính năng đặc biệt:
- LED ticker: Hiệu ứng chữ chạy
- Fake ad popup: Quảng cáo troll (lần thứ 5)
- Thinking timer: Nhắc nhở nếu chậm
- Screen shake: Rung khi sai

💡 Chiến thuật:
- Initial guess: Đoán 012345... để test tất cả digits
- Elimination: Loại bỏ các số không xuất hiện
- Pattern matching: So sánh Bulls/Cows giữa các lần
- Lock digits: Confirm từng vị trí khi có Bulls
''';

      case 'memory_match':
      case 'lật thẻ':
      case 'lat the':
        return '''
🧩 GAME MEMORY MATCH (LẬT THẺ GHI NHỚ) - LUẬT CHƠI

📖 Mục tiêu:
Tìm tất cả các cặp thẻ giống nhau bằng cách ghi nhớ vị trí.

🎯 3 Độ khó:
• Easy: 4×4 (8 cặp) - Không giới hạn thời gian - 5s preview
• Normal: 4×5 (10 cặp) - 120 giây - 4s preview
• Hard: 5×6 (15 cặp) - 150 giây - 3s preview + Double Coding

🔍 Cơ chế chơi:
1. Preview Phase: Tất cả thẻ hiện trong 3-5 giây
2. Thẻ úp lại, bắt đầu game
3. Click 2 thẻ để lật:
   • Khớp → Giữ mở + cộng điểm + streak++
   • Không khớp → Đợi 0.5s → tự động úp
4. Tính năng Zero Dead Time: Click thẻ thứ 3 → úp 2 thẻ cũ ngay lập tức
5. Tìm hết tất cả cặp = THẮNG! 🎉

⏱️ Tính năng đặc biệt:
- 3D Flip Animation: Thẻ lật với hiệu ứng 3D
- Hint Power-up: Lật 1 thẻ trong 2s (3 lần, -50 điểm)
- Streak System: Combo tăng điểm liên tục
- Timer Bar: Đếm ngược với màu đỏ khi < 30s
- Double Coding (Hard): Phải nhớ cả hình + màu

💡 Chiến thuật:
- Preview time: Tập trung nhớ vị trí, bắt đầu từ góc
- Hệ thống hóa: Nhớ theo hàng ngang hoặc cột dọc
- Hint timing: Dùng khi còn 2-3 cặp khó
- Zero Dead Time: Click nhanh thẻ thứ 3 thay vì đợi
- Streak bonus: Giữ combo cao để tối đa điểm
''';

      case 'quick_math':
      case 'toán nhanh':
      case 'toan nhanh':
        return '''
⚡ GAME QUICK MATH (TOÁN NHANH) - LUẬT CHƠI

📖 Mục tiêu:
Giải phép toán nhanh nhất có thể, đạt level cao nhất.

🎯 Level Progression:
• Level 1-5: Chỉ cộng (+), số 1-10, 5 giây
• Level 6-10: Cộng + trừ, số 1-20, 4 giây
• Level 11-15: Cộng + trừ + nhân, số 5-30, 3.5 giây
• Level 16+: Tất cả phép tính (+,-,×,÷), số 20-100, 3 giây

🔍 Cơ chế chơi:
1. Chọn đáp án đúng từ 4 lựa chọn
2. Sai hoặc hết giờ → mất 1 HP (heart)
3. Hết 3 HP = Game Over
4. Trả lời đúng 5 câu → Level Up
5. Mỗi level độ khó tăng dần

⚡ 3 Power-ups (mỗi loại 2 lần):
• ⏸️ Time Freeze: Đóng băng timer 3 giây
• ⏭️ Skip: Bỏ qua câu hỏi không mất HP
• 50-50: Ẩn 2 đáp án sai

⏱️ Tính năng đặc biệt:
- HP System: 3 trái tim, visual rõ ràng
- Squash Animation: Button bóp khi nhấn
- Streak Bonus: ≥5 streak → +2 điểm mỗi câu
- Timer Bar: Progress bar, đỏ khi < 30%
- Clean Division: Phép chia luôn chia hết (không dư)

💡 Chiến thuật:
- Levels đầu: Tập làm quen, không vội
- Accuracy > Speed: Sai là mất HP, cẩn thận
- Time Freeze: Dùng cho nhân/chia khó
- Skip: Dùng khi còn 1 HP và câu quá khó
- 50-50: Tăng tỷ lệ đoán khi không chắc
- Streak focus: 5 câu liên tiếp → bonus lớn
''';

      default:
        return 'Game không tồn tại. Hiện có 4 games: Đoán Số, Bò & Bê, Memory Match, Quick Math.';
    }
  }

  /// Get strategic tips for a game
  static List<String> getGameTips(String gameType, [String? difficulty]) {
    switch (gameType.toLowerCase()) {
      case 'guess_number':
      case 'đoán số':
        if (difficulty?.toLowerCase() == 'easy') {
          return [
            '🎯 Với Easy (1-50), đoán đầu tiên: 25',
            '📊 Mỗi lần đoán, thu hẹp phạm vi một nửa',
            '⚡ 7 lần thử là quá đủ, đừng stress',
            '🧮 Luôn đoán ở giữa khoảng min-max hiện tại',
            '💪 Practice mode này để làm quen binary search',
          ];
        } else if (difficulty?.toLowerCase() == 'hard') {
          return [
            '🔥 Hard (1-200) chỉ có 3 lần → Áp lực cao!',
            '🎯 Đoán 1: Số 100 (giữa)',
            '🎯 Đoán 2: 50 hoặc 150 (tùy feedback)',
            '🎯 Đoán 3: Tính toán chính xác, không sai được',
            '🍀 Cần kỹ năng + may mắn, đừng vội',
            '⏱️ Tư duy nhanh, quyết đoán trong 10s',
          ];
        } else {
          return [
            '🎯 Luôn đoán ở giữa khoảng (binary search)',
            '📝 Ghi nhớ min/max sau mỗi feedback',
            '🧮 Tính nhanh: (min + max) / 2',
            '⚡ Đừng đoán random, luôn có logic',
            '💡 5 lần thử cho 1-100 là đủ nếu chơi đúng',
            '🧘 Giữ bình tĩnh, không vội vàng',
          ];
        }

      case 'cows_bulls':
      case 'bò bê':
      case 'bò & bê':
        if (difficulty?.toLowerCase() == '12digit') {
          return [
            '🔥 12 digits = Ultimate challenge!',
            '📝 BẮT BUỘC dùng giấy nháp để track',
            '🎯 Đoán 1: 012345678901 (cover 10 digits)',
            '📊 Phân tích Bulls/Cows để loại digit',
            '🔄 Hoán vị digits có Bulls cao',
            '⏰ Mỗi lần đoán không quá 30s',
            '🧠 Cần matrix: digits x positions',
            '💪 Chơi Level 1 thành thạo trước!',
          ];
        } else {
          return [
            '🎯 Đoán 1: 012345 hoặc 543210 (cover digits)',
            '📊 Ghi chép Bulls/Cows mỗi lần đoán',
            '🔍 Focus vào digits có Bulls trước',
            '🔄 Swap positions để test Cows',
            '❌ Loại bỏ digits không xuất hiện',
            '✅ Lock vị trí khi confirm Bulls',
            '🧮 Dùng logic, không đoán random',
          ];
        }

      case 'memory_match':
      case 'lật thẻ':
      case 'lat the':
        if (difficulty?.toLowerCase() == 'hard') {
          return [
            '🔥 Hard = 5×6 (15 cặp) + Double Coding!',
            '🎯 Preview: Tập trung nhớ shape + color',
            '🧠 Double Coding: Phải nhớ CẢ hình VÀ màu',
            '📝 Hệ thống: Nhớ theo cột hoặc màu',
            '⏱️ 150s thôi, quản lý thời gian tốt',
            '💡 Hint: Dùng sớm nếu bí, đừng để hết giờ',
            '🔄 Zero Dead Time: Click thẻ 3 nhanh',
          ];
        } else if (difficulty?.toLowerCase() == 'easy') {
          return [
            '✅ Easy = 4×4 (8 cặp), không giới hạn giờ',
            '🎯 Preview 5s: Ghi nhớ tất cả vị trí',
            '📍 Bắt đầu từ góc: Top-left → clockwise',
            '🧠 Nhớ theo hàng: Hàng 1, Hàng 2...',
            '💪 Mode luyện tập, không stress',
            '🔄 Thử nhiều strategy khác nhau',
          ];
        } else {
          return [
            '🎯 Preview time: Nhớ vị trí, bắt đầu từ góc',
            '📝 Hệ thống hóa: Nhớ theo hàng/cột',
            '⚡ Zero Dead Time: Click thẻ 3 → ẩn ngay',
            '🔥 Build streak: Match liên tục → bonus',
            '💡 Hint strategy: Dùng khi còn 2-3 cặp khó',
            '⏱️ Quản lý timer: Đừng panic khi < 30s',
          ];
        }

      case 'quick_math':
      case 'toán nhanh':
      case 'toan nhanh':
        return [
          '🎯 Level 1-5: Làm quen, không vội',
          '⚡ Accuracy > Speed: Sai = -1 HP',
          '⏸️ Time Freeze: Dùng cho nhân/chia khó',
          '⏭️ Skip: Save cho khi còn 1 HP',
          '🎲 50-50: Tăng tỷ lệ khi không chắc',
          '🔥 Streak ≥5: Bonus +2 điểm/câu',
          '🧮 Division: Luôn chia hết, không có số lẻ',
          '💪 Level 10+: Cần tính nhẩm nhanh',
        ];

      default:
        return ['Game không tồn tại'];
    }
  }

  /// Get achievement information
  static String getAchievementInfo(AchievementModel achievement) {
    return '''
🏅 ${achievement.name.toUpperCase()}

Rarity: ${_getRarityDisplay(achievement.rarity)}
Icon: ${achievement.iconEmoji}
Status: ${achievement.isUnlocked ? '✅ Đã unlock' : '🔒 Chưa unlock'}
${achievement.isUnlocked && achievement.unlockedAt != null ? 'Unlocked: ${_formatDate(achievement.unlockedAt!)}' : ''}

📋 Mô tả:
${achievement.description}

🎯 Điều kiện:
${achievement.condition}
''';
  }

  static String _getRarityDisplay(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return '⭐ Common';
      case 'rare':
        return '⭐⭐ Rare';
      case 'epic':
        return '⭐⭐⭐ Epic';
      case 'legendary':
        return '⭐⭐⭐⭐ Legendary';
      default:
        return rarity;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get next suggested achievements to unlock
  static List<AchievementModel> getNextAchievements(GameProvider gameProvider) {
    // Return locked achievements sorted by difficulty
    final locked = gameProvider.lockedAchievements;

    // Sort by rarity (common first)
    locked.sort((a, b) {
      const rarityOrder = {'common': 0, 'rare': 1, 'epic': 2, 'legendary': 3};
      return (rarityOrder[a.rarity.toLowerCase()] ?? 99).compareTo(
        rarityOrder[b.rarity.toLowerCase()] ?? 99,
      );
    });

    return locked.take(3).toList();
  }

  /// Build system prompt for Gemini AI
  static String buildSystemPrompt() {
    return '''
Bạn là Kajima AI - trợ lý game thông minh cho ứng dụng Smart Student Tools.

🎮 GAMES BẠN HỖ TRỢ (4 games):
1. Đoán Số: Game đoán số với 3 độ khó (Easy/Normal/Hard)
2. Bò và Bê: Mastermind game với 2 levels (6/12 digits)
3. Memory Match (Lật Thẻ): Game ghi nhớ với 3 độ khó
   - Easy: 4x4, không giới hạn giờ, 5s preview
   - Normal: 4x5, 120s, 4s preview
   - Hard: 5x6, 150s, 3s preview + Double Coding
   - Hint power-up: 3 lần, -50 điểm
   - Navigation: Giải trí → Trò chơi → Lật Thẻ (indigo card)
   
4. Quick Math (Toán Nhanh): Game toán arcade với level tăng dần
   - Level 1-20+ tự động tăng độ khó
   - HP System: 3 hearts, sai/timeout = -1 HP
   - 3 Power-ups: Time Freeze (3s), Skip, 50-50
   - Streak bonus: từ 5 câu đúng thì +2 điểm
   - Navigation: Giải trí → Trò chơi → Quick Math (purple card)

👤 VAI TRÒ:
- Giải thích luật chơi chi tiết, dễ hiểu
- Đưa ra tips và tricks thực tế, có chiến thuật
- Phân tích thống kê cá nhân của người chơi
- Hướng dẫn unlock achievements cụ thể
- So sánh với leaderboard, động viên
- Trả lời mọi câu hỏi về games

💬 PHONG CÁCH:
- Thân thiện, nhiệt tình, vui vẻ
- Dùng emoji phù hợp
- Hài hước nhưng hữu ích
- Format rõ ràng với bullets, numbers
- Ngắn gọn (200-300 words) nhưng đầy đủ
- Khuyến khích và động viên người chơi

🚫 KHÔNG:
- Không quá dài dòng
- Không dùng ngôn ngữ phức tạp
- Không chỉ lý thuyết, cần examples
- Không phán xét tiêu cực

✅ LUÔN:
- Dựa trên stats của user để cá nhân hóa
- Đưa ra lời khuyên thực tế
- Giải thích WHY, không chỉ WHAT
- Encourage và motivate
''';
  }

  /// Build complete prompt with game context
  static String buildCompletePrompt(
    String userMessage,
    GameProvider gameProvider,
  ) {
    final systemPrompt = buildSystemPrompt();
    final gameContext = buildGameContext(gameProvider);

    return '''
$systemPrompt

GAME RULES REFERENCE
Đoán Số:
- Easy: 1-50 (7 tries), Normal: 1-100 (5 tries), Hard: 1-200 (3 tries)
- Strategy: Binary search, đoán giữa khoảng

Bò và Bê:
- Level 1: 6 digits (8 tries), Level 2: 12 digits (15 tries)
- Bulls: Đúng số đúng vị trí, Cows: Đúng số sai vị trí
- Strategy: Elimination, pattern matching

Memory Match (Lật Thẻ):
- Easy: 4x4 (8 pairs), no time limit, 5s preview
- Normal: 4x5 (10 pairs), 120s, 4s preview
- Hard: 5x6 (15 pairs), 150s, 3s preview + Double Coding
- Strategy: Systematic memory, use hint wisely, Zero Dead Time

Quick Math (Toán Nhanh):
- Level 1-5: cộng only, 6-10: cộng trừ, 11-15: cộng trừ nhân, 16+: tất cả phép tính
- 3 HP system, lose 1 on wrong/timeout
- Power-ups: Time Freeze (3s), Skip, 50-50 (2 uses each)
- Strategy: Accuracy > speed, streak focus, save power-ups

$gameContext

USER QUESTION
$userMessage

YOUR RESPONSE
''';
  }
}
