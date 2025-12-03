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

class CowsBullsGameScreen extends StatefulWidget {
  const CowsBullsGameScreen({super.key});

  @override
  State<CowsBullsGameScreen> createState() => _CowsBullsGameScreenState();
}

class _CowsBullsGameScreenState extends State<CowsBullsGameScreen>
    with TickerProviderStateMixin {
  final TextEditingController _guessController = TextEditingController();
  final _random = Random();

  // Game state
  String _level = '6digit'; // '6digit' or '10digit'
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
      final digitCount = _level == '6digit' ? 6 : 10;
      _maxAttempts = _level == '6digit' ? 8 : 12;

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

      if (_thinkingTime == 10 && _level == '10digit') {
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
    final digitCount = _level == '6digit' ? 6 : 10;

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

      // Troll: Show fake ad after 5 wrong attempts on 10 digit level
      if (_level == '10digit' && result.bulls < digitCount) {
        _wrongAttempts++;
        if (_wrongAttempts == 5) {
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

    // Save score to Hive & check achievements
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final score = _calculateScore();
    final newAchievements = await gameProvider.saveGameScore(
      gameType: 'cows_bulls',
      score: score,
      attempts: _currentAttempt,
      difficulty: _level,
      timeSpent: _thinkingTime,
    );

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
                              _buildActionButtons(),
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
                if (_showFakeAd) _buildFakeAdOverlay(),
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
                '🐮 BÒ & BÊ',
                style: TextStyle(
                  color: GameColors.neonYellow,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildLevelSelector(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🐂 = đúng vị trí  ',
                style: TextStyle(color: GameColors.successGreen),
              ),
              const Text(
                '🤡 = sai vị trí',
                style: TextStyle(color: GameColors.warningOrange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLevelChip('Tấm Chiếu Mới', '6digit', '6 số (8 lượt)'),
        _buildLevelChip('Thách Thức Tuyệt Vọng', '10digit', '10 số (12 lượt)'),
      ],
    );
  }

  Widget _buildLevelChip(String label, String value, String hint) {
    final isSelected = _level == value;
    return Tooltip(
      message: hint,
      child: GestureDetector(
        onTap: _isGameOver
            ? null
            : () {
                if (_level != value) {
                  setState(() => _level = value);
                  _initGame();
                }
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final digitCount = _level == '6digit' ? 6 : 10;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameColors.darkGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameColors.neonCyan, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Nhập $digitCount số khác nhau (0-9):',
            style: const TextStyle(
              color: GameColors.neonCyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          // LED Ticker style cho 10 số
          if (_level == '10digit') _buildLEDTicker() else _buildNormalInput(),
        ],
      ),
    );
  }

  Widget _buildNormalInput() {
    return TextField(
      controller: _guessController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: GameColors.textWhite,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 8,
      ),
      decoration: InputDecoration(
        hintText: '? ? ? ? ? ?',
        hintStyle: const TextStyle(color: GameColors.textGray),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: GameColors.neonYellow),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: GameColors.neonYellow, width: 2),
        ),
      ),
      onSubmitted: (_) => _makeGuess(),
    );
  }

  Widget _buildLEDTicker() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _tickerController,
          builder: (context, child) {
            return Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GameColors.neonYellow, width: 2),
              ),
              child: Center(
                child: TextField(
                  controller: _guessController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: GameColors.neonYellow,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: GameColors.neonYellow.withOpacity(0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '? ? ? ? ? ? ? ? ? ?',
                    hintStyle: TextStyle(color: GameColors.textGray),
                  ),
                  onSubmitted: (_) => _makeGuess(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        const Text(
          '⚠️ Level khó nhất - Hãy cố gắng!',
          style: TextStyle(
            color: GameColors.trollRed,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _makeGuess,
          style: ElevatedButton.styleFrom(
            backgroundColor: GameColors.neonPink,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 10,
            shadowColor: GameColors.neonPink.withOpacity(0.5),
          ),
          child: const Text(
            'GỬI ĐÁP ÁN 🎯',
            style: TextStyle(
              color: GameColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        if (_level == '10digit' && _currentAttempt > 5) ...[
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _surrender,
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.trollRed,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                '🏳️ BẤM ĐÂY ĐỂ GIẢI THOÁT 🏳️',
                style: TextStyle(
                  color: GameColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
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
          ..._guessHistory.reversed.take(5).map((result) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      result.guess,
                      style: const TextStyle(
                        color: GameColors.textWhite,
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Text(
                    '🐂 ${result.bulls}',
                    style: const TextStyle(
                      color: GameColors.successGreen,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '🤡 ${result.cows}',
                    style: const TextStyle(
                      color: GameColors.warningOrange,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFakeAdOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _closeFakeAd,
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(40),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: GameColors.darkGray,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GameColors.neonYellow, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🛒 QUẢNG CÁO',
                    style: TextStyle(
                      color: GameColors.neonYellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Thuốc Bổ Não Giá Rẻ\n💊 Giảm 99% hôm nay!\n🧠 Tăng IQ lên gấp đôi!\n\n(Đùa thôi, bấm X để đóng)',
                    style: TextStyle(
                      color: GameColors.textWhite,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _closeFakeAd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameColors.trollRed,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: GameColors.textWhite,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
              colors: [GameColors.neonCyan, GameColors.neonGreen],
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

class GuessResult {
  final String guess;
  final int bulls; // Đúng số đúng vị trí (🐂)
  final int cows; // Đúng số sai vị trí (🤡)

  GuessResult({required this.guess, required this.bulls, required this.cows});
}
