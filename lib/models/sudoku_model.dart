import 'dart:convert';
class SudokuGame {
  final String gameId;           // Cần ID để gọi API
  final List<int> puzzle;        // Đề bài (81 số, 0 = ô trống)
  final List<int> solution;      // Đáp án đúng
  final String difficulty;       // 'EASY', 'MEDIUM', 'HARD'
  final List<int> currentState;  // Trạng thái hiện tại
  final int hintsUsed;           // Thêm để hết lỗi ở SudokuControls
  final bool isCompletedStatus;  // Tránh trùng tên với hàm isCompleted()
  final int? score;
  final int? timeTaken;

  SudokuGame({
    required this.gameId ,
    required this.puzzle,
    required this.solution,
    required this.difficulty,
    List<int>? currentState,
    this.hintsUsed = 0,
    this.isCompletedStatus = false,
    this.score,
    this.timeTaken,
  }) : currentState = currentState ?? List<int>.from(puzzle);

  // Mapping từ JSON nhận từ Backend (Rất quan trọng)
  factory SudokuGame.fromJson(Map<String, dynamic> json) {
    return SudokuGame(
      gameId: json['gameId'] ?? json['id'] ?? '',
      puzzle: json['puzzle'] is String 
          ? List<int>.from(jsonDecode(json['puzzle'])) 
          : List<int>.from(json['puzzle']),
      solution: json['solution'] is String 
          ? List<int>.from(jsonDecode(json['solution'])) 
          : List<int>.from(json['solution']),
      currentState: json['currentState'] is String 
          ? List<int>.from(jsonDecode(json['currentState'])) 
          : List<int>.from(json['currentState']),
      difficulty: json['difficulty'] ?? 'EASY',
      hintsUsed: json['hintsUsed'] ?? 0,
      isCompletedStatus: json['isCompleted'] ?? false,
      score: json['score'],
      timeTaken: json['timeTaken'],
    );
  }

  SudokuGame copyWith({
    String? gameId,
    List<int>? puzzle,
    List<int>? solution,
    String? difficulty,
    List<int>? currentState,
    int? hintsUsed,
    bool? isCompletedStatus,
    int? score,
    int? timeTaken,
  }) {
    return SudokuGame(
      gameId: gameId ?? this.gameId,
      puzzle: puzzle ?? this.puzzle,
      solution: solution ?? this.solution,
      difficulty: difficulty ?? this.difficulty,
      currentState: currentState ?? this.currentState,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      isCompletedStatus: isCompletedStatus ?? this.isCompletedStatus,
      score: score ?? this.score,
      timeTaken: timeTaken ?? this.timeTaken,
    );
  }

  // --- Các hàm Logic giữ nguyên ---
  bool isInitialCell(int row, int col) {
    final index = row * 9 + col;
    return puzzle[index] != 0;
  }

  bool isCompleted() {
    for (int i = 0; i < 81; i++) {
      if (currentState[i] != solution[i]) return false;
    }
    return true;
  }

  int getFilledCount() {
    return currentState.where((val) => val != 0).length;
  }

  bool hasMistake(int row, int col) {
    final index = row * 9 + col;
    if (currentState[index] == 0) return false;
    return currentState[index] != solution[index];
  }

  int getTotalMistakes() {
    int count = 0;
    for (int i = 0; i < 81; i++) {
      if (currentState[i] != 0 && currentState[i] != solution[i]) {
        count++;
      }
    }
    return count;
  }
}