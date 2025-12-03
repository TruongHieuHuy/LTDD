import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import '../../utils/game_utils/game_colors.dart';
import '../../utils/game_utils/meme_texts.dart';
import '../../widgets/game_widgets/patience_bar.dart';
import '../../widgets/game_widgets/meme_feedback.dart';
import '../../widgets/game_widgets/firework_effect.dart';
import '../../providers/game_provider.dart';
import '../../utils/game_audio_service.dart';

class GuessNumberGameScreen extends StatefulWidget {
  const GuessNumberGameScreen({super.key});

  @override
  State<GuessNumberGameScreen> createState() => _GuessNumberGameScreenState();
}

class _GuessNumberGameScreenState extends State<GuessNumberGameScreen>
    with TickerProviderStateMixin {
  final TextEditingController _guessController = TextEditingController();
  final _random = Random();

  // Game state
  String _difficulty = 'normal'; // 'easy', 'normal', 'hard'
  late int _targetNumber;
  late int _minRange;
  late int _maxRange;
  late int _maxAttempts;
  int _currentAttempt = 0;
  List<int> _guessHistory = [];
  String? _feedbackMessage;
  bool _isWon = false;
  bool _isGameOver = false;
  bool _showFireworks = false;
  int _thinkingTime = 0;
  Timer? _thinkingTimer;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initGame();
  }

  void _initGame() {
    setState(() {
      switch (_difficulty) {
        case 'easy':
          _minRange = 1;
          _maxRange = 50;
          _maxAttempts = 7;
          break;
        case 'hard':
          _minRange = 1;
          _maxRange = 200;
          _maxAttempts = 3;
          break;
        default: // normal
          _minRange = 1;
          _maxRange = 100;
          _maxAttempts = 5;
      }

      _targetNumber = _minRange + _random.nextInt(_maxRange - _minRange + 1);
      _currentAttempt = 0;
      _guessHistory = [];
      _feedbackMessage = null;
      _isWon = false;
      _isGameOver = false;
      _showFireworks = false;
      _thinkingTime = 0;
    });

    _startThinkingTimer();
  }

  void _startThinkingTimer() {
    _thinkingTimer?.cancel();
    _thinkingTime = 0;
    _thinkingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _thinkingTime++;
      });

      if (_thinkingTime == 15) {
        _showQuickFeedback(MemeTexts.random(MemeTexts.thinking));
      } else if (_thinkingTime == 30) {
        _showQuickFeedback(MemeTexts.tooLongThinking);
        _shakeScreen();
      }
    });
  }

  void _shakeScreen() {
    _shakeController.forward(from: 0);
  }

  void _makeGuess() {
    final guessText = _guessController.text;
    if (guessText.isEmpty) return;

    final guess = int.tryParse(guessText);
    if (guess == null || guess < _minRange || guess > _maxRange) {
      _showQuickFeedback('Nhập số từ $_minRange đến $_maxRange chứ 🤨');
      GameAudioService.playError();
      return;
    }

    setState(() {
      _currentAttempt++;
      _guessHistory.add(guess);
      _thinkingTime = 0;
    });

    _thinkingTimer?.cancel();

    if (guess == _targetNumber) {
      _onWin();
    } else if (_currentAttempt >= _maxAttempts) {
      _onLose();
    } else {
      _provideFeedback(guess);
    }

    _guessController.clear();
    _startThinkingTimer();
  }

  void _provideFeedback(int guess) {
    final diff = (guess - _targetNumber).abs();
    String feedback;

    if (diff <= 5) {
      feedback = MemeTexts.random(MemeTexts.veryClose);
    } else if (guess > _targetNumber) {
      feedback = MemeTexts.random(MemeTexts.tooHigh);
    } else {
      feedback = MemeTexts.random(MemeTexts.tooLow);
    }

    setState(() {
      _feedbackMessage = feedback;
    });

    // Play bonk sound for wrong guess
    GameAudioService.playBonk();

    // Increment meme counter
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.incrementMemeEncounters();

    // Rung màn hình nếu sai quá 3 lần
    if (_currentAttempt >= 3) {
      _shakeScreen();
    }
  }

  void _onWin() async {
    setState(() {
      _isWon = true;
      _isGameOver = true;
      _feedbackMessage = MemeTexts.random(MemeTexts.correct);
      _showFireworks = true;
    });
    _thinkingTimer?.cancel();

    // Play victory sound
    GameAudioService.playVictory();

    // Tắt pháo hoa sau 3 giây
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showFireworks = false;
        });
      }
    });

    // Save score to Hive & check achievements
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final score = _calculateScore();
    final newAchievements = await gameProvider.saveGameScore(
      gameType: 'guess_number',
      score: score,
      attempts: _currentAttempt,
      difficulty: _difficulty,
      timeSpent: _thinkingTime,
    );

    // Show achievement unlocked dialog if any
    if (newAchievements.isNotEmpty && mounted) {
      _showAchievementDialog(newAchievements);
    }
  }

  int _calculateScore() {
    // Base score: 1000
    // Bonus for fewer attempts: x(maxAttempts - attempts + 1)
    // Bonus for speed: +50% if <30s, +20% if <60s
    int baseScore = 1000;
    int attemptMultiplier = _maxAttempts - _currentAttempt + 1;
    double timeBonus = 1.0;

    if (_thinkingTime < 30) {
      timeBonus = 1.5;
    } else if (_thinkingTime < 60) {
      timeBonus = 1.2;
    }

    return (baseScore * attemptMultiplier * timeBonus).toInt();
  }

  void _onLose() {
    setState(() {
      _isGameOver = true;
      _feedbackMessage =
          '${MemeTexts.random(MemeTexts.gameOver)}\nĐáp án: $_targetNumber';
    });
    _thinkingTimer?.cancel();

    // Play sad sound
    GameAudioService.playSadTrombone();
  }

  void _showQuickFeedback(String message) {
    setState(() {
      _feedbackMessage = message;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _feedbackMessage == message) {
        setState(() {
          _feedbackMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _guessController.dispose();
    _thinkingTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.darkGradient),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final shake = sin(_shakeController.value * pi * 8) * 10;
              return Transform.translate(
                offset: Offset(shake, 0),
                child: child,
              );
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (!_isGameOver) ...[
                              PatienceBar(
                                currentAttempts: _currentAttempt,
                                maxAttempts: _maxAttempts,
                              ),
                              const SizedBox(height: 20),
                              _buildInputArea(),
                              const SizedBox(height: 20),
                              _buildGuessButton(),
                            ],
                            if (_feedbackMessage != null) ...[
                              const SizedBox(height: 20),
                              MemeFeedback(
                                message: _feedbackMessage!,
                                isSuccess: _isWon,
                                onDismiss: () {
                                  setState(() => _feedbackMessage = null);
                                },
                              ),
                            ],
                            if (_guessHistory.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              _buildHistory(),
                            ],
                            if (_isGameOver) ...[
                              const SizedBox(height: 20),
                              _buildGameOverActions(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showFireworks)
                  const Positioned.fill(child: FireworkEffect()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameColors.darkGray.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: GameColors.neonCyan),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                '🎲 ĐOÁN SỐ',
                style: TextStyle(
                  color: GameColors.neonYellow,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDifficultySelector(),
          const SizedBox(height: 10),
          Text(
            'Số từ $_minRange đến $_maxRange',
            style: const TextStyle(color: GameColors.textGray, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDifficultyChip('Tấm Chiếu Mới', 'easy', '1-50 (7 lượt)'),
        _buildDifficultyChip('Dân Chơi Hệ', 'normal', '1-100 (5 lượt)'),
        _buildDifficultyChip('Điên Không?', 'hard', '1-200 (3 lượt)'),
      ],
    );
  }

  Widget _buildDifficultyChip(String label, String value, String hint) {
    final isSelected = _difficulty == value;
    return Tooltip(
      message: hint,
      child: GestureDetector(
        onTap: _isGameOver
            ? null
            : () {
                if (_difficulty != value) {
                  setState(() => _difficulty = value);
                  _initGame();
                }
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? GameColors.neonPink : GameColors.darkCharcoal,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? GameColors.neonPink : GameColors.textGray,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? GameColors.textWhite : GameColors.textGray,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameColors.darkGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameColors.neonCyan, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'Nhập số của bạn:',
            style: TextStyle(
              color: GameColors.neonCyan,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _guessController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GameColors.textWhite,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '???',
              hintStyle: const TextStyle(color: GameColors.textGray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: GameColors.neonYellow),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: GameColors.neonYellow,
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => _makeGuess(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuessButton() {
    return ElevatedButton(
      onPressed: _makeGuess,
      style: ElevatedButton.styleFrom(
        backgroundColor: GameColors.neonPink,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
        shadowColor: GameColors.neonPink.withOpacity(0.5),
      ),
      child: const Text(
        'CHỐT ĐƠN 🎯',
        style: TextStyle(
          color: GameColors.textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: GameColors.darkGray.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch sử đoán:',
            style: TextStyle(
              color: GameColors.neonYellow,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _guessHistory.map((guess) {
              final isClose = (guess - _targetNumber).abs() <= 10;
              return Chip(
                label: Text(
                  guess.toString(),
                  style: const TextStyle(color: GameColors.textWhite),
                ),
                backgroundColor: isClose
                    ? GameColors.warningOrange
                    : GameColors.trollRed,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverActions() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _initGame,
          icon: const Icon(Icons.refresh),
          label: const Text('CHƠI LẠI'),
          style: ElevatedButton.styleFrom(
            backgroundColor: GameColors.successGreen,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Về trang chủ',
            style: TextStyle(color: GameColors.textGray),
          ),
        ),
      ],
    );
  }

  void _showAchievementDialog(List newAchievements) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [GameColors.neonYellow, GameColors.neonOrange],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 HUY HIỆU MỚI!',
                style: TextStyle(
                  color: GameColors.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...newAchievements.map(
                (achievement) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        achievement.iconEmoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.name,
                              style: const TextStyle(
                                color: GameColors.textWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              achievement.description,
                              style: const TextStyle(
                                color: GameColors.textGray,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameColors.textWhite,
                ),
                child: const Text(
                  'TUYỆT VỜI!',
                  style: TextStyle(
                    color: GameColors.darkGray,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
