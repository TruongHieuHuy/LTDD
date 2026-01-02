import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/math_problem_model.dart';
import '../../utils/game_utils/math_problem_generator.dart';
import '../../widgets/game_widgets/math_answer_button.dart';
import '../../widgets/game_widgets/math_timer_bar.dart';
import '../../widgets/game_widgets/math_hp_display.dart';
import '../../widgets/game_widgets/math_power_up_bar.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

/// Quick Math Game Screen
/// Game giải toán nhanh với level tăng dần
class QuickMathGameScreen extends StatefulWidget {
  final String? challengeId;
  final int? challengeGameNumber;
  
  const QuickMathGameScreen({
    super.key,
    this.challengeId,
    this.challengeGameNumber,
  });

  @override
  State<QuickMathGameScreen> createState() => _QuickMathGameScreenState();
}

class _QuickMathGameScreenState extends State<QuickMathGameScreen> {
  // Game state
  int _level = 1;
  int _score = 0;
  int _currentHP = 3;
  final int _maxHP = 3;
  int _streak = 0;
  int _maxStreak = 0;
  int _questionsInLevel = 0;
  final int _questionsPerLevel = 5;

  // Current problem
  late MathProblem _currentProblem;
  int _timeRemaining = 0; // milliseconds
  Timer? _problemTimer;
  bool _isProcessing = false;
  bool _isTimeFrozen = false;

  // Power-ups
  int _timeFreezeRemaining = 2;
  int _skipRemaining = 2;
  int _fiftyFiftyRemaining = 2;
  Set<int> _hiddenAnswers = {};

  @override
  void initState() {
    super.initState();
    _startNewProblem();
  }

  @override
  void dispose() {
    _problemTimer?.cancel();
    super.dispose();
  }

