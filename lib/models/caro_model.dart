// lib/models/caro_model.dart
class CaroGame {
  final List<List<String?>> board; // null, 'X', 'O'
  final int size;
  final String mode; // 'pvp' or 'pve'
  final String difficulty; // 'easy', 'medium', 'hard'
  final String currentPlayer; // 'X' or 'O'
  final String? winner;
  final bool gameOver;
  final List<CaroMove> moveHistory;



  CaroGame({
    required this.board,
    required this.size,
    required this.mode,
    required this.difficulty,
    required this.currentPlayer,
    this.winner,
    this.gameOver = false,
    this.moveHistory = const [],
  });

  factory CaroGame.fromJson(Map<String, dynamic> json) {
    return CaroGame(
      board: (json['board'] as List)
          .map((row) => (row as List)
              .map((cell) => cell as String?)
              .toList())
          .toList(),
      size: json['size'] as int,
      mode: json['mode'] as String,
      difficulty: json['difficulty'] as String,
      currentPlayer: json['currentPlayer'] as String,
      winner: json['winner'] as String?,
      gameOver: json['gameOver'] as bool? ?? false,
      moveHistory: (json['moveHistory'] as List?)
              ?.map((m) => CaroMove.fromJson(m))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'size': size,
      'mode': mode,
      'difficulty': difficulty,
      'currentPlayer': currentPlayer,
      'winner': winner,
      'gameOver': gameOver,
      'moveHistory': moveHistory.map((m) => m.toJson()).toList(),
    };
  }

  CaroGame copyWith({
    List<List<String?>>? board,
    int? size,
    String? mode,
    String? difficulty,
    String? currentPlayer,
    String? winner,
    bool? gameOver,
    List<CaroMove>? moveHistory,
  }) {
    return CaroGame(
      board: board ?? this.board.map((row) => List<String?>.from(row)).toList(),
      size: size ?? this.size,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: winner ?? this.winner,
      gameOver: gameOver ?? this.gameOver,
      moveHistory: moveHistory ?? this.moveHistory,
    );
  }

  int getTotalMoves() => moveHistory.length;

  bool isCellEmpty(int row, int col) {
    return board[row][col] == null;
  }
}

class CaroMove {
  final int row;
  final int col;
  final String player;
  final DateTime timestamp;

  CaroMove({
    required this.row,
    required this.col,
    required this.player,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory CaroMove.fromJson(Map<String, dynamic> json) {
    return CaroMove(
      row: json['row'] as int,
      col: json['col'] as int,
      player: json['player'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
      'player': player,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}