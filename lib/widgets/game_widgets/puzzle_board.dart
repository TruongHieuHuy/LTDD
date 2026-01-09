// lib/widgets/game_widgets/puzzle_board.dart

import 'package:flutter/material.dart';
import '../../models/puzzle_model.dart';

class PuzzleBoard extends StatelessWidget {
  final PuzzleGame game;
  final Function(int) onTileTap;

  const PuzzleBoard({
    Key? key,
    required this.game,
    required this.onTileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 1. Tính toán rawSize dựa trên màn hình
    double rawSize = (screenWidth - 32).clamp(300.0, 500.0);
    
    // 2. ÉP KÍCH THƯỚC CHIA HẾT CHO GRID SIZE (QUAN TRỌNG)
    // ~/ là phép chia lấy nguyên, sau đó nhân ngược lại để ra bội số gần nhất
    double boardSize = (rawSize ~/ game.gridSize) * game.gridSize.toDouble();
    
    // 3. Tính toán tileSize chuẩn
    double tileSize = boardSize / game.gridSize;

    return Center(
      child: Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Dùng Stack để di chuyển các ô bằng tọa độ tuyệt đối (AnimatedPositioned)
        child: Stack(
          children: game.tiles.asMap().entries.map((entry) {
            final tile = entry.value;
            // Tính toán vị trí Row/Col dựa trên currentIndex (vị trí hiện tại trên lưới)
            final row = tile.currentIndex ~/ game.gridSize;
            final col = tile.currentIndex % game.gridSize;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              // Tọa độ chuẩn không sai lệch nhờ boardSize đã được xử lý
              left: col * tileSize,
              top: row * tileSize,
              child: _buildTile(tile, tileSize),
            );
          }).toList(),
        ),
      ),
    );
  }

 Widget _buildTile(PuzzleTile tile, double size) {
    // Ô trống được xác định là ô cuối cùng (ví dụ 8 đối với 3x3)
    // Hoặc giữ nguyên logic tile.isEmpty của bạn nếu trong model bạn đã định nghĩa đúng
    if (tile.isEmpty) {
      return SizedBox(width: size, height: size);
    }

    final canMove = game.canMoveTile(tile.currentIndex);

    return GestureDetector(
      onTap: canMove ? () => onTileTap(tile.currentIndex) : null,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(0.5), // Tạo đường kẻ mảnh giữa các ô
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: tile.isCorrect ? Colors.green : Colors.grey.shade300,
            width: tile.isCorrect ? 1.5 : 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              // SỬA TẠI ĐÂY: Dùng trực tiếp tile.value để lấy ảnh
              Image.network(
                game.tilePaths[tile.value], 
                width: size,
                height: size,
                fit: BoxFit.fill, // Cực kỳ quan trọng để không bị lệch pixel
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(child: Text('${tile.value}')),
                  );
                },
              ),

              if (tile.isCorrect)
                Container(color: Colors.green.withOpacity(0.1)),

              if (!tile.isCorrect)
                Positioned(
                  top: 4,
                  left: 4,
                  child: _buildBadge('${tile.value}', Colors.black54),
                ),

              if (tile.isCorrect)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 7,
                    child: Icon(Icons.check, color: Colors.white, size: 10),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper cho Badge số
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}