  /// Start new problem
  void _startNewProblem() {
    _problemTimer?.cancel();

    setState(() {
      _currentProblem = MathProblemGenerator.generateProblem(_level);
      _timeRemaining = _currentProblem.timeLimit;
      _isProcessing = false;
      _isTimeFrozen = false;
      _hiddenAnswers.clear();
    });

    // Start timer
    _problemTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!_isTimeFrozen) {
        setState(() {
          _timeRemaining -= 100;
        });

        if (_timeRemaining <= 0) {
          timer.cancel();
          _onTimeout();
        }
      }
    });
  }

  /// Handle answer tap
  void _onAnswerTap(int answer) {
    if (_isProcessing) return;

    _problemTimer?.cancel();
    setState(() => _isProcessing = true);

    final isCorrect = _currentProblem.checkAnswer(answer);

    if (isCorrect) {
      _onCorrectAnswer();
    } else {
      _onWrongAnswer();
    }
  }

  /// Handle correct answer
  void _onCorrectAnswer() {
    HapticFeedback.lightImpact();

    setState(() {
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;

      final points = DifficultyScaler.getPoints(_level);
      final streakBonus = _streak >= 5 ? (_streak * 2) : 0;
      _score += points + streakBonus;

      _questionsInLevel++;

      // Level up every 5 questions
      if (_questionsInLevel >= _questionsPerLevel) {
        _level++;
        _questionsInLevel = 0;
        // Dừng game và hiện dialog level up
        _showLevelUpDialog();
        return; // Không tiếp tục, đợi người dùng nhấn OK
      }
    });

    // Next problem after short delay (chỉ khi không level up)
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted && _currentHP > 0) {
        _startNewProblem();
      }
    });
  }

  /// Handle wrong answer
  void _onWrongAnswer() {
    HapticFeedback.heavyImpact();

    setState(() {
      _streak = 0;
      _currentHP--;
    });

    if (_currentHP <= 0) {
      _onGameOver();
    } else {
      // Next problem after short delay
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _startNewProblem();
        }
      });
    }
  }

  /// Handle timeout
  void _onTimeout() {
    HapticFeedback.heavyImpact();

    setState(() {
      _streak = 0;
      _currentHP--;
    });

    if (_currentHP <= 0) {
      _onGameOver();
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _startNewProblem();
        }
      });
    }
  }

  /// Show level up dialog
  void _showLevelUpDialog() {
    // Dừng timer hiện tại
    _problemTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('⬆️ Level Up!'),
            Spacer(),
            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LEVEL $_level',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Độ khó tăng lên!'),
            Text('Streak: $_streak 🔥'),
            Text('Score: $_score 💎'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Bắt đầu câu hỏi mới sau khi người dùng nhấn OK
              Future.delayed(Duration(milliseconds: 300), () {
                if (mounted && _currentHP > 0) {
                  _startNewProblem();
                }
              });
            },
            child: Text(
              'OK - Bắt đầu!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle game over
  void _onGameOver() async {
    _problemTimer?.cancel();
    
    // Save to backend if logged in
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn) {
      try {
        await ApiService().saveScore(
          gameType: 'quick_math',
          score: _score,
          difficulty: _level < 5 ? 'easy' : _level < 10 ? 'medium' : 'hard',
          attempts: (_level - 1) * _questionsPerLevel + _questionsInLevel,
          timeSpent: 0, // Quick math doesn't track total time
        );
      } catch (e) {
        debugPrint('Failed to save score to backend: $e');
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('💀 Game Over'),
            Spacer(),
            Icon(Icons.cancel, color: Colors.red, size: 32),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Level', '$_level'),
            _buildStatRow('Điểm', '$_score 💎'),
            _buildStatRow('Streak tối đa', '$_maxStreak 🔥'),
            Divider(),
            Text(
              'Bạn đã trả lời sai quá nhiều!',
              style: TextStyle(color: Colors.red),
            ),
            if (authProvider.isLoggedIn)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_done, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text('Đã lưu lên server', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: Text('Chơi Lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Thoát'),
          ),
        ],
      ),
    );
  }

  /// Restart game
  void _restartGame() {
    setState(() {
      _level = 1;
      _score = 0;
      _currentHP = 3;
      _streak = 0;
      _maxStreak = 0;
      _questionsInLevel = 0;
      _timeFreezeRemaining = 2;
      _skipRemaining = 2;
      _fiftyFiftyRemaining = 2;
    });
    _startNewProblem();
  }

  // Power-ups
  void _useTimeFreeze() {
    if (_timeFreezeRemaining <= 0 || _isTimeFrozen) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _timeFreezeRemaining--;
      _isTimeFrozen = true;
    });

    // Freeze for 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isTimeFrozen = false);
      }
    });
  }

  void _useSkip() {
    if (_skipRemaining <= 0 || _isProcessing) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _skipRemaining--;
    });

    _problemTimer?.cancel();
    _startNewProblem();
  }

  void _useFiftyFifty() {
    if (_fiftyFiftyRemaining <= 0 || _hiddenAnswers.length >= 2) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _fiftyFiftyRemaining--;

      // Hide 2 wrong answers
      final wrongAnswers = _currentProblem.answers
          .where((a) => a != _currentProblem.correctAnswer)
          .toList();
      wrongAnswers.shuffle();
      _hiddenAnswers.add(wrongAnswers[0]);
      _hiddenAnswers.add(wrongAnswers[1]);
    });
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('⚡ Quick Math'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _restartGame),
        ],
      ),
      body: Column(
        children: [
          // Header with HP and Stats
          Container(
            padding: EdgeInsets.all(16),
            color: theme.primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MathHPDisplay(currentHP: _currentHP, maxHP: _maxHP),
                    Text(
                      'Level $_level',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_score 💎',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔥 Streak: $_streak', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 16),
                    Text(
                      'Progress: $_questionsInLevel/$_questionsPerLevel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Timer Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: MathTimerBar(
              timeRemaining: _timeRemaining,
              timeLimit: _currentProblem.timeLimit,
            ),
          ),

          SizedBox(height: 32),

          // Problem Display
          Container(
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _currentProblem.displayText,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 32),

          // Answer Grid (2x2)
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: _currentProblem.answers.length,
                itemBuilder: (context, index) {
                  final answer = _currentProblem.answers[index];
                  final isHidden = _hiddenAnswers.contains(answer);

                  if (isHidden) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: 48,
                          color: Colors.grey[500],
                        ),
                      ),
                    );
                  }

                  return MathAnswerButton(
                    answer: answer,
                    onTap: () => _onAnswerTap(answer),
                    isDisabled: _isProcessing,
                  );
                },
              ),
            ),
          ),

          // Power-ups Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: MathPowerUpBar(
              timeFreezeRemaining: _timeFreezeRemaining,
              skipRemaining: _skipRemaining,
              fiftyFiftyRemaining: _fiftyFiftyRemaining,
              onTimeFreeze: _useTimeFreeze,
              onSkip: _useSkip,
              onFiftyFifty: _useFiftyFifty,
              isDisabled: _isProcessing,
            ),
          ),
        ],
      ),
    );
  }
}
