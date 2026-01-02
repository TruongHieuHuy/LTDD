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

class CowsBullsGameScreen extends StatefulWidget {
  final String? challengeId;
  final int? challengeGameNumber;
  
  const CowsBullsGameScreen({
    super.key,
    this.challengeId,
    this.challengeGameNumber,
  });

  @override
  State<CowsBullsGameScreen> createState() => _CowsBullsGameScreenState();
}

class _CowsBullsGameScreenState extends State<CowsBullsGameScreen>
    with TickerProviderStateMixin {
  final TextEditingController _guessController = TextEditingController();
  final _random = Random();

  // Game state
  String _level = '6digit'; // '6digit' or '8digit'
  late String _targetCode;
  late int _maxAttempts;
  int _currentAttempt = 0;
  List<GuessResult> _guessHistory = [];
  String? _feedbackMessage;
  bool _isWon = false;
  bool _isGameOver = false;
  bool _showFireworks = false;
  bool _showFakeAd = false;
  int _wrongAttempts = 0;
  int _thinkingTime = 0;
  Timer? _thinkingTimer;
  late AnimationController _shakeController;
  late AnimationController _tickerController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _initGame();
  }

  void _initGame() {
    setState(() {
      final digitCount = _level == '6digit' ? 6 : 8; // Changed from 10
      _maxAttempts = _level == '6digit' ? 8 : 10; // Changed from 12

      // Generate unique random digits
      _targetCode = _generateUniqueCode(digitCount);
      _currentAttempt = 0;
      _guessHistory = [];
      _feedbackMessage = null;
      _isWon = false;
      _isGameOver = false;
      _showFireworks = false;
      _showFakeAd = false;
      _wrongAttempts = 0;
      _thinkingTime = 0;
    });

    _startThinkingTimer();
  }

  String _generateUniqueCode(int length) {
    final digits = List.generate(10, (i) => i);
    digits.shuffle(_random);
    return digits.take(length).join();
  }

  void _startThinkingTimer() {
    _thinkingTimer?.cancel();
    _thinkingTime = 0;
    _thinkingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _thinkingTime++;
      });

      if (_thinkingTime == 10 && _level == '8digit') {
        // Changed from 10digit
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
    final digitCount = _level == '6digit' ? 6 : 8; // Changed from 10

    if (guessText.length != digitCount) {
      _showQuickFeedback('Nhập đủ $digitCount số chứ bro! 🤨');
      return;
    }

    // Check for unique digits
    if (guessText.split('').toSet().length != digitCount) {
      _showQuickFeedback('Các số phải khác nhau nha! 🙄');
      return;
    }

    setState(() {
      _currentAttempt++;
      _thinkingTime = 0;
    });

    _thinkingTimer?.cancel();

    final result = _calculateBullsAndCows(guessText);
    _guessHistory.add(result);

    if (result.bulls == digitCount) {
      _onWin();
    } else if (_currentAttempt >= _maxAttempts) {
      _onLose();
    } else {
      _provideFeedback(result);

      // Troll: Show fake ad after 6 wrong attempts on 8 digit level
      if (_level == '8digit' && result.bulls < digitCount) {
        _wrongAttempts++;
        if (_wrongAttempts == 6) {
          // Changed from 5
          _showFakeAdPopup();
        }
      }
    }

    _guessController.clear();
    _startThinkingTimer();
  }

  GuessResult _calculateBullsAndCows(String guess) {
    int bulls = 0;
    int cows = 0;

    for (int i = 0; i < guess.length; i++) {
      if (guess[i] == _targetCode[i]) {
        bulls++;
      } else if (_targetCode.contains(guess[i])) {
        cows++;
      }
    }

    return GuessResult(guess: guess, bulls: bulls, cows: cows);
  }

  void _provideFeedback(GuessResult result) {
    String feedback;

    if (result.bulls == 0 && result.cows == 0) {
      feedback = MemeTexts.random(MemeTexts.noBullsNoCows);
      // Play troll sound for total miss
      GameAudioService.playTroll();
    } else {
      final bullText = result.bulls > 0
          ? MemeTexts.bullsFound(result.bulls)
          : '';
      final cowText = result.cows > 0 ? MemeTexts.cowsFound(result.cows) : '';
      feedback = [bullText, cowText].where((s) => s.isNotEmpty).join('\n');
      // Play bonk for partial match
      GameAudioService.playBonk();
    }

    setState(() {
      _feedbackMessage = feedback;
    });

    // Increment meme counter
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.incrementMemeEncounters();

    if (_currentAttempt >= _maxAttempts ~/ 2) {
      _shakeScreen();
    }
  }

  void _onWin() async {
    setState(() {
      _isWon = true;
      _isGameOver = true;
      _feedbackMessage = MemeTexts.random(MemeTexts.cowsBullsWin);
      _showFireworks = true;
    });
    _thinkingTimer?.cancel();

    // Play victory sound
    GameAudioService.playVictory();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showFireworks = false;
        });
      }
    });

    // Calculate score
    final score = _calculateScore();
    
    // Challenge mode - submit score to PK system
    if (widget.challengeId != null && widget.challengeGameNumber != null) {
      try {
        await ApiService().submitChallengeScore(
          challengeId: widget.challengeId!,
          gameNumber: widget.challengeGameNumber!,
          score: score,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Score $score submitted!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }
    
    // Normal mode
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final newAchievements = await gameProvider.saveGameScore(
      gameType: 'cows_bulls',
      score: score,
      attempts: _currentAttempt,
      difficulty: _level,
      timeSpent: _thinkingTime,
    );

    // Save to backend if logged in
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn && mounted) {
      try {
        await ApiService().saveScore(
          gameType: 'cows_bulls',
          score: score,
          difficulty: _level == '6digit' ? 'easy' : 'hard',
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
        debugPrint('Failed to save score: $e');
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

    // Show achievement dialog if any
    if (newAchievements.isNotEmpty && mounted) {
      _showAchievementDialog(newAchievements);
    }
  }

  int _calculateScore() {
    // Base score: 1200 (harder than guess number)
    // Bonus for fewer attempts
    // Bonus for speed
    int baseScore = 1200;
    int attemptMultiplier = _maxAttempts - _currentAttempt + 1;
    double timeBonus = 1.0;

    if (_thinkingTime < 60) {
      timeBonus = 1.5;
    } else if (_thinkingTime < 120) {
      timeBonus = 1.2;
    }

    return (baseScore * attemptMultiplier * timeBonus).toInt();
  }

  void _onLose() {
    setState(() {
      _isGameOver = true;
      _feedbackMessage =
          '${MemeTexts.random(MemeTexts.gameOver)}\nĐáp án: $_targetCode';
    });
    _thinkingTimer?.cancel();

    // Play sad sound
    GameAudioService.playSadTrombone();
  }

  void _showFakeAdPopup() {
    setState(() {
      _showFakeAd = true;
    });
  }

  void _closeFakeAd() {
    setState(() {
      _showFakeAd = false;
    });
  }

  void _surrender() {
    setState(() {
      _isGameOver = true;
      _feedbackMessage =
          '${MemeTexts.random(MemeTexts.surrender)}\nĐáp án: $_targetCode';
    });
    _thinkingTimer?.cancel();

    // Play bruh sound for giving up
    GameAudioService.playBruh();
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
    _tickerController.dispose();
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
          '🐮 Bò & Bê',
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
                        _buildLevelSelector(theme),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(
                              theme,
                              '🐂',
                              'Đúng vị trí',
                              Colors.green,
                            ),
                            const SizedBox(width: 16),
                            _buildLegendItem(
                              theme,
                              '🤡',
                              'Sai vị trí',
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (!_isGameOver) ...[
                            _buildPatienceBar(theme),
                            const SizedBox(height: 24),
                            _buildInputArea(theme),
                            const SizedBox(height: 20),
                            _buildActionButtons(theme),
                          ],

                          if (_feedbackMessage != null) ...[
                            const SizedBox(height: 24),
                            _buildFeedbackCard(theme),
                          ],

                          if (_guessHistory.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildHistory(theme),
                          ],

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

              if (_showFireworks)
                const Positioned.fill(child: FireworkEffect()),

              // TROLL: Fake ad overlay (keep this!)
              if (_showFakeAd) _buildFakeAdOverlay(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    ThemeData theme,
    String emoji,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

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

  Widget _buildLevelSelector(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLevelChip(theme, 'Tấm Chiếu Mới', '6digit', '6 số (8 lượt)'),
        _buildLevelChip(theme, 'Thách Thức Khó', '8digit', '8 số (10 lượt)'),
      ],
    );
  }

  Widget _buildLevelChip(
    ThemeData theme,
    String label,
    String value,
    String hint,
  ) {
    final isSelected = _level == value;
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: hint,
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: _isGameOver
            ? null
            : (_) {
                if (_level != value) {
                  setState(() => _level = value);
                  _initGame();
                }
              },
        backgroundColor: theme.cardColor,
        selectedColor: colorScheme.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    final digitCount = _level == '6digit' ? 6 : 10;

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
                  Icons.casino_outlined,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nhập $digitCount số khác nhau (0-9):',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // LED Ticker style for 8 digits (modern look with theme colors)
            if (_level == '8digit')
              _buildLEDTicker(theme)
            else
              _buildNormalInput(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalInput(ThemeData theme) {
    return TextField(
      controller: _guessController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      textAlign: TextAlign.center,
      style: theme.textTheme.headlineLarge?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        letterSpacing: 6,
        fontFamily: 'monospace',
      ),
      decoration: const InputDecoration(hintText: '? ? ? ? ? ?'),
      onSubmitted: (_) => _makeGuess(),
    );
  }

  Widget _buildLEDTicker(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Digital display look with theme colors
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.black
                : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.secondary, width: 2),
            boxShadow: [
              BoxShadow(
                color: colorScheme.secondary.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: TextField(
              controller: _guessController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8), // Changed from 10
              ],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.secondary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                fontFamily: 'monospace',
                shadows: [
                  Shadow(
                    color: colorScheme.secondary.withOpacity(0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '? ? ? ? ? ? ? ?', // Changed to 8 digits
                hintStyle: TextStyle(
                  color: Colors.grey.shade700,
                  letterSpacing: 4,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: (_) => _makeGuess(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, color: Colors.red.shade400, size: 20),
            const SizedBox(width: 8),
            Text(
              'Level khó nhất - Hãy cố gắng!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade400,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
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
                  'GỬI ĐÁP ÁN',
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
        ),

        // TROLL: Surrender button (keep this!)
        if (_level == '8digit' && _currentAttempt > 5) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _surrender,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text(
                '🏳️ BẤM ĐÂY ĐỂ GIẢI THOÁT 🏳️',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
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
            ..._guessHistory.reversed.take(5).map((result) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        result.guess,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'monospace',
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        '🐂 ${result.bulls}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Text(
                        '🤡 ${result.cows}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // TROLL: Keep fake ad overlay!
  Widget _buildFakeAdOverlay(ThemeData theme) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _closeFakeAd,
        child: Container(
          color: Colors.black.withOpacity(0.85),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.yellow.shade700, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🛒', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 8),
                      Text(
                        'QUẢNG CÁO',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.yellow.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Thuốc Bổ Não Giá Rẻ\n💊 Giảm 99% hôm nay!\n🧠 Tăng IQ lên gấp đôi!',
                    style: theme.textTheme.titleLarge?.copyWith(height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '(Đùa thôi, bấm X để đóng)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _closeFakeAd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.close, size: 32),
                  ),
                ],
              ),
            ),
          ),
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

class GuessResult {
  final String guess;
  final int bulls; // Đúng số đúng vị trí (🐂)
  final int cows; // Đúng số sai vị trí (🤡)

  GuessResult({required this.guess, required this.bulls, required this.cows});
}
