import 'package:flutter/material.dart';
import '../../models/rubik_cube_model.dart';
import '../../config/gaming_theme.dart';
import 'step_guide_screen.dart';
import 'package:cuber/cuber.dart' as cuber;

class SetupRubikScreen extends StatefulWidget {
  const SetupRubikScreen({super.key});

  @override
  State<SetupRubikScreen> createState() => _SetupRubikScreenState();
}

class _SetupRubikScreenState extends State<SetupRubikScreen> {
  // State: 54 colors (6 faces × 9 cells each)
  Map<String, List<CubeColor>> faceColors = {
    'U': List.filled(9, CubeColor.white),
    'R': List.filled(9, CubeColor.red),
    'F': List.filled(9, CubeColor.blue),
    'D': List.filled(9, CubeColor.yellow),
    'L': List.filled(9, CubeColor.orange),
    'B': List.filled(9, CubeColor.green),
  };

  CubeColor selectedColor = CubeColor.white;
  bool isValidating = false;

  @override
  void initState() {
    super.initState();
    _resetToSolved();
  }

  void _resetToSolved() {
    setState(() {
      faceColors = {
        'U': List.filled(9, CubeColor.white),
        'R': List.filled(9, CubeColor.red),
        'F': List.filled(9, CubeColor.blue),
        'D': List.filled(9, CubeColor.yellow),
        'L': List.filled(9, CubeColor.orange),
        'B': List.filled(9, CubeColor.green),
      };
    });
  }

  void _onCellTap(String face, int index) {
    // Center cells (index 4) are locked
    if (index == 4) return;

    setState(() {
      faceColors[face]![index] = selectedColor;
    });
  }

  String _getCubeStateString() {
    final buffer = StringBuffer();
    
    // URFDLB order for Kociemba
    for (String face in ['U', 'R', 'F', 'D', 'L', 'B']) {
      for (var color in faceColors[face]!) {
        buffer.write(_colorToChar(color));
      }
    }
    
    return buffer.toString();
  }

  String _colorToChar(CubeColor color) {
    switch (color) {
      case CubeColor.white: return 'U';
      case CubeColor.red: return 'R';
      case CubeColor.blue: return 'F';
      case CubeColor.yellow: return 'D';
      case CubeColor.orange: return 'L';
      case CubeColor.green: return 'B';
    }
  }

  bool _validateCubeState() {
    // Count each color
    Map<CubeColor, int> colorCounts = {};
    for (var face in faceColors.values) {
      for (var color in face) {
        colorCounts[color] = (colorCounts[color] ?? 0) + 1;
      }
    }

    // Must have exactly 9 of each color
    for (var color in CubeColor.values) {
      if (colorCounts[color] != 9) {
        _showError('Mỗi màu phải có đúng 9 ô! Hiện tại ${_colorName(color)}: ${colorCounts[color] ?? 0}');
        return false;
      }
    }

    return true;
  }

