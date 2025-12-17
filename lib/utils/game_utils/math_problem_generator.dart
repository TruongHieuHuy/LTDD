import 'dart:math';
import '../../models/math_problem_model.dart';

/// Math Problem Generator
/// Tạo bài toán toán học với độ khó tự động
class MathProblemGenerator {
  static final Random _random = Random();

  /// Generate problem for level
  static MathProblem generateProblem(int level) {
    final operators = DifficultyScaler.getOperators(level);
    final range = DifficultyScaler.getRange(level);
    final operator = operators[_random.nextInt(operators.length)];

    late int num1, num2, correctAnswer;

    switch (operator) {
      case '+':
        num1 = _randomInRange(range);
        num2 = _randomInRange(range);
        correctAnswer = num1 + num2;
        break;

      case '-':
        // Ensure positive result
        num1 = _randomInRange(NumberRange(min: range.min + 5, max: range.max));
        num2 = _randomInRange(NumberRange(min: range.min, max: num1));
        correctAnswer = num1 - num2;
        break;

      case '×':
        // Keep numbers smaller for multiplication
        final smallRange = NumberRange(
          min: range.min,
          max: (range.max / 2).floor().clamp(range.min + 1, 20),
        );
        num1 = _randomInRange(smallRange);
        num2 = _randomInRange(smallRange);
        correctAnswer = num1 * num2;
        break;

      case '÷':
        // Ensure clean division
        num2 = _randomInRange(NumberRange(min: 2, max: 12));
        correctAnswer = _randomInRange(
          NumberRange(min: range.min, max: (range.max / num2).floor()),
        );
        num1 = correctAnswer * num2;
        break;

      default:
        num1 = _randomInRange(range);
        num2 = _randomInRange(range);
        correctAnswer = num1 + num2;
    }

    // Generate 4 answers (1 correct + 3 distractors)
    final answers = _generateAnswers(correctAnswer, level);

    return MathProblem(
      num1: num1,
      num2: num2,
      operator: operator,
      correctAnswer: correctAnswer,
      answers: answers,
      timeLimit: DifficultyScaler.getTimeLimit(level),
    );
  }

  /// Generate 4 answers with distractors
  static List<int> _generateAnswers(int correctAnswer, int level) {
    final answers = <int>[correctAnswer];
    final used = <int>{correctAnswer};

    // Distractor range based on level
    int maxOffset = level <= 5
        ? 5
        : level <= 10
        ? 10
        : 20;

    while (answers.length < 4) {
      // Generate distractor
      final offset = _random.nextInt(maxOffset) + 1;
      final distractor = _random.nextBool()
          ? correctAnswer + offset
          : (correctAnswer - offset).clamp(0, 9999);

      if (!used.contains(distractor) && distractor >= 0) {
        answers.add(distractor);
        used.add(distractor);
      }
    }

    // Shuffle answers
    answers.shuffle(_random);
    return answers;
  }

  /// Get random number in range
  static int _randomInRange(NumberRange range) {
    return range.min + _random.nextInt(range.max - range.min + 1);
  }
}
