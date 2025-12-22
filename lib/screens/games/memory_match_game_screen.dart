import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/memory_card_model.dart';
import '../../utils/game_utils/memory_icon_provider.dart';
import '../../utils/game_utils/memory_game_generator.dart';
import '../../widgets/game_widgets/memory_card_widget.dart';

/// Memory Match Game Screen
/// Game lật thẻ ghi nhớ với 3 độ khó
class MemoryMatchGameScreen extends StatefulWidget {
  const MemoryMatchGameScreen({Key? key}) : super(key: key);

  @override
  State<MemoryMatchGameScreen> createState() => _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen> {
  // Game state
  String _difficulty = 'easy';
  List<MemoryCard> _cards = [];
  List<MemoryCard> _selectedCards = [];
  bool _isProcessing = false;
  bool _isPreviewPhase = true;
  int _previewCountdown = 0;

  // Stats
  int _moves = 0;
  int _timeElapsed = 0;
  int _currentStreak = 0;
  int _maxStreak = 0;
  int _pairsFound = 0;
  int _score = 0;

  // Timers
  Timer? _gameTimer;
  Timer? _previewTimer;
  int? _timeLimit;

  // Power-ups
  int _hintsRemaining = 3;
  final int _hintCost = 50;

  @override
  void initState() {
    super.initState();
    _showDifficultySelector();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _previewTimer?.cancel();
    super.dispose();
  }

  /// Show difficulty selector dialog
  void _showDifficultySelector() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('🧩 Chọn Độ Khó'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDifficultyButton(
                'Easy',
                '4×4 (8 cặp)\nKhông giới hạn thời gian',
                Colors.green,
              ),
              SizedBox(height: 12),
              _buildDifficultyButton(
                'Normal',
                '4×5 (10 cặp)\n120 giây',
                Colors.orange,
              ),
              SizedBox(height: 12),
              _buildDifficultyButton(
                'Hard',
                '5×6 (15 cặp)\n150 giây\nDouble Coding',
                Colors.red,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDifficultyButton(
    String difficulty,
    String description,
    Color color,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.all(16),
        minimumSize: Size(double.infinity, 80),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        _startGame(difficulty.toLowerCase());
      },
      child: Column(
        children: [
          Text(
            difficulty,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Start game
  void _startGame(String difficulty) {
    _gameTimer?.cancel();
    _previewTimer?.cancel();

    setState(() {
      _difficulty = difficulty;
      _cards = MemoryGameGenerator.generateCards(difficulty);
      _selectedCards = [];
      _isProcessing = false;
      _isPreviewPhase = true;
      _moves = 0;
      _timeElapsed = 0;
      _currentStreak = 0;
      _maxStreak = 0;
      _pairsFound = 0;
      _score = difficulty == 'easy'
          ? 1000
          : difficulty == 'normal'
          ? 1500
          : 2500;
      _hintsRemaining = 3;
      _timeLimit = MemoryIconProvider.getTimeLimit(difficulty);
      _previewCountdown = MemoryIconProvider.getPreviewDuration(difficulty);
    });

    print(
      'Starting game - difficulty: $difficulty, _isPreviewPhase: $_isPreviewPhase',
    );
    _startPreviewPhase();
  }

  void _startPreviewPhase() {
    print('Starting preview phase - duration: $_previewCountdown seconds');

    // Nếu không có preview time (countdown = 0), kết thúc ngay
    if (_previewCountdown <= 0) {
      print('No preview time, ending immediately');
      _endPreviewPhase();
      return;
    }

    // Flip tất cả thẻ lên tuần tự với animation
    for (int i = 0; i < _cards.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted && _isPreviewPhase) {
          setState(() => _cards[i].isFlipped = true);
        }
      });
    }

    // Bắt đầu countdown với delay 1s (để user thấy thẻ trước)
    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted || !_isPreviewPhase) return;
      
      _previewTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() => _previewCountdown--);
        print('Preview countdown: $_previewCountdown');

        if (_previewCountdown <= 0) {
          timer.cancel();
          print('Preview countdown finished, calling _endPreviewPhase');
          _endPreviewPhase();
        }
      });
    });
  }

  void _endPreviewPhase() {
    if (!_isPreviewPhase) return; // Đã kết thúc rồi, không làm gì nữa

    print('Ending preview phase...');
    _previewTimer?.cancel(); // Đảm bảo cancel timer

    setState(() {
      _isPreviewPhase = false;
      for (var card in _cards) {
        card.isFlipped = false;
      }
    });
    print(
      'Preview phase ended. _isPreviewPhase = $_isPreviewPhase. Can now play!',
    );

    if (_timeLimit != null) {
      _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() => _timeElapsed++);
        if (_timeElapsed >= _timeLimit!) {
          timer.cancel();
          _onGameLost();
        }
      });
    } else {
      _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() => _timeElapsed++);
      });
    }
  }

  void _onCardTap(int index) {
    final card = _cards[index];

    // Debug: print state
    print(
      'Card tap: index=$index, isPreviewPhase=$_isPreviewPhase, isProcessing=$_isProcessing, isFlipped=${card.isFlipped}, isMatched=${card.isMatched}',
    );

    if (_isProcessing || card.isFlipped || card.isMatched || _isPreviewPhase) {
      print('Card tap blocked!');
      return;
    }

    if (_selectedCards.length == 2) {
      setState(() {
        for (var selectedCard in _selectedCards) selectedCard.isFlipped = false;
        _selectedCards.clear();
      });
    }

    setState(() {
      card.isFlipped = true;
      _selectedCards.add(card);
      _moves++;
    });

    if (_selectedCards.length == 2) {
      _isProcessing = true;
      _checkMatch();
    }
  }

  void _checkMatch() async {
    await Future.delayed(Duration(milliseconds: 500));

    final card1 = _selectedCards[0];
    final card2 = _selectedCards[1];

    if (card1 == card2) {
      HapticFeedback.lightImpact();
      setState(() {
        card1.isMatched = true;
        card2.isMatched = true;
        _pairsFound++;
        _currentStreak++;
        if (_currentStreak > _maxStreak) _maxStreak = _currentStreak;
        _score += 50 + (_currentStreak * 10);
      });

      if (_pairsFound == MemoryIconProvider.getGridSize(_difficulty).pairs) {
        _onGameWon();
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        card1.isFlipped = false;
        card2.isFlipped = false;
        _currentStreak = 0;
      });
    }

    setState(() {
      _selectedCards.clear();
      _isProcessing = false;
    });
  }

  void _onGameWon() {
    _gameTimer?.cancel();
    final baseScore = _difficulty == 'easy'
        ? 1000
        : _difficulty == 'normal'
        ? 1500
        : 2500;
    final movePenalty = _moves * 10;
    double timeBonus = 1.0;

    if (_difficulty != 'easy') {
      if (_timeElapsed < 40)
        timeBonus = 2.0;
      else if (_timeElapsed < 70)
        timeBonus = 1.5;
      else if (_timeElapsed < 100)
        timeBonus = 1.2;
    }

    final streakBonus = _maxStreak * 50;
    final finalScore =
        (((baseScore - movePenalty) * timeBonus).toInt() + streakBonus).clamp(
          0,
          10000,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('🎉 Chiến Thắng!'),
            Spacer(),
            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('💎 Điểm', '$finalScore'),
            _buildStatRow('📊 Moves', '$_moves'),
            _buildStatRow('⏱️ Thời gian', '${_timeElapsed}s'),
            _buildStatRow('🔥 Streak', '$_maxStreak'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDifficultySelector();
            },
            child: Text('Chơi Lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Thoát'),
          ),
        ],
      ),
    );
  }

  void _onGameLost() {
    _gameTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('⏰ Hết Giờ!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tìm được $_pairsFound/${MemoryIconProvider.getGridSize(_difficulty).pairs} cặp',
            ),
            Text('Thời gian: ${_timeLimit}s'),
            Text('Số nước: $_moves'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame(_difficulty);
            },
            child: Text('Thử Lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDifficultySelector();
            },
            child: Text('Đổi Độ Khó'),
          ),
        ],
      ),
    );
  }

  void _useHint() {
    if (_hintsRemaining <= 0) return;
    final card = MemoryGameGenerator.getRandomUnmatchedCard(_cards);
    if (card == null) return;

    setState(() {
      _hintsRemaining--;
      _score = (_score - _hintCost).clamp(0, 999999);
      card.showHintGlow = true;
      card.isFlipped = true;
    });

    HapticFeedback.mediumImpact();
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          card.isFlipped = false;
          card.showHintGlow = false;
        });
      }
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
    final gridSize = MemoryIconProvider.getGridSize(_difficulty);

    return Scaffold(
      appBar: AppBar(
        title: Text('🧩 Memory Match'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _showDifficultySelector,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildStatsHeader(theme),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize.cols,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) => MemoryCardWidget(
                      card: _cards[index],
                      onTap: () => _onCardTap(index),
                      isDisabled: _isPreviewPhase || _isProcessing,
                    ),
                  ),
                ),
              ),
              _buildControls(theme),
            ],
          ),
          if (_isPreviewPhase && _previewCountdown > 0)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ghi nhớ vị trí các thẻ!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '$_previewCountdown',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(ThemeData theme) {
    final gridSize = MemoryIconProvider.getGridSize(_difficulty);
    final timeRemaining = _timeLimit != null
        ? _timeLimit! - _timeElapsed
        : null;

    return Container(
      padding: EdgeInsets.all(16),
      color: theme.primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('🔥', '$_currentStreak'),
              _buildStatItem('📊', '$_moves'),
              _buildStatItem('💎', '$_score'),
              _buildStatItem('Cặp', '$_pairsFound/${gridSize.pairs}'),
            ],
          ),
          if (timeRemaining != null) ...[
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: _timeElapsed / _timeLimit!,
              backgroundColor: Colors.grey[300],
              color: timeRemaining < 30 ? Colors.red : theme.primaryColor,
              minHeight: 8,
            ),
            SizedBox(height: 4),
            Text(
              '⏱️ ${timeRemaining}s',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: timeRemaining < 30 ? Colors.red : null,
              ),
            ),
          ] else ...[
            SizedBox(height: 4),
            Text('⏱️ ${_timeElapsed}s'),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12)),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.lightbulb_outline),
            label: Text('Hint ($_hintsRemaining)'),
            onPressed: _hintsRemaining > 0 ? _useHint : null,
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh),
            label: Text('Restart'),
            onPressed: () => _startGame(_difficulty),
          ),
        ],
      ),
    );
  }
}
