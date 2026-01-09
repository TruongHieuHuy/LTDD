// lib/screens/games/puzzle_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/puzzle_model.dart';
import '../../widgets/game_widgets/puzzle_board.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/gaming_theme.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({Key? key}) : super(key: key);

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  PuzzleGame? _game;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isCompleted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDifficultyDialog();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Show difficulty selection
  void _showDifficultyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🧩 Chọn độ khó'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDifficultyButton('easy', Colors.green, '3x3 (8 mảnh)', 3),
            const SizedBox(height: 8),
            _buildDifficultyButton('medium', Colors.orange, '4x4 (15 mảnh)', 4),
            const SizedBox(height: 8),
            _buildDifficultyButton('hard', Colors.red, '5x5 (24 mảnh)', 5),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    String difficulty,
    Color color,
    String desc,
    int gridSize,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          Navigator.pop(context);
          _startNewGame(difficulty, gridSize);
        },
        child: Column(
          children: [
            Text(
              difficulty.toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(desc, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// Start new game - GỌI API TỪ BACKEND
  void _startNewGame(String difficulty, int gridSize) async {
    _timer?.cancel();

    setState(() {
      _isLoading = true;
      _game = null;
    });

    try {
      // GỌI API TỪ BACKEND
      final game = await ApiService().generatePuzzle(
        difficulty: difficulty,
        gridSize: gridSize,
      );

      setState(() {
        _game = game;
        _elapsedSeconds = 0;
        _isCompleted = false;
        _isLoading = false;
      });
      
      _startTimer();
      // DEBUG: In ra URL ảnh
      debugPrint('✅ Puzzle game generated from backend successfully!');
      debugPrint('📷 Image URL: ${game.imageUrl}');
      debugPrint('🧩 Tile paths: ${game.tilePaths}');
    } catch (e) {
      debugPrint('❌ Failed to generate puzzle game: $e');

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tạo game: $e'),
            backgroundColor: Colors.red,
          ),
        );

        // Show dialog again
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _showDifficultyDialog();
        });
      }
    }
  }

  /// Move tile
  void _moveTile(int index) {
    if (_game == null || _isCompleted) return;

    if (!_game!.canMoveTile(index)) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _game = _game!.moveTile(index);

      // Check completion
      if (_game!.isCompleted()) {
        _onGameComplete();
      }
    });
  }

  /// Show preview image
  void _showPreviewImage() {
    if (_game == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Ảnh gốc'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Image.network(
                _game!.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Game complete
  void _onGameComplete() async {
    _timer?.cancel();
    setState(() => _isCompleted = true);

    HapticFeedback.heavyImpact();

    // Calculate score - GỌI API TỪ BACKEND
    int score = 0;
    try {
      score = await ApiService().calculatePuzzleScore(
        difficulty: _game!.difficulty,
        timeInSeconds: _elapsedSeconds,
        moves: _game!.moves,
        gridSize: _game!.gridSize,
      );

      debugPrint('✅ Score calculated from backend: $score');
    } catch (e) {
      debugPrint('❌ Failed to calculate score: $e');
      // Fallback: Calculate locally
      score = _calculateScoreLocally();
    }

    // Save to backend
    final authProvider = context.read<AuthProvider>();
    bool savedToBackend = false;

    if (authProvider.isLoggedIn) {
      try {
        await ApiService().saveScore(
          gameType: 'puzzle',
          score: score,
          difficulty: _game!.difficulty.toLowerCase(),
          attempts: _game!.moves,
          timeSpent: _elapsedSeconds,
        );
        savedToBackend = true;
        debugPrint('✅ Score saved to backend!');
      } catch (e) {
        debugPrint('❌ Failed to save score: $e');
      }
    }

    // Show completion dialog
    if (mounted) {
      _showCompletionDialog(score, savedToBackend);
    }
  }

  /// Fallback: Calculate score locally
  int _calculateScoreLocally() {
    final baseScores = {'easy': 1500, 'medium': 3000, 'hard': 5000};
    final targetTimes = {'easy': 120, 'medium': 300, 'hard': 600};
    final targetMoves = {'easy': 50, 'medium': 100, 'hard': 200};

    final baseScore = baseScores[_game!.difficulty.toLowerCase()] ?? 1500;
    final targetTime = targetTimes[_game!.difficulty.toLowerCase()] ?? 120;
    final targetMove = targetMoves[_game!.difficulty.toLowerCase()] ?? 50;

    // Time bonus/penalty
    final timeDiff = targetTime - _elapsedSeconds;
    final maxTimeBonus = (baseScore * 0.3).floor();
    final timeBonus = (timeDiff * 5).clamp(-maxTimeBonus, maxTimeBonus);

    // Move penalty
    final moveDiff = _game!.moves - targetMove;
    final movePenalty = moveDiff > 0 ? moveDiff * 10 : 0;

    final finalScore = (baseScore + timeBonus - movePenalty).clamp(0, 99999);

    return finalScore.toInt();
  }

  /// Show completion dialog
  void _showCompletionDialog(int score, bool savedToBackend) {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Hoàn thành!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Điểm', '$score 💎'),
            _buildStatRow(
              'Thời gian',
              '$minutes:${seconds.toString().padLeft(2, '0')}',
            ),
            _buildStatRow('Độ khó', _game!.difficulty.toUpperCase()),
            _buildStatRow('Số bước', '${_game!.moves}'),
            if (savedToBackend) ...[
              const Divider(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.cloud_done, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Text('Đã lưu lên server', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDifficultyDialog();
            },
            child: const Text('Chơi lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: GamingTheme.primaryDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: GamingTheme.primaryAccent),
              const SizedBox(height: 16),
              Text(
                'Đang tạo game từ server...',
                style: GamingTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    if (_game == null) {
      return Scaffold(
        backgroundColor: GamingTheme.primaryDark,
        body: Center(
          child: CircularProgressIndicator(color: GamingTheme.primaryAccent),
        ),
      );
    }

    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;

    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: GamingTheme.surfaceDark,
        title: Text('🧩 Xếp hình', style: GamingTheme.h2),
        actions: [
          // Timer
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: GamingTheme.primaryAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GamingTheme.primaryAccent),
              ),
              child: Text(
                '$minutes:${seconds.toString().padLeft(2, '0')}',
                style: GamingTheme.scoreDisplay.copyWith(
                  fontSize: 18,
                  color: GamingTheme.primaryAccent,
                ),
              ),
            ),
          ),
          // Preview image
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _showPreviewImage,
            tooltip: 'Xem ảnh gốc',
          ),
          // New game
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showDifficultyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GamingTheme.surfaceDark,
              border: Border(
                bottom: BorderSide(color: GamingTheme.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Độ khó',
                  _game!.difficulty.toUpperCase(),
                  GamingTheme.primaryAccent,
                ),
                _buildStatItem('Bước đi', '${_game!.moves}', GamingTheme.mediumOrange),
                _buildStatItem(
                  'Đã đúng',
                  '${_game!.correctTilesCount}/${_game!.totalTiles}',
                  GamingTheme.easyGreen,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Board
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PuzzleBoard(
                  game: _game!,
                  onTileTap: _moveTile,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GamingTheme.bodySmall.copyWith(
            color: GamingTheme.textSecondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GamingTheme.h3.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  void _startTimer() {
  _timer?.cancel(); // Đảm bảo không có timer nào đang chạy chồng lên nhau
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (mounted) {
      setState(() {
        _elapsedSeconds++;
      });
    }
  });
}


}