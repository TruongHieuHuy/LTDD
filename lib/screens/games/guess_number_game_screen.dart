import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import '../../utils/game_utils/meme_texts.dart';
import '../../widgets/game_widgets/firework_effect.dart';
import '../../providers/game_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/game_audio_service.dart';

class GuessNumberGameScreen extends StatefulWidget {
  final String? challengeId;
  final int? challengeGameNumber;

  const GuessNumberGameScreen({
    super.key,
    this.challengeId,
    this.challengeGameNumber,
  });

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
          _maxRange = 150; // Reduced from 200
          _maxAttempts = 5; // Increased from 3
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

    // Calculate score
    final score = _calculateScore();
    
    // Save score to Hive (local) & check achievements
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final newAchievements = await gameProvider.saveGameScore(
      gameType: 'guess_number',
      score: score,
      attempts: _currentAttempt,
      difficulty: _difficulty,
      timeSpent: _thinkingTime,
    );

    // Save score to backend if logged in
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn && mounted) {
      try {
        await ApiService().saveScore(
          gameType: 'guess_number',
          score: score,
          difficulty: _difficulty,
          attempts: _currentAttempt,
          timeSpent: _thinkingTime,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.cloud_upload, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('✅ Điểm đã lưu lên server! ($score điểm)'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        debugPrint('Failed to save score to backend: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.white),
                  SizedBox(width: 8),
                  Text('⚠️ Lưu offline - Kết nối lại để đồng bộ'),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '🎲 Đoán Số',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final shake = sin(_shakeController.value * pi * 8) * 10;
            return Transform.translate(offset: Offset(shake, 0), child: child);
          },
          child: Stack(
            children: [
              Column(
                children: [
                  // Game info banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDifficultySelector(theme),
                        const SizedBox(height: 12),
                        Text(
                          'Số từ $_minRange đến $_maxRange',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Patience bar (custom design)
                          if (!_isGameOver) ...[
                            _buildPatienceBar(theme),
                            const SizedBox(height: 24),
                            _buildInputArea(theme),
                            const SizedBox(height: 20),
                            _buildGuessButton(theme),
                          ],

                          // Feedback message
                          if (_feedbackMessage != null) ...[
                            const SizedBox(height: 24),
                            _buildFeedbackCard(theme),
                          ],

                          // Guess history
                          if (_guessHistory.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildHistory(theme),
                          ],

                          // Game over actions
                          if (_isGameOver) ...[
                            const SizedBox(height: 24),
                            _buildGameOverActions(theme),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Fireworks overlay
              if (_showFireworks)
                const Positioned.fill(child: FireworkEffect()),
            ],
          ),
        ),
      ),
    );
  }

  // Patience bar with theme colors
  Widget _buildPatienceBar(ThemeData theme) {
    final progress = _currentAttempt / _maxAttempts;
    final remaining = _maxAttempts - _currentAttempt;

    Color barColor;
    if (progress < 0.5) {
      barColor = Colors.green;
    } else if (progress < 0.8) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lượt còn lại',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$remaining/$_maxAttempts',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 1 - progress,
                minHeight: 12,
                backgroundColor: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                color: barColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildDifficultyChip(theme, 'Tấm Chiếu Mới', 'easy', '1-50 (7 lượt)'),
        _buildDifficultyChip(theme, 'Dân Chơi Hệ', 'normal', '1-100 (5 lượt)'),
        _buildDifficultyChip(theme, 'Điên Không?', 'hard', '1-200 (3 lượt)'),
      ],
    );
  }

  Widget _buildDifficultyChip(
    ThemeData theme,
    String label,
    String value,
    String hint,
  ) {
    final isSelected = _difficulty == value;
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: hint,
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: _isGameOver
            ? null
            : (_) {
                if (_difficulty != value) {
                  setState(() => _difficulty = value);
                  _initGame();
                }
              },
        backgroundColor: theme.cardColor,
        selectedColor: colorScheme.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nhập số của bạn:',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _guessController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                hintText: '???',
                hintStyle: TextStyle(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.3),
                ),
              ),
              onSubmitted: (_) => _makeGuess(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuessButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _makeGuess,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'CHỐT ĐƠN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            const Text('🎯', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(ThemeData theme) {
    final isError = !_isWon && _isGameOver;
    final isSuccess = _isWon;

    Color bgColor;
    Color textColor;
    IconData icon;

    if (isSuccess) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade900;
      icon = Icons.celebration;
    } else if (isError) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade900;
      icon = Icons.sentiment_dissatisfied;
    } else {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade900;
      icon = Icons.info_outline;
    }

    if (theme.brightness == Brightness.dark) {
      bgColor = isSuccess
          ? Colors.green.shade900.withOpacity(0.3)
          : isError
          ? Colors.red.shade900.withOpacity(0.3)
          : Colors.orange.shade900.withOpacity(0.3);
      textColor = isSuccess
          ? Colors.green.shade200
          : isError
          ? Colors.red.shade200
          : Colors.orange.shade200;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 48),
          const SizedBox(height: 12),
          Text(
            _feedbackMessage!,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_isGameOver) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() => _feedbackMessage = null);
              },
              child: Text('Đóng', style: TextStyle(color: textColor)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistory(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lịch sử đoán:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _guessHistory.map((guess) {
                final isClose = (guess - _targetNumber).abs() <= 10;
                return Chip(
                  label: Text(
                    guess.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  backgroundColor: isClose
                      ? Colors.orange.shade100
                      : theme.brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  side: BorderSide(
                    color: isClose ? Colors.orange : Colors.transparent,
                    width: 2,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverActions(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _initGame,
            icon: const Icon(Icons.refresh),
            label: const Text('CHƠI LẠI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Về trang chủ'),
        ),
      ],
    );
  }

  void _showAchievementDialog(List newAchievements) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 HUY HIỆU MỚI!',
                style: TextStyle(
                  color: Colors.white,
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
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              achievement.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
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
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                ),
                child: const Text(
                  'TUYỆT VỜI!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
