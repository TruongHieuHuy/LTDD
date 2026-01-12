// lib/screens/games/caro_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/caro_model.dart';
import '../../../widgets/game_widgets/caro_board.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';

class CaroScreen extends StatefulWidget {
  const CaroScreen({Key? key}) : super(key: key);

  @override
  State<CaroScreen> createState() => _CaroScreenState();
}

class _CaroScreenState extends State<CaroScreen> {
  CaroGame? _game;
  int? _selectedRow;
  int? _selectedCol;
  
  // Stats
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isLoading = false;
  bool _isAiThinking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGameModeDialog();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Show game mode selection
  void _showGameModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎮 Chọn chế độ chơi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModeButton(
              '👥 Chơi 2 người',
              'Chơi với bạn bè trên cùng 1 máy',
              Colors.blue,
              () => _showBoardSizeDialog('pvp'),
            ),
            const SizedBox(height: 12),
            _buildModeButton(
              '🤖 Chơi với máy',
              'Thử thách với AI thông minh',
              Colors.purple,
              () => _showDifficultyDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String title, String desc, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
        ),
        onPressed: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// Show difficulty selection (PVE mode)
  void _showDifficultyDialog() {
    Navigator.pop(context); // Close mode dialog
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⚔️ Chọn độ khó'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDifficultyButton('easy', Colors.green, 'Dễ - Máy đánh random'),
            const SizedBox(height: 8),
            _buildDifficultyButton('medium', Colors.orange, 'Trung bình - Minimax'),
            const SizedBox(height: 8),
            _buildDifficultyButton('hard', Colors.red, 'Khó - Alpha-Beta Pruning'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _showGameModeDialog,
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(String difficulty, Color color, String desc) {
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
          _showBoardSizeDialog('pve', difficulty: difficulty);
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

  /// Show board size selection
  void _showBoardSizeDialog(String mode, {String difficulty = 'medium'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('📐 Kích thước bàn cờ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSizeButton(10, mode, difficulty),
            const SizedBox(height: 8),
            _buildSizeButton(15, mode, difficulty),
            const SizedBox(height: 8),
            _buildSizeButton(20, mode, difficulty),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mode == 'pve') {
                _showDifficultyDialog();
              } else {
                _showGameModeDialog();
              }
            },
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeButton(int size, String mode, String difficulty) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          Navigator.pop(context);
          _startNewGame(size: size, mode: mode, difficulty: difficulty);
        },
        child: Text(
          '$size x $size',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Start new game - GỌI API TỪ BACKEND
  void _startNewGame({required int size, required String mode, required String difficulty}) async {
    _timer?.cancel();

    setState(() {
      _isLoading = true;
      _game = null;
    });

    try {
      final game = await ApiService().createCaroGame(
        size: size,
        mode: mode,
        difficulty: difficulty,
      );

      setState(() {
        _game = game;
        _selectedRow = null;
        _selectedCol = null;
        _elapsedSeconds = 0;
        _isLoading = false;
      });

      // Start timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_game != null && !_game!.gameOver) {
          setState(() => _elapsedSeconds++);
        }
      });

      debugPrint('✅ Game created: ${mode.toUpperCase()} - Size: $size');
    } catch (e) {
      debugPrint('❌ Failed to create game: $e');
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tạo game: $e'),
            backgroundColor: Colors.red,
          ),
        );
        
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _showGameModeDialog();
        });
      }
    }
  }

  /// Handle cell tap - Người chơi đánh
  void _onCellTap(int row, int col) async {
    if (_game == null || _game!.gameOver || _isAiThinking) return;
    if (!_game!.isCellEmpty(row, col)) return;

    // PVE: Chỉ cho phép X (người chơi) đánh
    if (_game!.mode == 'pve' && _game!.currentPlayer == 'O') return;

    HapticFeedback.lightImpact();

    // Đánh quân
    await _makeMove(row, col, _game!.currentPlayer);

    // Nếu là PVE và chưa kết thúc, để AI đánh
    if (_game!.mode == 'pve' && !_game!.gameOver) {
      await _aiMove();
    }
  }

  /// Make a move
  Future<void> _makeMove(int row, int col, String player) async {
    // Update board
    final newBoard = _game!.board.map((r) => List<String?>.from(r)).toList();
    newBoard[row][col] = player;

    final newHistory = List<CaroMove>.from(_game!.moveHistory)
      ..add(CaroMove(row: row, col: col, player: player));

    setState(() {
      _game = _game!.copyWith(
        board: newBoard,
        moveHistory: newHistory,
      );
      _selectedRow = row;
      _selectedCol = col;
    });

    // Check winner
    await _checkWinner(row, col, player);
  }

  /// AI move - GỌI API TỪ BACKEND
  Future<void> _aiMove() async {
    setState(() => _isAiThinking = true);

    // Delay nhỏ để UI mượt hơn
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final moveData = await ApiService().getCaroAiMove(
        board: _game!.board,
        size: _game!.size,
        difficulty: _game!.difficulty,
      );

      if (moveData['move'] != null) {
        final move = moveData['move'];
        await _makeMove(
          move['row'] as int,
          move['col'] as int,
          move['player'] as String,
        );
      }
    } catch (e) {
      debugPrint('❌ AI move failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi AI: $e')),
      );
    } finally {
      setState(() => _isAiThinking = false);
    }
  }

  /// Check winner - GỌI API TỪ BACKEND
  Future<void> _checkWinner(int row, int col, String player) async {
    try {
      final result = await ApiService().checkCaroWinner(
        board: _game!.board,
        size: _game!.size,
        lastMove: {'row': row, 'col': col, 'player': player},
      );

      if (result['gameOver'] == true) {
        _timer?.cancel();
        
        setState(() {
          _game = _game!.copyWith(
            winner: result['winner'] as String?,
            gameOver: true,
          );
        });

        HapticFeedback.heavyImpact();

        // Show completion dialog
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _onGameComplete();
        }
      } else {
        // Switch player
        final nextPlayer = _game!.currentPlayer == 'X' ? 'O' : 'X';
        setState(() {
          _game = _game!.copyWith(currentPlayer: nextPlayer);
        });
      }
    } catch (e) {
      debugPrint('❌ Check winner failed: $e');
    }
  }

  /// Game complete
  void _onGameComplete() async {
    final winner = _game!.winner;
    final isDraw = winner == null;

    // Calculate score - GỌI API TỪ BACKEND
    int score = 0;
    if (!isDraw) {
      try {
        score = await ApiService().calculateCaroScore(
          mode: _game!.mode,
          difficulty: _game!.difficulty,
          timeInSeconds: _elapsedSeconds,
          winner: winner,
          totalMoves: _game!.getTotalMoves(),
        );
        
        debugPrint('✅ Score calculated: $score');
      } catch (e) {
        debugPrint('❌ Failed to calculate score: $e');
      }
    }

    // Save to backend
    final authProvider = context.read<AuthProvider>();
    bool savedToBackend = false;
    
    if (authProvider.isLoggedIn && !isDraw) {
      try {
        await ApiService().saveScore(
          gameType: 'caro',
          score: score,
          difficulty: _game!.difficulty.toLowerCase(),
          attempts: _game!.getTotalMoves(),
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
      _showCompletionDialog(winner, isDraw, score, savedToBackend);
    }
  }

  /// Show completion dialog
  void _showCompletionDialog(String? winner, bool isDraw, int score, bool savedToBackend) {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;

    String title;
    IconData icon;
    Color iconColor;

    if (isDraw) {
      title = 'Hòa!';
      icon = Icons.handshake;
      iconColor = Colors.orange;
    } else if (_game!.mode == 'pve' && winner == 'X') {
      title = 'Bạn thắng! 🎉';
      icon = Icons.emoji_events;
      iconColor = Colors.amber;
    } else if (_game!.mode == 'pve' && winner == 'O') {
      title = 'AI thắng! 🤖';
      icon = Icons.sentiment_dissatisfied;
      iconColor = Colors.blue;
    } else {
      title = '$winner thắng!';
      icon = Icons.emoji_events;
      iconColor = Colors.amber;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isDraw) _buildStatRow('Điểm', '$score 💎'),
            _buildStatRow('Thời gian', '$minutes:${seconds.toString().padLeft(2, '0')}'),
            _buildStatRow('Chế độ', _game!.mode == 'pvp' ? '2 người' : 'Với máy'),
            if (_game!.mode == 'pve') 
              _buildStatRow('Độ khó', _game!.difficulty.toUpperCase()),
            _buildStatRow('Số nước', '${_game!.getTotalMoves()}'),
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
              _showGameModeDialog();
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

  /// Undo last move
  void _undoMove() {
    if (_game == null || _game!.moveHistory.isEmpty || _isAiThinking) return;
    if (_game!.gameOver) return;

    final movesToUndo = _game!.mode == 'pve' ? 2 : 1; // PVE: Undo 2 moves (player + AI)
    
    if (_game!.moveHistory.length < movesToUndo) return;

    HapticFeedback.mediumImpact();

    final newHistory = List<CaroMove>.from(_game!.moveHistory);
    final newBoard = _game!.board.map((r) => List<String?>.from(r)).toList();

    for (int i = 0; i < movesToUndo; i++) {
      final lastMove = newHistory.removeLast();
      newBoard[lastMove.row][lastMove.col] = null;
    }

    setState(() {
      _game = _game!.copyWith(
        board: newBoard,
        moveHistory: newHistory,
        currentPlayer: 'X', // Always back to player's turn
        winner: null,
        gameOver: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tạo game...'),
            ],
          ),
        ),
      );
    }

    if (_game == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;

    return Scaffold(
      appBar: AppBar(
        title: Text(_game!.mode == 'pvp' ? '⭕ Caro - 2 người' : '⭕ Caro - Với máy'),
        actions: [
          // Timer
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$minutes:${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // New game
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showGameModeDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Lượt',
                  _game!.currentPlayer,
                  _game!.currentPlayer == 'X' ? Colors.blue : Colors.red,
                ),
                _buildStatItem('Số nước', '${_game!.getTotalMoves()}', Colors.green),
                _buildStatItem('Kích thước', '${_game!.size}x${_game!.size}', Colors.purple),
              ],
            ),
          ),

          if (_isAiThinking)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('🤖 AI đang suy nghĩ...'),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Board
          Expanded(
            child: CaroBoard(
              game: _game!,
              selectedRow: _selectedRow,
              selectedCol: _selectedCol,
              onCellTap: _onCellTap,
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _game!.moveHistory.isEmpty || _isAiThinking || _game!.gameOver
                      ? null
                      : _undoMove,
                  icon: const Icon(Icons.undo),
                  label: const Text('Hoàn tác'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showGameModeDialog,
                  icon: const Icon(Icons.flag),
                  label: const Text('Game mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}