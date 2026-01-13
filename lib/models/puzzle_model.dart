// lib/models/puzzle_model.dart

class PuzzleTile {
  final int value; // Giá trị từ 0-8, 0-15, 0-24 (0 là ô trống)
  final int currentIndex; // Vị trí hiện tại
  final int correctIndex; // Vị trí đúng

  PuzzleTile({
    required this.value,
    required this.currentIndex,
    required this.correctIndex,
  });

  bool get isCorrect => currentIndex == correctIndex;
  bool get isEmpty => value == 0;

  PuzzleTile copyWith({
    int? value,
    int? currentIndex,
    int? correctIndex,
  }) {
    return PuzzleTile(
      value: value ?? this.value,
      currentIndex: currentIndex ?? this.currentIndex,
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'currentIndex': currentIndex,
      'correctIndex': correctIndex,
    };
  }

  factory PuzzleTile.fromJson(Map<String, dynamic> json) {
    return PuzzleTile(
      value: json['value'] as int,
      currentIndex: json['currentIndex'] as int,
      correctIndex: json['correctIndex'] as int,
    );
  }
}

class PuzzleGame {
  final String id;
  final String difficulty; // 'easy' (3x3), 'medium' (4x4), 'hard' (5x5)
  final int gridSize; // 3, 4, 5
  final List<PuzzleTile> tiles;
  final String imageUrl; // URL ảnh gốc từ backend
  final List<String> tilePaths; // Đường dẫn các mảnh ảnh đã cắt
  final int moves; // Số lần di chuyển
  final DateTime startTime;

  PuzzleGame({
    required this.id,
    required this.difficulty,
    required this.gridSize,
    required this.tiles,
    required this.imageUrl,
    required this.tilePaths,
    this.moves = 0,
    DateTime? startTime,
  }) : startTime = startTime ?? DateTime.now();

  // Tính số ô đã đúng vị trí
  int get correctTilesCount {
    return tiles.where((tile) => tile.isCorrect && !tile.isEmpty).length;
  }

  // Tổng số ô (không tính ô trống)
  int get totalTiles => gridSize * gridSize - 1;

  // Kiểm tra hoàn thành
  bool isCompleted() {
    return tiles.every((tile) => tile.isCorrect);
  }

  // Lấy vị trí ô trống
  int get emptyTileIndex {
    return tiles.indexWhere((tile) => tile.isEmpty);
  }

  // Kiểm tra có thể di chuyển ô này không
  bool canMoveTile(int index) {
    final emptyIndex = emptyTileIndex;
    final row = index ~/ gridSize;
    final col = index % gridSize;
    final emptyRow = emptyIndex ~/ gridSize;
    final emptyCol = emptyIndex % gridSize;

    // Cùng hàng hoặc cùng cột với ô trống
    if (row == emptyRow && (col - emptyCol).abs() == 1) return true;
    if (col == emptyCol && (row - emptyRow).abs() == 1) return true;

    return false;
  }

  // Di chuyển ô
  PuzzleGame moveTile(int index) {
    if (!canMoveTile(index)) return this;

    final emptyIndex = emptyTileIndex;
    final newTiles = List<PuzzleTile>.from(tiles);

    // Swap positions
    final temp = newTiles[index];
    newTiles[index] = newTiles[emptyIndex].copyWith(currentIndex: index);
    newTiles[emptyIndex] = temp.copyWith(currentIndex: emptyIndex);

    return copyWith(
      tiles: newTiles,
      moves: moves + 1,
    );
  }

  // Tính thời gian đã chơi (giây)
  int getElapsedSeconds() {
    return DateTime.now().difference(startTime).inSeconds;
  }

  PuzzleGame copyWith({
    String? id,
    String? difficulty,
    int? gridSize,
    List<PuzzleTile>? tiles,
    String? imageUrl,
    List<String>? tilePaths,
    int? moves,
    DateTime? startTime,
  }) {
    return PuzzleGame(
      id: id ?? this.id,
      difficulty: difficulty ?? this.difficulty,
      gridSize: gridSize ?? this.gridSize,
      tiles: tiles ?? this.tiles,
      imageUrl: imageUrl ?? this.imageUrl,
      tilePaths: tilePaths ?? this.tilePaths,
      moves: moves ?? this.moves,
      startTime: startTime ?? this.startTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'difficulty': difficulty,
      'gridSize': gridSize,
      'tiles': tiles.map((t) => t.toJson()).toList(),
      'imageUrl': imageUrl,
      'tilePaths': tilePaths,
      'moves': moves,
      'startTime': startTime.toIso8601String(),
    };
  }

  factory PuzzleGame.fromJson(Map<String, dynamic> json) {
    // Helper để đổi localhost thành 10.0.2.2 cho Android Emulator
    String fixUrl(String url) {
      // Đổi localhost thành 10.0.2.2 (Android Emulator)
      if (url.contains('localhost:3000')) {
        return url.replaceAll('localhost:3000', '10.0.2.2:3000');
      }
      if (url.contains('localhost')) {
        return url.replaceAll('localhost', '10.0.2.2');
      }
      return url;
    }

    final imageUrl = fixUrl(json['imageUrl'] as String);
    final tilePaths = (json['tilePaths'] as List)
        .map((path) => fixUrl(path as String))
        .toList();

    print('🔧 Fixed imageUrl: $imageUrl');
    print('🔧 Fixed first tile: ${tilePaths.isNotEmpty ? tilePaths[0] : "none"}');

    return PuzzleGame(
      id: json['id'] as String,
      difficulty: json['difficulty'] as String,
      gridSize: json['gridSize'] as int,
      tiles: (json['tiles'] as List)
          .map((t) => PuzzleTile.fromJson(t as Map<String, dynamic>))
          .toList(),
      imageUrl: imageUrl,
      tilePaths: tilePaths,
      moves: json['moves'] as int? ?? 0,
      startTime: DateTime.parse(json['startTime'] as String),
    );
  }
}