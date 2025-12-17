import 'package:flutter/material.dart';

/// Provider cho các bộ icon của Memory Match game
/// Sử dụng Material Icons thay vì emoji để đảm bảo consistency cross-platform
class MemoryIconProvider {
  // Easy - Các icon rõ ràng, dễ phân biệt
  static final List<IconData> easyIcons = [
    Icons.face,
    Icons.pets,
    Icons.apple,
    Icons.star,
    Icons.sports_soccer,
    Icons.palette,
    Icons.music_note,
    Icons.wb_sunny,
  ];

  // Normal - Động vật & đồ vật (10 icons cho 4x5 grid)
  static final List<IconData> normalIcons = [
    Icons.directions_car,
    Icons.flight,
    Icons.home,
    Icons.local_florist,
    Icons.bolt,
    Icons.flag,
    Icons.camera_alt,
    Icons.favorite,
    Icons.restaurant,
    Icons.shopping_bag,
  ];

  // Hard - Double Coding (Shape + Color)
  static final List<HardIconData> hardIcons = [
    HardIconData(Icons.square, Colors.blue),
    HardIconData(Icons.square, Colors.red),
    HardIconData(Icons.square, Colors.green),
    HardIconData(Icons.circle, Colors.blue),
    HardIconData(Icons.circle, Colors.red),
    HardIconData(Icons.circle, Colors.green),
    HardIconData(Icons.change_history, Colors.blue), // Triangle
    HardIconData(Icons.change_history, Colors.red),
    HardIconData(Icons.change_history, Colors.green),
    HardIconData(Icons.star, Colors.blue),
    HardIconData(Icons.star, Colors.red),
    HardIconData(Icons.star, Colors.green),
    HardIconData(Icons.favorite, Colors.blue),
    HardIconData(Icons.favorite, Colors.red),
    HardIconData(Icons.favorite, Colors.green),
  ];

  /// Get icons based on difficulty
  static List<IconData> getIconsForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return easyIcons;
      case 'normal':
        return normalIcons;
      default:
        return easyIcons;
    }
  }

  /// Get grid size based on difficulty
  static GridSize getGridSize(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return GridSize(rows: 4, cols: 4, pairs: 8);
      case 'normal':
        return GridSize(rows: 4, cols: 5, pairs: 10);
      case 'hard':
        return GridSize(rows: 5, cols: 6, pairs: 15);
      default:
        return GridSize(rows: 4, cols: 4, pairs: 8);
    }
  }

  /// Get time limit based on difficulty (in seconds)
  static int? getTimeLimit(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return null; // Unlimited
      case 'normal':
        return 120; // 2 minutes
      case 'hard':
        return 150; // 2.5 minutes
      default:
        return null;
    }
  }

  /// Get preview duration based on difficulty (in seconds)
  static int getPreviewDuration(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 5;
      case 'normal':
        return 4;
      case 'hard':
        return 3;
      default:
        return 5;
    }
  }
}

/// Data class for Hard mode icons (Double Coding)
class HardIconData {
  final IconData shape;
  final Color color;

  HardIconData(this.shape, this.color);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HardIconData &&
        other.shape == shape &&
        other.color == color;
  }

  @override
  int get hashCode => shape.hashCode ^ color.hashCode;
}

/// Grid size configuration
class GridSize {
  final int rows;
  final int cols;
  final int pairs;

  GridSize({required this.rows, required this.cols, required this.pairs});

  int get totalCards => rows * cols;
}
