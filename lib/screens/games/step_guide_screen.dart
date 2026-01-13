import 'package:flutter/material.dart';
import '../../config/gaming_theme.dart';

class StepGuideScreen extends StatefulWidget {
  final List<String> solutionMoves;

  const StepGuideScreen({
    super.key,
    required this.solutionMoves,
  });

  @override
  State<StepGuideScreen> createState() => _StepGuideScreenState();
}

class _StepGuideScreenState extends State<StepGuideScreen> {
  int currentStep = 0;

  String get currentMove => widget.solutionMoves[currentStep];
  int get totalSteps => widget.solutionMoves.length;

  void _nextStep() {
    if (currentStep < totalSteps - 1) {
      setState(() => currentStep++);
    } else {
      _showCompletionDialog();
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Hoàn thành!'),
        content: const Text('Cube của bạn đã được giải xong!\nChúc mừng!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to setup screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getMoveInstruction(String move) {
    // Parse move notation
    String face = move[0];
    bool isPrime = move.contains("'");
    bool isDouble = move.contains('2');

    String faceName = _getFaceName(face);
    String direction = isPrime ? 'ngược chiều kim đồng hồ' : 'theo chiều kim đồng hồ';

    if (isDouble) {
      return 'Xoay mặt $faceName 180° (2 lần)';
    } else {
      return 'Xoay mặt $faceName $direction';
    }
  }

  String _getFaceName(String face) {
    switch (face) {
      case 'R': return 'PHẢI (Đỏ)';
      case 'L': return 'TRÁI (Cam)';
      case 'U': return 'TRÊN (Trắng)';
      case 'D': return 'DƯỚI (Vàng)';
      case 'F': return 'TRƯỚC (Xanh dương)';
      case 'B': return 'SAU (Xanh lá)';
      default: return face;
    }
  }

  Color _getMoveColor(String move) {
    String face = move[0];
    switch (face) {
      case 'R': return Colors.red;
      case 'L': return Colors.orange;
      case 'U': return Colors.white;
      case 'D': return Colors.yellow[700]!;
      case 'F': return Colors.blue;
      case 'B': return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _buildMoveAnimation(String move) {
    bool isPrime = move.contains("'");
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: (isPrime ? -1 : 1) * value * 1.57, // 90 degrees
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getMoveColor(move),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.rotate_right, size: 40, color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      appBar: AppBar(
        title: Text('Bước ${currentStep + 1} / $totalSteps'),
        backgroundColor: GamingTheme.surfaceDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: GamingTheme.surfaceGradient),
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (currentStep + 1) / totalSteps,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
            ),
            
            const SizedBox(height: 40),
            
            // Current move display (large)
            Text(
              currentMove,
              style: const TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Animation
            _buildMoveAnimation(currentMove),
            
            const SizedBox(height: 40),
            
            // Instruction text
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              color: GamingTheme.surfaceLight,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _getMoveInstruction(currentMove),
                  textAlign: TextAlign.center,
                  style: GamingTheme.h3.copyWith(color: Colors.white),
                ),
              ),
            ),
            
            const Spacer(),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: currentStep > 0 ? _previousStep : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Trước'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _nextStep,
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(currentStep < totalSteps - 1 ? 'Tiếp' : 'Xong'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Hủy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
