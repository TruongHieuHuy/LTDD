import 'dart:math';
import 'sudoku_solver.dart';
import '../../../models/sudoku_model.dart';

class SudokuGenerator {
  static final _random = Random();

  /// Tạo Sudoku game mới
/// Tạo Sudoku game mới
  static SudokuGame generate(String difficulty) {
    final solution = _generateFullBoard();
    final puzzle = _createPuzzle(solution, difficulty);
    
    return SudokuGame(
      gameId: DateTime.now().millisecondsSinceEpoch.toString(), 
      puzzle: puzzle,
      solution: solution,
      difficulty: difficulty,
      hintsUsed: 0, 
    );
  }


  /// Tạo board đầy đủ
  static List<int> _generateFullBoard() {
    final board = List.generate(9, (_) => List<int>.filled(9, 0));
    
    // Điền số ngẫu nhiên vào 3 ô chéo chính (để tăng tốc)
    _fillDiagonal(board);
    
    // Giải phần còn lại
    SudokuSolver.solve(board);
    
    return SudokuSolver.to1D(board);
  }

  /// Điền 3 ô 3x3 trên đường chéo
  static void _fillDiagonal(List<List<int>> board) {
    for (int box = 0; box < 9; box += 3) {
      _fillBox(board, box, box);
    }
  }

  /// Điền một ô 3x3
  static void _fillBox(List<List<int>> board, int row, int col) {
    final nums = List.generate(9, (i) => i + 1)..shuffle(_random);
    
    int idx = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        board[row + i][col + j] = nums[idx++];
      }
    }
  }

  /// Tạo đề bài bằng cách xóa số
  static List<int> _createPuzzle(List<int> solution, String difficulty) {
    final cellsToRemove = _getCellsToRemove(difficulty);
    final puzzle = List<int>.from(solution);
    
    final indices = List.generate(81, (i) => i)..shuffle(_random);
    int removed = 0;
    
    for (final index in indices) {
      if (removed >= cellsToRemove) break;
      
      final backup = puzzle[index];
      puzzle[index] = 0;
      
      // Đơn giản hóa: không check unique solution (để tăng tốc)
      removed++;
    }
    
    return puzzle;
  }

  /// Số ô cần xóa theo độ khó
  static int _getCellsToRemove(String difficulty) {
    switch (difficulty) {
      case 'EASY':
        return 35;  // Giữ 46 số
      case 'MEDIUM':
        return 45;  // Giữ 36 số
      case 'HARD':
        return 55;  // Giữ 26 số
      default:
        return 40;
    }
  }

  
/// Tính điểm dựa trên độ khó và thời gian
static int calculateScore({
  required String difficulty,
  required int timeInSeconds,
  required int hintsUsed,
  required int mistakes,
}) {
  // Điểm cơ bản cao hơn
  final baseScore = {
    'EASY': 1000,     // ← Tăng lên 10x
    'MEDIUM': 3000,
    'HARD': 5000,
  }[difficulty] ?? 1000;

  // Thời gian mục tiêu (giây) - càng khó càng nhiều thời gian
  final targetTime = {
    'EASY': 300,      // 5 phút
    'MEDIUM': 600,    // 10 phút
    'HARD': 900,      // 15 phút
  }[difficulty] ?? 300;

  // Bonus thời gian: Nếu nhanh hơn target → +điểm, chậm hơn → -điểm
  // Tối đa bonus = baseScore * 0.5
  final timeDiff = targetTime - timeInSeconds;
  final timeBonus = (timeDiff * 2).clamp(-(baseScore ~/ 2), baseScore ~/ 2);

  // Phạt hints (mỗi hint -100 điểm)
  final hintPenalty = hintsUsed * 100;

  // Phạt mistakes (mỗi lỗi -50 điểm)
  final mistakePenalty = mistakes * 50;

  // Tính điểm cuối (không âm)
  final finalScore = (baseScore + timeBonus - hintPenalty - mistakePenalty)
      .clamp(0, 99999);

  return finalScore;
}
}