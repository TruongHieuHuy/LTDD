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
import 'package:flutter/foundation.dart';
import 'package:cuber/cuber.dart' as cuber;
import 'setup_rubik_screen.dart';

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
  
  // Timer
  Timer? _gameTimer;
  int _timeSpent = 0;

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
    _stopTimer();
    _stopAutoOperations();
    super.dispose();
  }

  void _startTimer() {
    _stopTimer();
    _timeSpent = 0;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeSpent++;
        });
      }
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void _onCubeChanged() {
    // Start timer if not solved and not auto-operating
    if (!_cube.isSolved && !_isAutoShuffling && !_isAutoSolving && _gameTimer == null) {
      _startTimer();
    }

    // Stop timer and check win condition
    if (_cube.isSolved) {
      _stopTimer();
      if (!_showCelebration && !_isAutoSolving) { // Don't save if auto-solved
        _showWinCelebration();
        _saveGameResult();
      }
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

    // Only save if logged in AND manual solve (implicit via _onCubeChanged check)
    if (authProvider.isLoggedIn) {
      try {
        await gameProvider.saveGameScore(
          gameType: 'rubik', // Lowercase to match backend
          score: 0, // Backend calculates based on time/moves
          difficulty: 'medium', // Default for now
          attempts: 1,
          timeSpent: _timeSpent,
          moves: _cube.moveCount,
        );
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Score saved to leaderboard!')),
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
      await _executeMoveDirectly(move);
      await Future.delayed(const Duration(milliseconds: 350));
    }

    if (mounted) {
      setState(() {
        _isAutoShuffling = false;
      });
    }
  }

  // Máy Giải - Sử dụng thuật toán Kociemba
  Future<void> _autoSolve() async {
    if (_isAutoSolving || _isAutoShuffling) return;
    if (!mounted) return;

    setState(() {
      _isAutoSolving = true;
      _solveStep = 0;
      _totalSolveSteps = 0;
    });

    try {
      int maxAttempts = 3;
      int attempt = 0;

      while (!_cube.isSolved && attempt < maxAttempts) {
        attempt++;
        debugPrint('\n=== AutoSolve Attempt $attempt/$maxAttempts ===');
        
        // 1. Lấy trạng thái cube hiện tại
        final cubeString = _getCubeStateString();
        debugPrint('AutoSolve: Current cube state (54 chars):');
        debugPrint('  - Full: $cubeString');
        debugPrint('  - U: ${cubeString.substring(0, 9)}');
        debugPrint('  - R: ${cubeString.substring(9, 18)}');
        debugPrint('  - F: ${cubeString.substring(18, 27)}');
        debugPrint('  - D: ${cubeString.substring(27, 36)}');
        debugPrint('  - L: ${cubeString.substring(36, 45)}');
        debugPrint('  - B: ${cubeString.substring(45, 54)}');
        debugPrint('AutoSolve: isSolved before solving = ${_cube.isSolved}');

        if (cubeString.length != 54) {
          throw Exception('Invalid cube state length: ${cubeString.length}');
        }

        // 2. Giải bằng Kociemba trong background isolate
        debugPrint('AutoSolve: Starting solver in background...');
        final solutionMoves = await compute(_solveCube, cubeString);
        
        debugPrint('AutoSolve: Solution found with ${solutionMoves.length} moves');

        if (solutionMoves.isEmpty) {
           debugPrint('AutoSolve: Cube is already solved.');
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Cube đã được giải!')),
           );
           return;
        }

        if (solutionMoves.first.startsWith('ERROR:')) {
           throw Exception(solutionMoves.first.substring(7));
        }

        setState(() {
          _totalSolveSteps = solutionMoves.length;
        });

        // 3. Thực hiện từng bước move và update model
        for (int i = 0; i < solutionMoves.length; i++) {
          if (!_isAutoSolving || !mounted) return;

          final moveStr = solutionMoves[i];
          
          if (mounted) {
            setState(() {
               _solveStep = i + 1;
            });
          }
          
          debugPrint('AutoSolve: Executing move ${i+1}/${solutionMoves.length}: $moveStr');
          await _executeMoveWithCuberNotation(moveStr);
          
          // Đợi thêm để đảm bảo animation (500ms) + model update hoàn tất
          await Future.delayed(const Duration(milliseconds: 600));
          
          // Log state sau mỗi move
          debugPrint('AutoSolve: After move $moveStr, isSolved: ${_cube.isSolved}');
        }

        // 4. Kiểm tra xem đã solved chưa
        await Future.delayed(const Duration(milliseconds: 500)); // Đợi thêm để chắc chắn
        debugPrint('AutoSolve: After attempt $attempt, isSolved = ${_cube.isSolved}');
        
        if (_cube.isSolved) {
          debugPrint('AutoSolve: SUCCESS! Cube solved in $attempt attempt(s)');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Cube đã giải xong sau $attempt lần thử!')),
          );
          break;
        } else if (attempt < maxAttempts) {
          debugPrint('AutoSolve: NOT solved yet, will retry...');
        } else {
          debugPrint('AutoSolve: FAILED after $maxAttempts attempts');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ Không thể giải hoàn toàn. Hãy thử lại!')),
          );
        }
      }

    } catch (e) {
      debugPrint('Error in auto solve: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể giải: ${e.toString().substring(0, math.min(50, e.toString().length))}...')),
        );
      }
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
          actions: [
            IconButton(
              icon: const Icon(Icons.camera_alt),
              color: GamingTheme.textPrimary,
              tooltip: 'Setup Real Cube',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SetupRubikScreen(),
                  ),
                );
              },
            ),
          ],
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

  Future<void> _executeMoveWithCuberNotation(String move) async {
      if (move.endsWith('2')) {
          final baseMove = move.substring(0, 1);
          await _executeMoveDirectly(baseMove); // 1
          // Đợi animation + model update hoàn tất (500ms animation)
          await Future.delayed(const Duration(milliseconds: 600));
          await _executeMoveDirectly(baseMove); // 2
      } else {
          await _executeMoveDirectly(move);
      }
  }

  // Thực hiện move trực tiếp qua 3D widget (sẽ update cả model)
  Future<void> _executeMoveDirectly(String move) async {
    if (!mounted) return;

    // Gọi qua widget - widget sẽ update model sau khi animation xong
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

    // Đợi để animation bắt đầu (avoid race condition)
    await Future.delayed(const Duration(milliseconds: 50));
  }

  String _getCubeStateString() {
    final buffer = StringBuffer();
    
    // U (Up) - y=2, z:0->2, x:0->2
    for (int z = 0; z <= 2; z++) {
      for (int x = 0; x <= 2; x++) {
        buffer.write(_getColorChar(_cube.cubelets[x][2][z].getFaceColor('up')));
      }
    }

    // R (Right) - x=2, y:2->0, z:2->0
    for (int y = 2; y >= 0; y--) {
      for (int z = 2; z >= 0; z--) {
        buffer.write(_getColorChar(_cube.cubelets[2][y][z].getFaceColor('right')));
      }
    }

    // F (Front) - z=2, y:2->0, x:0->2
    for (int y = 2; y >= 0; y--) {
      for (int x = 0; x <= 2; x++) {
        buffer.write(_getColorChar(_cube.cubelets[x][y][2].getFaceColor('front')));
      }
    }

    // D (Down) - y=0, z:2->0, x:0->2
    for (int z = 2; z >= 0; z--) {
      for (int x = 0; x <= 2; x++) {
        buffer.write(_getColorChar(_cube.cubelets[x][0][z].getFaceColor('down')));
      }
    }

    // L (Left) - x=0, y:2->0, z:0->2
    for (int y = 2; y >= 0; y--) {
      for (int z = 0; z <= 2; z++) {
        buffer.write(_getColorChar(_cube.cubelets[0][y][z].getFaceColor('left')));
      }
    }

    // B (Back) - z=0, y:2->0, x:2->0
    for (int y = 2; y >= 0; y--) {
      for (int x = 2; x >= 0; x--) {
        buffer.write(_getColorChar(_cube.cubelets[x][y][0].getFaceColor('back')));
      }
    }

    return buffer.toString();
  }

  String _getColorChar(CubeColor? color) {
    if (color == null) return 'U'; // Should not happen for face-colored cubelets
    switch (color) {
      case CubeColor.white: return 'U';
      case CubeColor.red: return 'R';
      case CubeColor.blue: return 'F';
      case CubeColor.yellow: return 'D';
      case CubeColor.orange: return 'L';
      case CubeColor.green: return 'B';
    }
  }
}

// Top-level function for compute
List<String> _solveCube(String cubeString) {
  try {
    final cube = cuber.Cube.from(cubeString);
    
    if (cube.isSolved) return [];

    final solution = cube.solve(maxDepth: 30);
    final moves = solution?.algorithm.moves.map((m) => m.toString()).toList() ?? [];
    
    if (moves.isEmpty && !cube.isSolved) {
      return ['ERROR: Solver returned no moves but cube is not solved.'];
    }
    
    return moves;
  } catch (e) {
    debugPrint('_solveCube error: $e');
    return ['ERROR: ${e.toString()}'];
  }
}
