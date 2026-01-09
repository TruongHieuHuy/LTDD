import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/rubik_cube_model.dart';
import '../../config/gaming_theme.dart';
import '../../widgets/game_widgets/rubik_cube_3d_widget.dart';
import '../../providers/game_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/game_audio_service.dart';
import 'dart:async';
import 'dart:math' as math;

class RubikCubeGameScreen extends StatefulWidget {
  const RubikCubeGameScreen({super.key});

  @override
  State<RubikCubeGameScreen> createState() => _RubikCubeGameScreenState();
}

class _RubikCubeGameScreenState extends State<RubikCubeGameScreen>
    with TickerProviderStateMixin {
  late RubikCubeModel _cube;
  late AnimationController _celebrationController;
  bool _showCelebration = false;
  Timer? _celebrationTimer;
  final GlobalKey<RubikCube3DWidgetState> _cube3DKey = GlobalKey();

  // Auto operations
  bool _isAutoShuffling = false;
  bool _isAutoSolving = false;
  List<String> _shuffleHistory = [];

  // Solving progress
  int _solveStep = 0;
  int _totalSolveSteps = 0;

  @override
  void initState() {
    super.initState();
    _cube = RubikCubeModel();
    _cube.addListener(_onCubeChanged);
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _cube.removeListener(_onCubeChanged);
    _cube.dispose();
    _celebrationController.dispose();
    _celebrationTimer?.cancel();
    _stopAutoOperations();
    super.dispose();
  }

  void _onCubeChanged() {
    if (_cube.isSolved && !_showCelebration) {
      _showWinCelebration();
      _saveGameResult();
    }
  }

  void _showWinCelebration() {
    setState(() {
      _showCelebration = true;
    });
    _celebrationController.forward();
    GameAudioService.playVictory();

    _celebrationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showCelebration = false;
        });
        _celebrationController.reset();
      }
    });
  }

  Future<void> _saveGameResult() async {
    final gameProvider = context.read<GameProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLoggedIn) {
      try {
        await gameProvider.saveGameScore(
          gameType: 'RUBIK_CUBE',
          score: _cube.moveCount,
          difficulty: 'normal',
          attempts: 1,
          timeSpent: 0,
        );
      } catch (e) {
        debugPrint('Error saving Rubik Cube score: $e');
      }
    }
  }

  // Tự Xáo trộn
  Future<void> _autoShuffle() async {
    if (_isAutoShuffling || _isAutoSolving) return;

    setState(() {
      _isAutoShuffling = true;
      _shuffleHistory.clear();
    });

    final moves = [
      'R',
      'R\'',
      'L',
      'L\'',
      'U',
      'U\'',
      'D',
      'D\'',
      'F',
      'F\'',
      'B',
      'B\'',
    ];
    final random = math.Random();
    final shuffleCount = 20 + random.nextInt(11);

    for (int i = 0; i < shuffleCount; i++) {
      if (!_isAutoShuffling || !mounted) break;

      final move = moves[random.nextInt(moves.length)];
      _shuffleHistory.add(move);
      await _executeMove(move);
      await Future.delayed(const Duration(milliseconds: 350));
    }

    if (mounted) {
      setState(() {
        _isAutoShuffling = false;
      });
    }
  }

  // Máy Giải - Sử dụng thuật toán lặp lại cho đến khi giải xong
  Future<void> _autoSolve() async {
    if (_isAutoSolving || _isAutoShuffling) return;

    if (!mounted) return;

    setState(() {
      _isAutoSolving = true;
      _solveStep = 0;
      _totalSolveSteps = 0;
    });

    try {
      if (_shuffleHistory.isNotEmpty) {
        // Undo chính xác nếu có lịch sử
        await _reverseShuffleHistory();
      } else {
        // Sử dụng thuật toán lặp cho đến khi giải xong
        await _repeatSolveUntilComplete();
      }
    } catch (e) {
      debugPrint('Error in auto solve: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAutoSolving = false;
          _solveStep = 0;
          _totalSolveSteps = 0;
        });
      }
    }
  }

  // Lặp lại thuật toán cho đến khi giải xong
  Future<void> _repeatSolveUntilComplete() async {
    if (!mounted) return;

    int maxAttempts = 10; // Tối đa 10 lần lặp
    int attempt = 0;

    while (!_cube.isSolved &&
        attempt < maxAttempts &&
        _isAutoSolving &&
        mounted) {
      attempt++;
      debugPrint('Solve attempt: $attempt');

      // Lấy sequence giải
      final sequence = _getCompleteSolveSequence();

      if (mounted) {
        setState(() {
          _totalSolveSteps = sequence.length * (maxAttempts - attempt + 1);
        });
      }

      // Thực hiện từng bước
      for (int i = 0; i < sequence.length; i++) {
        if (!_isAutoSolving || !mounted) return;

        // Kiểm tra đã giải xong chưa
        if (_cube.isSolved) {
          debugPrint('Cube solved at step $i of attempt $attempt');
          return;
        }

        if (mounted) {
          setState(() {
            _solveStep = (attempt - 1) * sequence.length + i + 1;
          });
        }

        final move = sequence[i];
        await _executeMoveDirectly(move);
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Delay giữa các lần thử
      if (!_cube.isSolved && attempt < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (!_cube.isSolved) {
      debugPrint('Could not solve cube after $attempt attempts');
    }
  }

  // Thực hiện move trực tiếp không qua widget
  Future<void> _executeMoveDirectly(String move) async {
    if (!mounted) return;

    // Gọi qua widget
    switch (move) {
      case 'R':
        _cube3DKey.currentState?.rotateFace('right', true);
        break;
      case 'R\'':
        _cube3DKey.currentState?.rotateFace('right', false);
        break;
      case 'L':
        _cube3DKey.currentState?.rotateFace('left', true);
        break;
      case 'L\'':
        _cube3DKey.currentState?.rotateFace('left', false);
        break;
      case 'U':
        _cube3DKey.currentState?.rotateFace('up', true);
        break;
      case 'U\'':
        _cube3DKey.currentState?.rotateFace('up', false);
        break;
      case 'D':
        _cube3DKey.currentState?.rotateFace('down', true);
        break;
      case 'D\'':
        _cube3DKey.currentState?.rotateFace('down', false);
        break;
      case 'F':
        _cube3DKey.currentState?.rotateFace('front', true);
        break;
      case 'F\'':
        _cube3DKey.currentState?.rotateFace('front', false);
        break;
      case 'B':
        _cube3DKey.currentState?.rotateFace('back', true);
        break;
      case 'B\'':
        _cube3DKey.currentState?.rotateFace('back', false);
        break;
    }

    // Đợi animation hoàn thành
    await Future.delayed(const Duration(milliseconds: 150));
  }

  // Sequence giải hoàn chỉnh và đơn giản
  List<String> _getCompleteSolveSequence() {
    return [
      // White Cross - Thập tự trắng dưới
      'F', 'F', 'U', 'R', 'U\'', 'R\'', 'F\'', 'F',
      'D', 'L', 'D\'', 'L\'',
      'D\'', 'B', 'D', 'B\'',

      // White Corners - 4 góc trắng
      'R', 'U', 'R\'', 'U\'', 'R', 'U', 'R\'', 'U\'',
      'U', 'R', 'U', 'R\'', 'U\'', 'R', 'U', 'R\'', 'U\'',
      'U', 'R', 'U', 'R\'', 'U\'', 'R', 'U', 'R\'', 'U\'',
      'U', 'R', 'U', 'R\'', 'U\'', 'R', 'U', 'R\'', 'U\'',

      // Middle Layer - Tầng giữa
      'U', 'R', 'U\'', 'R\'', 'U\'', 'F\'', 'U', 'F',
      'U', 'U',
      'U\'', 'L\'', 'U', 'L', 'U', 'F', 'U\'', 'F\'',
      'U', 'U',

      // Yellow Cross - Thập tự vàng
      'F', 'R', 'U', 'R\'', 'U\'', 'F\'',
      'U',
      'F', 'R', 'U', 'R\'', 'U\'', 'F\'',

      // Yellow Face - Mặt vàng hoàn chỉnh
      'R', 'U', 'R\'', 'U', 'R', 'U', 'U', 'R\'',
      'U',
      'R', 'U', 'R\'', 'U', 'R', 'U', 'U', 'R\'',

      // Position Yellow Corners - Đặt góc vàng
      'U', 'R', 'U\'', 'L\'', 'U', 'R\'', 'U\'', 'L',
      'U', 'U',

      // Orient Yellow Corners - Xoay góc vàng
      'R\'', 'D\'', 'R', 'D', 'R\'', 'D\'', 'R', 'D',
      'U\'',
      'R\'', 'D\'', 'R', 'D', 'R\'', 'D\'', 'R', 'D',

      // Final positioning
      'U', 'R', 'U\'', 'R\'', 'U\'', 'R', 'U', 'R\'',
      'U', 'U',
      'R', 'U', 'R\'', 'U', 'R', 'U', 'U', 'R\'',
    ];
  }

  // Undo lịch sử xáo trộn
  Future<void> _reverseShuffleHistory() async {
    if (!mounted) return;

    final reversedHistory = _shuffleHistory.reversed.toList();

    if (mounted) {
      setState(() {
        _totalSolveSteps = reversedHistory.length;
      });
    }

    for (int i = 0; i < reversedHistory.length; i++) {
      if (!_isAutoSolving || !mounted) break;

      if (mounted) {
        setState(() {
          _solveStep = i + 1;
        });
      }

      await _executeMoveDirectly(_reverseMove(reversedHistory[i]));
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  String _reverseMove(String move) {
    if (move.endsWith('\'')) {
      return move.substring(0, move.length - 1);
    } else if (move.endsWith('2')) {
      return move;
    } else {
      return '$move\'';
    }
  }

  Future<void> _executeMove(String move) async {
    if (!mounted) return;

    switch (move) {
      case 'R':
        _cube3DKey.currentState?.rotateFace('right', true);
        break;
      case 'R\'':
        _cube3DKey.currentState?.rotateFace('right', false);
        break;
      case 'L':
        _cube3DKey.currentState?.rotateFace('left', true);
        break;
      case 'L\'':
        _cube3DKey.currentState?.rotateFace('left', false);
        break;
      case 'U':
        _cube3DKey.currentState?.rotateFace('up', true);
        break;
      case 'U\'':
        _cube3DKey.currentState?.rotateFace('up', false);
        break;
      case 'D':
        _cube3DKey.currentState?.rotateFace('down', true);
        break;
      case 'D\'':
        _cube3DKey.currentState?.rotateFace('down', false);
        break;
      case 'F':
        _cube3DKey.currentState?.rotateFace('front', true);
        break;
      case 'F\'':
        _cube3DKey.currentState?.rotateFace('front', false);
        break;
      case 'B':
        _cube3DKey.currentState?.rotateFace('back', true);
        break;
      case 'B\'':
        _cube3DKey.currentState?.rotateFace('back', false);
        break;
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _stopAutoOperations() {
    setState(() {
      _isAutoShuffling = false;
      _isAutoSolving = false;
      _solveStep = 0;
      _totalSolveSteps = 0;
    });
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GamingTheme.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color ?? GamingTheme.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? GamingTheme.primaryAccent, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GamingTheme.bodyMedium.copyWith(
              color: color ?? GamingTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: GamingTheme.bodySmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildNotationButton(
    String notation,
    Color color,
    VoidCallback onPressed,
  ) {
    final isLightColor = color == Colors.white || color == Colors.white70;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: (_isAutoShuffling || _isAutoSolving) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: isLightColor ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            minimumSize: const Size(0, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 3,
          ),
          child: Text(
            notation,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoButton(
    String icon,
    Color color,
    String text,
    VoidCallback onPressed,
    bool isActive,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          onPressed: isActive ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            minimumSize: const Size(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: isActive ? 2 : 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isActive)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _cube,
      child: Scaffold(
        backgroundColor: GamingTheme.primaryDark,
        appBar: AppBar(
          title: Text(
            '🎲 Rubik Cube',
            style: GamingTheme.h2.copyWith(color: GamingTheme.textPrimary),
          ),
          backgroundColor: GamingTheme.surfaceDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: GamingTheme.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<RubikCubeModel>(
          builder: (context, cube, child) {
            return Container(
              decoration: BoxDecoration(gradient: GamingTheme.surfaceGradient),
              child: SafeArea(
                child: Column(
                  children: [
                    // Status banner
                    if (cube.isSolved)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.celebration,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '🎉 Rubik Cube Đã Được Giải! 🎉',
                              style: GamingTheme.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        color: GamingTheme.surfaceDark,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              'Số lần xoay',
                              '${cube.moveCount}',
                              Icons.refresh,
                            ),
                            if (_isAutoSolving && _totalSolveSteps > 0)
                              _buildStatCard(
                                'Tiến độ',
                                '$_solveStep/$_totalSolveSteps',
                                Icons.analytics,
                                color: Colors.blue,
                              )
                            else
                              _buildStatCard(
                                'Trạng thái',
                                cube.isSolved ? 'Đã giải' : 'Đang giải',
                                cube.isSolved ? Icons.check_circle : Icons.sync,
                                color: cube.isSolved
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                          ],
                        ),
                      ),

                    // Cube display
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RubikCube3DWidget(
                              key: _cube3DKey,
                              cube: cube,
                              size: 250,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isAutoSolving
                                  ? 'Đang giải tự động...'
                                  : _isAutoShuffling
                                  ? 'Đang xáo trộn...'
                                  : 'Vuốt để xoay cube',
                              style: GamingTheme.bodySmall.copyWith(
                                color: GamingTheme.textSecondary,
                                fontWeight: _isAutoSolving || _isAutoShuffling
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Control panel
                    Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: GamingTheme.surfaceDark,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Công thức giải
                            Text(
                              '🎮 Công Thức Giải Rubik',
                              style: GamingTheme.bodyMedium.copyWith(
                                color: GamingTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '(R: Phải, L: Trái, U: Trên, D: Dưới, F: Trước, B: Sau)',
                              style: GamingTheme.bodySmall.copyWith(
                                color: GamingTheme.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '(M: Giữa-X, E: Giữa-Y, S: Giữa-Z)',
                              style: GamingTheme.bodySmall.copyWith(
                                color: GamingTheme.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Các hàng nút notation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildNotationButton('R', Colors.blue, () {
                                  _cube3DKey.currentState?.rotateFace(
                                    'right',
                                    true,
                                  );
                                  GameAudioService.playClick();
                                }),
                                _buildNotationButton(
                                  'R\'',
                                  Colors.blue[300]!,
                                  () {
                                    _cube3DKey.currentState?.rotateFace(
                                      'right',
                                      false,
                                    );
                                    GameAudioService.playClick();
                                  },
                                ),
                                _buildNotationButton('L', Colors.green, () {
                                  _cube3DKey.currentState?.rotateFace(
                                    'left',
                                    true,
                                  );
                                  GameAudioService.playClick();
                                }),
                                _buildNotationButton(
                                  'L\'',
                                  Colors.green[300]!,
                                  () {
                                    _cube3DKey.currentState?.rotateFace(
                                      'left',
                                      false,
                                    );
                                    GameAudioService.playClick();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildNotationButton('U', Colors.red, () {
                                  _cube3DKey.currentState?.rotateFace(
                                    'up',
                                    true,
                                  );
                                  GameAudioService.playClick();
                                }),
                                _buildNotationButton(
                                  'U\'',
                                  Colors.red[300]!,
                                  () {
                                    _cube3DKey.currentState?.rotateFace(
                                      'up',
                                      false,
                                    );
                                    GameAudioService.playClick();
                                  },
                                ),
                                _buildNotationButton('D', Colors.orange, () {
                                  _cube3DKey.currentState?.rotateFace(
                                    'down',
                                    true,
                                  );
                                  GameAudioService.playClick();
                                }),
                                _buildNotationButton(
                                  'D\'',
                                  Colors.orange[300]!,
                                  () {
                                    _cube3DKey.currentState?.rotateFace(
                                      'down',
                                      false,
                                    );
                                    GameAudioService.playClick();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildNotationButton('F', Colors.white, () {
                                  _cube3DKey.currentState?.rotateFace(
                                    'front',
                                    true,
                                  );
                                  GameAudioService.playClick();
                                }),
                                _buildNotationButton('F\'', Colors.white70, () {
                                  _cube3DKey.currentState?.rotateFace(
                                    'front',
                                    false,
                                  );
                                  GameAudioService.playClick();
                                }),
                                _buildNotationButton('B', Colors.yellow, () {
                                  _cube3DKey.currentState?.rotateFace(
                                    'back',
                                    true,
                                  );
                                  GameAudioService.playClick();
                                }),
                                _buildNotationButton(
                                  'B\'',
                                  Colors.yellow[300]!,
                                  () {
                                    _cube3DKey.currentState?.rotateFace(
                                      'back',
                                      false,
                                    );
                                    GameAudioService.playClick();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildNotationButton('M', Colors.teal, () {
                                      _cube3DKey.currentState?.rotateFace(
                                        'middle_x',
                                        true,
                                      );
                                      GameAudioService.playClick();
                                    }),
                                    _buildNotationButton(
                                      'M\'',
                                      Colors.teal[300]!,
                                      () {
                                        _cube3DKey.currentState?.rotateFace(
                                          'middle_x',
                                          false,
                                        );
                                        GameAudioService.playClick();
                                      },
                                    ),
                                    _buildNotationButton(
                                      'E',
                                      Colors.purple,
                                      () {
                                        _cube3DKey.currentState?.rotateFace(
                                          'middle_y',
                                          true,
                                        );
                                        GameAudioService.playClick();
                                      },
                                    ),
                                    _buildNotationButton(
                                      'E\'',
                                      Colors.purple[300]!,
                                      () {
                                        _cube3DKey.currentState?.rotateFace(
                                          'middle_y',
                                          false,
                                        );
                                        GameAudioService.playClick();
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildNotationButton(
                                      'S',
                                      Colors.indigo,
                                      () {
                                        _cube3DKey.currentState?.rotateFace(
                                          'middle_z',
                                          true,
                                        );
                                        GameAudioService.playClick();
                                      },
                                    ),
                                    _buildNotationButton(
                                      'S\'',
                                      Colors.indigo[300]!,
                                      () {
                                        _cube3DKey.currentState?.rotateFace(
                                          'middle_z',
                                          false,
                                        );
                                        GameAudioService.playClick();
                                      },
                                    ),
                                    const Expanded(child: SizedBox()),
                                    const Expanded(child: SizedBox()),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Chức năng tự động
                            Text(
                              '🤖 Chức Năng Tự Động',
                              style: GamingTheme.bodyMedium.copyWith(
                                color: GamingTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildAutoButton(
                                  '🎲',
                                  _isAutoShuffling
                                      ? Colors.grey
                                      : Colors.deepOrange,
                                  _isAutoShuffling ? 'Đang xáo...' : 'Tự Xáo',
                                  _autoShuffle,
                                  _isAutoShuffling,
                                ),
                                _buildAutoButton(
                                  '🧠',
                                  _isAutoSolving ? Colors.grey : Colors.green,
                                  _isAutoSolving ? 'Đang giải...' : 'Máy Giải',
                                  _autoSolve,
                                  _isAutoSolving,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Dừng và Reset
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (_isAutoShuffling || _isAutoSolving)
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _stopAutoOperations,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.stop, size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            'Dừng',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (_isAutoShuffling || _isAutoSolving)
                                  const SizedBox(width: 6),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        (_isAutoShuffling || _isAutoSolving)
                                        ? null
                                        : () {
                                            cube.reset();
                                            _shuffleHistory.clear();
                                            GameAudioService.playClick();
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.refresh, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          'Reset',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
