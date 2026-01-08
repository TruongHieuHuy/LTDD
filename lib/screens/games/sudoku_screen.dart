import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/sudoku_model.dart';
import '../../widgets/game_widgets/sudoku_board.dart';
import '../../widgets/game_widgets/sudoku_controls.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({Key? key}) : super(key: key);

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  SudokuGame? _game;
  int? _selectedRow;
  int? _selectedCol;
  int? _selectedNumber;
  
  // Stats
  int _hintsUsed = 0;
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
        title: const Text('Chọn độ khó'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDifficultyButton('easy', Colors.green, '35 ô trống'),
            const SizedBox(height: 8),
            _buildDifficultyButton('medium', Colors.orange, '45 ô trống'),
            const SizedBox(height: 8),
            _buildDifficultyButton('hard', Colors.red, '55 ô trống'),
          ],
        ),
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
          _startNewGame(difficulty);
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
  void _startNewGame(String difficulty) async {
    _timer?.cancel();

    setState(() {
      _isLoading = true;
      _game = null;
    });

    try {
      // GỌI API TỪ BACKEND
      final game = await ApiService().generateSudoku(difficulty: difficulty);

      setState(() {
        _game = game;
        _selectedRow = null;
        _selectedCol = null;
        _selectedNumber = null;
        _hintsUsed = 0;
        _elapsedSeconds = 0;
        _isCompleted = false;
        _isLoading = false;
      });

      // Start timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isCompleted) {
          setState(() => _elapsedSeconds++);
        }
      });

      debugPrint('✅ Game generated from backend successfully!');
    } catch (e) {
      debugPrint('❌ Failed to generate game: $e');
      
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

  /// Select cell
  void _selectCell(int row, int col) {
    if (_game!.isInitialCell(row, col)) return;

    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  /// Fill number
  void _fillNumber(int number) {
    if (_selectedRow == null || _selectedCol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chọn một ô trước!')),
      );
      return;
    }

    final index = _selectedRow! * 9 + _selectedCol!;
    if (_game!.puzzle[index] != 0) return;

    HapticFeedback.lightImpact();

    setState(() {
      _selectedNumber = number;
      final newState = List<int>.from(_game!.currentState);
      newState[index] = number;
      _game = _game!.copyWith(currentState: newState);

      // Check completion
      if (_game!.isCompleted()) {
        _onGameComplete();
      }
    });
  }

  /// Clear cell
  void _clearCell() {
    if (_selectedRow == null || _selectedCol == null) return;

    final index = _selectedRow! * 9 + _selectedCol!;
    if (_game!.puzzle[index] != 0) return;

    setState(() {
      final newState = List<int>.from(_game!.currentState);
      newState[index] = 0;
      _game = _game!.copyWith(currentState: newState);
    });
  }

  /// Get hint - CÓ THỂ GỌI API TỪ BACKEND (OPTIONAL)
  void _getHint() async {
    if (_game == null) return;

    try {
      // Option 1: Gọi API từ backend
      final hintData = await ApiService().getSudokuHint(
        currentState: _game!.currentState,
        solution: _game!.solution,
      );

      final index = hintData['index'] as int?;
      final value = hintData['value'] as int?;

      if (index == null || value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không còn ô trống!')),
        );
        return;
      }

      final row = index ~/ 9;
      final col = index % 9;

      HapticFeedback.mediumImpact();

      setState(() {
        _hintsUsed++;
        _selectedRow = row;
        _selectedCol = col;
        final newState = List<int>.from(_game!.currentState);
        newState[index] = value;
        _game = _game!.copyWith(currentState: newState);

        // Check completion
        if (_game!.isCompleted()) {
          _onGameComplete();
        }
      });
    } catch (e) {
      debugPrint('❌ Failed to get hint: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lấy gợi ý: $e')),
      );
    }
  }

  /// Game complete
  void _onGameComplete() async {
    _timer?.cancel();
    setState(() => _isCompleted = true);

    HapticFeedback.heavyImpact();

    // Calculate score - CÓ THỂ GỌI API TỪ BACKEND
    int score = 0;
    try {
      score = await ApiService().calculateSudokuScore(
        difficulty: _game!.difficulty,
        timeInSeconds: _elapsedSeconds,
        hintsUsed: _hintsUsed,
        mistakes: _game!.getTotalMistakes(),
      );
      
      debugPrint('✅ Score calculated from backend: $score');
    } catch (e) {
      debugPrint('❌ Failed to calculate score: $e');
      // Fallback: Calculate locally nếu BE fail
      score = _calculateScoreLocally();
    }

    // Save to backend
    final authProvider = context.read<AuthProvider>();
    bool savedToBackend = false;
    
    if (authProvider.isLoggedIn) {
      try {
        await ApiService().saveScore(
          gameType: 'sudoku',
          score: score,
          difficulty: _game!.difficulty.toLowerCase(),
          attempts: _hintsUsed,
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

  /// Fallback: Calculate score locally nếu API fail
  int _calculateScoreLocally() {
    final baseScores = {'easy': 2000, 'medium': 4000, 'hard': 6000};
    final targetTimes = {'easy': 300, 'medium': 600, 'hard': 900};
    
    final baseScore = baseScores[_game!.difficulty.toLowerCase()] ?? 2000;
    final targetTime = targetTimes[_game!.difficulty.toLowerCase()] ?? 300;
    
    final timeDiff = targetTime - _elapsedSeconds;
    final maxBonus = (baseScore * 0.5).floor();
    final timeBonus = (timeDiff * 2).clamp(-maxBonus, maxBonus);
    
    final hintPenalty = _hintsUsed * 50;
    final mistakePenalty = _game!.getTotalMistakes() * 50;
    
    final finalScore = (baseScore + timeBonus - hintPenalty - mistakePenalty).clamp(0, 99999);
    
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
            _buildStatRow('Thời gian', '$minutes:${seconds.toString().padLeft(2, '0')}'),
            _buildStatRow('Độ khó', _game!.difficulty.toUpperCase()),
            _buildStatRow('Gợi ý dùng', '$_hintsUsed'),
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
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tạo game từ server...'),
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
        title: const Text('🔢 Sudoku'),
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
            onPressed: _showDifficultyDialog,
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
                _buildStatItem('Độ khó', _game!.difficulty.toUpperCase(), Colors.blue),
                _buildStatItem('Gợi ý', '$_hintsUsed', Colors.green),
                _buildStatItem(
                  'Đã điền',
                  '${_game!.getFilledCount()}/81',
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Board
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SudokuBoard(
                  game: _game!,
                  selectedRow: _selectedRow,
                  selectedCol: _selectedCol,
                  selectedNumber: _selectedNumber,
                  onCellTap: _selectCell,
                ),
              ),
            ),
          ),

          // Controls
          SudokuControls(
            selectedNumber: _selectedNumber,
            onNumberTap: _fillNumber,
            onClear: _clearCell,
            onHint: _getHint,
            hintsUsed: _hintsUsed,
            canClear: _selectedRow != null && _selectedCol != null,
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