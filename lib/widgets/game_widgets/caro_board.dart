// lib/widgets/game_widgets/caro_board.dart
import 'package:flutter/material.dart';
import '../../models/caro_model.dart';

class CaroBoard extends StatelessWidget {
  final CaroGame game;
  final int? selectedRow;
  final int? selectedCol;
  final Function(int row, int col) onCellTap;

  const CaroBoard({
    Key? key,
    required this.game,
    this.selectedRow,
    this.selectedCol,
    required this.onCellTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth - 32; // padding
    final cellSize = boardSize / game.size;

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(50),
      minScale: 0.5,
      maxScale: 3.0,
      child: Center(
        child: Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            color: Colors.brown.shade50,
            border: Border.all(color: Colors.brown.shade800, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Grid lines
              CustomPaint(
                size: Size(boardSize, boardSize),
                painter: GridPainter(
                  size: game.size,
                  cellSize: cellSize,
                ),
              ),
              
              // Cells
              for (int row = 0; row < game.size; row++)
                for (int col = 0; col < game.size; col++)
                  _buildCell(row, col, cellSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col, double cellSize) {
    final value = game.board[row][col];
    final isSelected = row == selectedRow && col == selectedCol;
    
    // Check if this is the last move
    final isLastMove = game.moveHistory.isNotEmpty &&
        game.moveHistory.last.row == row &&
        game.moveHistory.last.col == col;

    return Positioned(
      left: col * cellSize,
      top: row * cellSize,
      child: GestureDetector(
        onTap: () => onCellTap(row, col),
        child: Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.yellow.withOpacity(0.3)
                : isLastMove
                    ? Colors.green.withOpacity(0.2)
                    : Colors.transparent,
          ),
          child: Center(
            child: value != null
                ? AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: _buildPiece(value, cellSize, isLastMove),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildPiece(String player, double cellSize, bool isLastMove) {
    final pieceSize = cellSize * 0.7;
    
    if (player == 'X') {
      return Container(
        width: pieceSize,
        height: pieceSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isLastMove ? Colors.blue.shade700 : Colors.blue,
            width: cellSize * 0.08,
          ),
        ),
      );
    } else {
      return CustomPaint(
        size: Size(pieceSize, pieceSize),
        painter: XPainter(
          color: isLastMove ? Colors.red.shade700 : Colors.red,
          strokeWidth: cellSize * 0.08,
        ),
      );
    }
  }
}

// Grid painter
class GridPainter extends CustomPainter {
  final int size;
  final double cellSize;

  GridPainter({required this.size, required this.cellSize});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = Colors.brown.shade400
      ..strokeWidth = 1.0;

    // Vertical lines
    for (int i = 0; i <= size; i++) {
      final x = i * cellSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, canvasSize.height),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 0; i <= size; i++) {
      final y = i * cellSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(canvasSize.width, y),
        paint,
      );
    }

    // Draw star points (for 15x15 board)
    if (size == 15) {
      final starPaint = Paint()
        ..color = Colors.brown.shade800
        ..style = PaintingStyle.fill;

      final starPositions = [3, 7, 11];
      for (final row in starPositions) {
        for (final col in starPositions) {
          final x = (col + 0.5) * cellSize;
          final y = (row + 0.5) * cellSize;
          canvas.drawCircle(Offset(x, y), 4, starPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// X painter (for O piece)
class XPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  XPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final padding = size.width * 0.2;

    // Draw X
    canvas.drawLine(
      Offset(padding, padding),
      Offset(size.width - padding, size.height - padding),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(padding, size.height - padding),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}