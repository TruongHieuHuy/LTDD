import 'package:flutter/material.dart';
import '../../models/sudoku_model.dart';
import 'sudoku_cell.dart';

class SudokuBoard extends StatelessWidget {
  final SudokuGame game;
  final int? selectedRow;
  final int? selectedCol;
  final int? selectedNumber;
  final Function(int row, int col) onCellTap;

  const SudokuBoard({
    Key? key,
    required this.game,
    this.selectedRow,
    this.selectedCol,
    this.selectedNumber,
    required this.onCellTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          color: Colors.grey.shade200,
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            final value = game.currentState[index];

            final isSelected = selectedRow == row && selectedCol == col;
            final isHighlighted = selectedNumber != null && 
                value == selectedNumber && 
                value != 0;
            final isMistake = game.hasMistake(row, col);

            return Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: (col + 1) % 3 == 0 && col != 8
                        ? Colors.black
                        : Colors.transparent,
                    width: 2,
                  ),
                  bottom: BorderSide(
                    color: (row + 1) % 3 == 0 && row != 8
                        ? Colors.black
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: SudokuCell(
                value: value,
                isInitial: game.isInitialCell(row, col),
                isSelected: isSelected,
                isMistake: isMistake,
                isHighlighted: isHighlighted,
                onTap: () => onCellTap(row, col),
              ),
            );
          },
        ),
      ),
    );
  }
}