  String _colorName(CubeColor color) {
    switch (color) {
      case CubeColor.white: return 'Trắng';
      case CubeColor.yellow: return 'Vàng';
      case CubeColor.red: return 'Đỏ';
      case CubeColor.orange: return 'Cam';
      case CubeColor.blue: return 'Xanh dương';
      case CubeColor.green: return 'Xanh lá';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _solve() async {
    if (!_validateCubeState()) return;

    setState(() => isValidating = true);

    try {
      final cubeString = _getCubeStateString();
      debugPrint('Cube state: $cubeString');

      // Try to solve
      final cube = cuber.Cube.from(cubeString);
      
      if (cube.isSolved) {
         _showError('Cube đã được giải rồi! (Trạng thái hoàn hảo)');
         return;
      }

      final solution = cube.solve(maxDepth: 25, timeout: const Duration(seconds: 10));
      
      if (solution == null) {
        _showError('Không tìm thấy lời giải! Có thể bạn đã nhập sai màu hoặc cube bị lỗi vật lý (góc/cạnh sai).');
        return;
      }

      final moves = solution.algorithm.moves.map((m) => m.toString()).toList();
      debugPrint('Solver Found Moves: $moves'); // <-- In ra terminal

      if (moves.isEmpty) {
        _showError('Cube đã được giải rồi!');
      } else {
        // Navigate to step guide
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StepGuideScreen(solutionMoves: moves),
          ),
        );
      }
    } catch (e) {
      _showError('Trạng thái cube không hợp lệ: ${e.toString()}');
    } finally {
      setState(() => isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      appBar: AppBar(
        title: const Text('Setup Real Cube'),
        backgroundColor: GamingTheme.surfaceDark,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: GamingTheme.surfaceGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildColorPicker(),
              const SizedBox(height: 20),
              _buildFaceLayout(),
              const SizedBox(height: 20),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    // Calculate current counts
    Map<CubeColor, int> counts = {};
    for (var face in faceColors.values) {
      for (var color in face) {
        counts[color] = (counts[color] ?? 0) + 1;
      }
    }

    return Card(
      color: GamingTheme.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text('Chọn màu (Cần đủ 9 ô mỗi màu):', style: GamingTheme.bodyLarge),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: CubeColor.values.map((color) {
                final isSelected = selectedColor == color;
                final count = counts[color] ?? 0;
                final isComplete = count == 9;
                final isOver = count > 9;

                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Column(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: _getFlutterColor(color),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.black26,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _getFlutterColor(color).withOpacity(0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: isComplete
                            ? const Icon(Icons.check, color: Colors.black54)
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count/9',
                        style: TextStyle(
                          color: isOver
                              ? Colors.red
                              : (isComplete ? Colors.green : Colors.white70),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFlutterColor(CubeColor color) {
    switch (color) {
      case CubeColor.white: return Colors.white;
      case CubeColor.yellow: return Colors.yellow[700]!;
      case CubeColor.red: return Colors.red[700]!;
      case CubeColor.orange: return Colors.orange[700]!;
      case CubeColor.blue: return Colors.blue[700]!;
      case CubeColor.green: return Colors.green[700]!;
    }
  }

  Widget _buildFaceLayout() {
    return Column(
      children: [
        // Up face
        _buildFace('U', 'UP'),
        const SizedBox(height: 8),
        // Middle row: L F R B
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFace('L', 'L'),
            const SizedBox(width: 4),
            _buildFace('F', 'F'),
            const SizedBox(width: 4),
            _buildFace('R', 'R'),
            const SizedBox(width: 4),
            _buildFace('B', 'B'),
          ],
        ),
        const SizedBox(height: 8),
        // Down face
        _buildFace('D', 'DOWN'),
      ],
    );
  }

  Widget _buildFace(String face, String label) {
    final colors = faceColors[face]!;
    
    return Container(
      width: 90,
      child: Column(
        children: [
          Text(label, style: GamingTheme.bodySmall.copyWith(color: Colors.white70)),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final isCenter = index == 4;
              return GestureDetector(
                onTap: () => _onCellTap(face, index),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getFlutterColor(colors[index]),
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: isCenter
                      ? const Icon(Icons.lock, size: 16, color: Colors.black26)
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _shuffleCube() {
    setState(() {
      final scrambledCube = cuber.Cube.scrambled();
      // Kociemba string format: UUUUUUUUURRRRRRRRRFFFFFFFFFDDDDDDDDDLLLLLLLLLBBBBBBBBB
      // 54 chars corresponding to 54 facelets in U R F D L B order
      final cubeString = scrambledCube.definition; 

      int index = 0;
      for (String face in ['U', 'R', 'F', 'D', 'L', 'B']) {
        for (int i = 0; i < 9; i++) {
          final char = cubeString[index++];
          faceColors[face]![i] = _charToColor(char);
        }
      }
    });
  }

  CubeColor _charToColor(String char) {
    switch (char) {
      case 'U': return CubeColor.white;
      case 'R': return CubeColor.red;
      case 'F': return CubeColor.blue;
      case 'D': return CubeColor.yellow;
      case 'L': return CubeColor.orange;
      case 'B': return CubeColor.green;
      default: return CubeColor.white;
    }
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _resetToSolved,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shuffleCube,
            icon: const Icon(Icons.shuffle),
            label: const Text('Shuffle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isValidating ? null : _solve,
            icon: isValidating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check),
            label: const Text('Solve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
