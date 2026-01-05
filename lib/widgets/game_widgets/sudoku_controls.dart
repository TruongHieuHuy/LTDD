import 'package:flutter/material.dart';

class SudokuControls extends StatelessWidget {
  final int? selectedNumber;
  final Function(int) onNumberTap;
  final VoidCallback onClear;
  final VoidCallback onHint;
  final int hintsUsed;
  final bool canClear;

  const SudokuControls({
    Key? key,
    this.selectedNumber,
    required this.onNumberTap,
    required this.onClear,
    required this.onHint,
    required this.hintsUsed,
    required this.canClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Number buttons (1-9)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(9, (index) {
              final number = index + 1;
              final isSelected = selectedNumber == number;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected 
                            ? Colors.blue 
                            : Colors.grey.shade300,
                        foregroundColor: isSelected 
                            ? Colors.white 
                            : Colors.black87,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => onNumberTap(number),
                      child: Text(
                        number.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Clear button
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.clear, size: 20),
                  label: const Text('Xóa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: canClear ? onClear : null,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Hint button
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.lightbulb_outline, size: 20),
                  label: Text('Gợi ý ($hintsUsed)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}