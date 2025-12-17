/// Math Problem Model
/// Bài toán toán học với 4 đáp án
class MathProblem {
  final int num1;
  final int num2;
  final String operator;
  final int correctAnswer;
  final List<int> answers; // 4 đáp án (1 đúng, 3 sai)
  final int timeLimit; // Thời gian giới hạn (ms)

  MathProblem({
    required this.num1,
    required this.num2,
    required this.operator,
    required this.correctAnswer,
    required this.answers,
    required this.timeLimit,
  });

  /// Get display text for problem
  String get displayText => '$num1 $operator $num2 = ?';

  /// Check if answer is correct
  bool checkAnswer(int answer) => answer == correctAnswer;
}

/// Difficulty Scaler
/// Tự động điều chỉnh độ khó dựa trên level
class DifficultyScaler {
  static const int _baseTimeLimit = 5000; // 5s base time

  /// Get operators for level
  static List<String> getOperators(int level) {
    if (level <= 5) return ['+'];
    if (level <= 10) return ['+', '-'];
    if (level <= 15) return ['+', '-', '×'];
    return ['+', '-', '×', '÷'];
  }

  /// Get number range for level
  static NumberRange getRange(int level) {
    if (level <= 3) return NumberRange(min: 1, max: 10);
    if (level <= 6) return NumberRange(min: 1, max: 20);
    if (level <= 10) return NumberRange(min: 5, max: 30);
    if (level <= 15) return NumberRange(min: 10, max: 50);
    return NumberRange(min: 20, max: 100);
  }

  /// Get time limit (ms) for level
  static int getTimeLimit(int level) {
    if (level <= 5) return 5000; // 5s
    if (level <= 10) return 4000; // 4s
    if (level <= 15) return 3500; // 3.5s
    return 3000; // 3s
  }

  /// Get points for correct answer
  static int getPoints(int level) {
    return 10 + (level * 2);
  }
}

/// Number Range
class NumberRange {
  final int min;
  final int max;

  NumberRange({required this.min, required this.max});
}
