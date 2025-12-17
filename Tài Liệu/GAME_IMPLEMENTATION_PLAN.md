# 🎮 GAME IMPLEMENTATION PLAN

> ⚠️ **CẢNH BÁO ĐỎ**: Rubik 3D là game KHÓ NHẤT - Rủi ro cao!
> 🎯 **Chiến lược**: Làm Sudoku + Puzzle TRƯỚC (game dễ) để tạo momentum

**Dự án**: Game Mobile - 4 Games Required  
**Ngày**: 18/12/2025  
**Games**: Rubik's Cube, Sudoku, Caro (Gomoku), Puzzle (Jigsaw)

---

## 📋 MỤC LỤC (ƯU TIÊN THỰC HIỆN)
1. [✅ Game DỄ: Sudoku](#game-2-sudoku) - **LÀM TRƯỚC TIÊN**
2. [✅ Game DỄ: Puzzle](#game-4-puzzle-jigsaw) - **LÀM TRƯỚC TIÊN**
3. [⚠️ Game TRUNG BÌNH: Caro](#game-3-caro-gomoku) - **CẦN DÙNG ISOLATE**
4. [🔴 Game KHÓ: Rubik's Cube](#game-1-rubiks-cube) - **TÌM PACKAGE, KHÔNG TỰ VIẾT**
5. [Common Components](#common-components)

---

## GAME 1: RUBIK'S CUBE

> 🔴 **RỦI RO CRITICAL**: Đây là game KHÓ NHẤT trong 4 game!
> ⚠️ **KHÔNG TỰ VIẾT** thuật toán Solver - Tìm package có sẵn!
> 💡 **Backup Plan**: Nếu quá khó → Xin giáo viên cho phép Rubik 2D (1 mặt)

### 1.1 Tổng quan

**Mô tả**: 3D Rubik's Cube với khả năng giải tự động  
**Độ khó**: 3 levels (2x2, 3x3, 4x4)  
**Tính năng**: Rotate faces, Solver algorithm, Timer, Move counter  
**Thời gian dự kiến**: 1.5-2 tuần (⚠️ Cao nhất)  
**Rủi ro**: 🔴 Cao - Cần backup plan

### 1.2 UI/UX Flow

```
┌──────────────────────────────────────────────┐
│        RUBIK'S CUBE GAME FLOW                │
└──────────────────────────────────────────────┘

Screen 1: Game Menu
├─ Choose Cube Size: 2x2, 3x3, 4x4
├─ [Start New Game]
├─ [View Tutorial]
└─ [Leaderboard]
        │
        ▼
Screen 2: Game Play
├─ 3D Cube Rendering (using Canvas/Custom Paint)
├─ Gesture Controls:
│   - Swipe to rotate faces
│   - Pinch to zoom
│   - Drag to rotate cube view
├─ HUD:
│   ├─ Timer: 00:00
│   ├─ Moves: 0
│   └─ [Solve] [Reset] [Hint]
├─ Color Palette:
│   ├─ White (Top)
│   ├─ Yellow (Bottom)
│   ├─ Red (Front)
│   ├─ Orange (Back)
│   ├─ Blue (Left)
│   └─ Green (Right)
        │
        ▼
Screen 3: Victory
├─ 🎉 Completed!
├─ Time: 2m 34s
├─ Moves: 87
├─ Score: 850
├─ [Play Again] [Share] [Home]
```

### 1.3 Algorithm Design

#### **Cube State Representation**
```dart
class RubikCube {
  // 3x3 cube = 6 faces x 9 stickers = 54 stickers
  late List<List<Color>> faces; // [top, bottom, front, back, left, right]
  
  RubikCube(int size) {
    faces = List.generate(6, (faceIndex) => 
      List.filled(size * size, _getFaceColor(faceIndex))
    );
  }
  
  // Rotate face clockwise
  void rotateFace(int face, bool clockwise) {
    // 1. Rotate the face itself
    _rotateFaceMatrix(face, clockwise);
    
    // 2. Rotate adjacent edges
    _rotateAdjacentEdges(face, clockwise);
  }
  
  bool isSolved() {
    return faces.every((face) => 
      face.every((color) => color == face[0])
    );
  }
}
```

#### **Solver Algorithm: Kociemba's Algorithm**

> ⚠️ **QUAN TRỌNG**: ĐừNG tự viết thuật toán này từ đầu!

**Cách tiếp cận khuyến nghị**:

1. **Option A (Tốt nhất)**: Tìm package Dart có sẵn
   ```yaml
   # pubspec.yaml - TÌM PACKAGE NÀY
   dependencies:
     rubik_solver: ^x.x.x  # Kiểm tra pub.dev
   ```

2. **Option B**: Port từ JavaScript/Python
   - GitHub: Search "rubik cube solver javascript"
   - Chọn repo có nhiều star, convert sang Dart
   - Ví dụ: [cube-solver](https://github.com/...)

3. **Option C (Cuối cùng)**: Tự implement đơn giản
   ```dart
   class RubikSolver {
     // ĐƠN GIẢN HÓA: Chỉ dùng cho 2x2 cube
     // 2x2 có thuật toán đơn giản hơn (max 11 moves)
     
     List<String> solve2x2(RubikCube cube) {
       // Use BFS (Breadth-First Search)
       // Max depth = 11 for 2x2
       return _breadthFirstSearch(cube, maxDepth: 11);
     }
     
     List<String> solve3x3(RubikCube cube) {
       // Nếu không tìm được package → XIN GIÁO VIÊN
       // cho phép bỏ Solver hoặc chỉ làm 2x2
       throw UnimplementedError('Use package instead!');
     }
   }
   ```

**Note**: Nếu sau 3 ngày chưa tìm được giải pháp → BÁO CÁO GIÁO VIÊN NGAY!

### 1.4 Scoring Formula

```dart
int calculateScore(int moves, int timeSeconds, String difficulty) {
  const baseScore = {
    '2x2': 500,
    '3x3': 1000,
    '4x4': 2000,
  };
  
  final base = baseScore[difficulty] ?? 1000;
  
  // Penalty for moves (optimal moves: 2x2=11, 3x3=20, 4x4=40)
  final optimalMoves = difficulty == '2x2' ? 11 : (difficulty == '3x3' ? 20 : 40);
  final moveMultiplier = max(0.5, 1 - (moves - optimalMoves) / 100);
  
  // Penalty for time (bonus under 5 min)
  final timeMultiplier = timeSeconds < 300 ? 1.5 : max(0.5, 1 - timeSeconds / 600);
  
  return (base * moveMultiplier * timeMultiplier).toInt();
}
```

### 1.5 Technical Implementation

**Dependencies**:
```yaml
# pubspec.yaml
dependencies:
  vector_math: ^2.1.4      # 3D math
  flutter_cube: ^0.1.1     # 3D rendering (alternative: custom paint)
```

**File Structure**:
```
lib/screens/games/rubik/
├── rubik_game_screen.dart          # Main game screen
├── rubik_cube_painter.dart         # Custom painter for 3D cube
├── rubik_cube_model.dart           # Cube state + logic
├── rubik_solver.dart               # Solver algorithm
├── rubik_controls.dart             # Gesture handlers
└── rubik_tutorial_screen.dart      # Tutorial overlay
```

**Key Code Sample**:
```dart
class RubikCubePainter extends CustomPainter {
  final RubikCube cube;
  final Matrix4 transformation;
  
  @override
  void paint(Canvas canvas, Size size) {
    // Project 3D coordinates to 2D screen
    for (int face = 0; face < 6; face++) {
      for (int i = 0; i < cube.size; i++) {
        for (int j = 0; j < cube.size; j++) {
          final color = cube.faces[face][i * cube.size + j];
          final rect = _calculateStickerRect(face, i, j, transformation);
          canvas.drawRect(rect, Paint()..color = color);
        }
      }
    }
  }
  
  Rect _calculateStickerRect(int face, int row, int col, Matrix4 transform) {
    // Convert cube coordinates to screen coordinates
    // Apply rotation matrix, perspective projection
    // ...
  }
}
```

---

## GAME 2: SUDOKU

### 2.1 Tổng quan

**Mô tả**: Classic Sudoku với generator & solver  
**Độ khó**: 4 levels (Easy, Medium, Hard, Expert)  
**Tính năng**: Auto-check, Hints, Notes mode, Undo/Redo

### 2.2 UI/UX Flow

```
Screen 1: Difficulty Selection
├─ Easy (40 clues)
├─ Medium (30 clues)
├─ Hard (25 clues)
└─ Expert (20 clues)
        │
        ▼
Screen 2: Game Board
┌─────────────────────────┐
│ Timer: 5:23  Mistakes: 0│
├─────────────────────────┤
│  9x9 Grid                │
│  ┌───┬───┬───┐          │
│  │5 1│ 3 │ 9 │          │
│  │ 8 │ 5 │ 6 │          │
│  │ 3 │ 8 │ 1 │          │
│  ├───┼───┼───┤          │
│  │...│...│...│          │
├─────────────────────────┤
│ Number Pad: 1-9         │
│ [Notes] [Hint] [Undo]   │
└─────────────────────────┘
        │
        ▼
Screen 3: Victory
├─ Time: 5m 23s
├─ Difficulty: Hard
├─ Hints used: 2
├─ Score: 920
```

### 2.3 Algorithm Design

#### **Puzzle Generator**
```dart
class SudokuGenerator {
  List<List<int>> generate(String difficulty) {
    // 1. Generate a complete solved board
    final board = _generateSolvedBoard();
    
    // 2. Remove cells based on difficulty
    final clues = _getClueCount(difficulty);
    _removeCells(board, 81 - clues);
    
    // 3. Ensure unique solution
    while (!_hasUniqueSolution(board)) {
      _adjustBoard(board);
    }
    
    return board;
  }
  
  List<List<int>> _generateSolvedBoard() {
    final board = List.generate(9, (_) => List.filled(9, 0));
    _fillBoard(board, 0, 0);
    return board;
  }
  
  bool _fillBoard(List<List<int>> board, int row, int col) {
    if (row == 9) return true; // Completed
    if (col == 9) return _fillBoard(board, row + 1, 0);
    
    final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle();
    
    for (final num in numbers) {
      if (_isValid(board, row, col, num)) {
        board[row][col] = num;
        if (_fillBoard(board, row, col + 1)) return true;
        board[row][col] = 0; // Backtrack
      }
    }
    return false;
  }
  
  bool _isValid(List<List<int>> board, int row, int col, int num) {
    // Check row
    if (board[row].contains(num)) return false;
    
    // Check column
    if (board.any((r) => r[col] == num)) return false;
    
    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[boxRow + i][boxCol + j] == num) return false;
      }
    }
    
    return true;
  }
  
  int _getClueCount(String difficulty) {
    switch (difficulty) {
      case 'easy': return 40;
      case 'medium': return 30;
      case 'hard': return 25;
      case 'expert': return 20;
      default: return 30;
    }
  }
}
```

#### **Solver (Backtracking)**
```dart
class SudokuSolver {
  bool solve(List<List<int>> board) {
    return _backtrack(board, 0, 0);
  }
  
  bool _backtrack(List<List<int>> board, int row, int col) {
    if (row == 9) return true;
    if (col == 9) return _backtrack(board, row + 1, 0);
    if (board[row][col] != 0) return _backtrack(board, row, col + 1);
    
    for (int num = 1; num <= 9; num++) {
      if (_isValid(board, row, col, num)) {
        board[row][col] = num;
        if (_backtrack(board, row, col + 1)) return true;
        board[row][col] = 0;
      }
    }
    return false;
  }
  
  // Get hint: Find next solvable cell
  Point<int>? getHint(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          // Find cell with fewest candidates (naked single)
          final candidates = _getCandidates(board, row, col);
          if (candidates.length == 1) {
            return Point(row, col);
          }
        }
      }
    }
    return null;
  }
}
```

### 2.4 Scoring Formula

```dart
int calculateScore(int timeSeconds, int hintsUsed, String difficulty) {
  const baseScore = {
    'easy': 500,
    'medium': 1000,
    'hard': 1500,
    'expert': 2000,
  };
  
  final base = baseScore[difficulty] ?? 1000;
  
  // Penalty for hints (-50 points each)
  final hintPenalty = hintsUsed * 50;
  
  // Time bonus (finish under 10 min = +500)
  final timeBonus = timeSeconds < 600 ? 500 : 0;
  
  // Time penalty (every minute over 10 = -50)
  final timePenalty = max(0, (timeSeconds - 600) ~/ 60) * 50;
  
  return max(100, base - hintPenalty + timeBonus - timePenalty);
}
```

---

## GAME 3: CARO (GOMOKU)

> ⚠️ **CẢNH BÁO**: AI Minimax có thể gây LAG UI!
> ✅ **GIẢI PHÁP BẮT BUỘC**: Dùng `Isolate` (thread của Dart)
> 📝 **Test ngay**: Chạy trên thiết bị thật, không phải emulator

### 3.1 Tổng quan

**Mô tả**: 5-in-a-row game with AI opponent  
**Modes**: vs AI (3 difficulties), vs Player (local/online)  
**Board Size**: 15x15, 19x19  
**Win Condition**: 5 stones in a row (horizontal/vertical/diagonal)  
**Thời gian dự kiến**: 1 tuần  
**Rủi ro**: ⚠️ Trung bình - Cần Isolate cho AI

### 3.2 UI/UX Flow

```
Screen 1: Mode Selection
├─ vs AI (Easy / Medium / Hard)
├─ vs Player (Local)
└─ vs Player (Online) - Challenge friend
        │
        ▼
Screen 2: Game Board
┌──────────────────────────┐
│ You (●) vs AI (○)        │
│ Time: 3:45               │
├──────────────────────────┤
│      15x15 Grid          │
│  ╔═══╦═══╦═══╦═══╗      │
│  ║   ║ ● ║   ║   ║      │
│  ╠═══╬═══╬═══╬═══╣      │
│  ║ ○ ║   ║ ● ║   ║      │
│  ╠═══╬═══╬═══╬═══╣      │
│  ║...║...║...║...║      │
├──────────────────────────┤
│ [Undo] [Hint] [Surrender]│
└──────────────────────────┘
        │
        ▼
Screen 3: Result
├─ Winner: You / AI / Draw
├─ Moves: 45
├─ Time: 3m 45s
├─ Score: 880
```

### 3.3 Algorithm Design - AI (Minimax + Alpha-Beta)

```dart
class CaroAI {
  final int maxDepth;
  
  CaroAI(String difficulty) 
    : maxDepth = difficulty == 'easy' ? 2 : (difficulty == 'medium' ? 4 : 6);
  
  // ⚠️ BẮT BUỘC: Chạy AI trong Isolate để không lag UI
  Future<Point<int>> getBestMoveAsync(List<List<int>> board, int player) async {
    // Chạy AI trong background thread
    final result = await Isolate.run(() => _computeBestMove(board, player));
    return result;
  }
  
  // Hàm này chạy trong Isolate (separate thread)
  static Point<int> _computeBestMove(List<List<int>> board, int player) {
    int bestScore = -999999;
    Point<int>? bestMove;
    
    final candidates = _getCandidateMoves(board);
    
    for (final move in candidates) {
      board[move.x][move.y] = player;
      final score = _minimax(board, maxDepth - 1, false, player, -999999, 999999);
      board[move.x][move.y] = 0;
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove!;
  }
  
  // Version đồng bộ (chỉ dùng cho Easy mode hoặc testing)
  Point<int> getBestMove(List<List<int>> board, int player) {
    return _computeBestMove(board, player);
  }
  
  int _minimax(List<List<int>> board, int depth, bool isMaximizing, 
               int player, int alpha, int beta) {
    // Terminal conditions
    if (depth == 0 || _isGameOver(board)) {
      return _evaluateBoard(board, player);
    }
    
    if (isMaximizing) {
      int maxEval = -999999;
      for (final move in _getCandidateMoves(board)) {
        board[move.x][move.y] = player;
        final eval = _minimax(board, depth - 1, false, player, alpha, beta);
        board[move.x][move.y] = 0;
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break; // Pruning
      }
      return maxEval;
    } else {
      int minEval = 999999;
      final opponent = 3 - player; // Switch player (1 ↔ 2)
      for (final move in _getCandidateMoves(board)) {
        board[move.x][move.y] = opponent;
        final eval = _minimax(board, depth - 1, true, player, alpha, beta);
        board[move.x][move.y] = 0;
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break; // Pruning
      }
      return minEval;
    }
  }
  
  // Heuristic evaluation
  int _evaluateBoard(List<List<int>> board, int player) {
    int score = 0;
    final opponent = 3 - player;
    
    // Check all possible 5-in-a-row patterns
    final patterns = _getAllPatterns(board);
    
    for (final pattern in patterns) {
      final playerCount = pattern.where((p) => p == player).length;
      final opponentCount = pattern.where((p) => p == opponent).length;
      final emptyCount = pattern.where((p) => p == 0).length;
      
      // Scoring logic
      if (playerCount == 5) score += 1000000; // Win
      else if (opponentCount == 5) score -= 1000000; // Lose
      else if (playerCount == 4 && emptyCount == 1) score += 10000; // Open 4
      else if (opponentCount == 4 && emptyCount == 1) score -= 50000; // Block 4
      else if (playerCount == 3 && emptyCount == 2) score += 1000; // Open 3
      else if (playerCount == 2 && emptyCount == 3) score += 100; // Open 2
    }
    
    return score;
  }
  
  // Get candidate moves (only check cells near existing stones)
  List<Point<int>> _getCandidateMoves(List<List<int>> board) {
    final candidates = <Point<int>>{};
    
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[0].length; j++) {
        if (board[i][j] != 0) {
          // Add all empty neighbors (within 2 cells)
          for (int di = -2; di <= 2; di++) {
            for (int dj = -2; dj <= 2; dj++) {
              final ni = i + di, nj = j + dj;
              if (ni >= 0 && ni < board.length && 
                  nj >= 0 && nj < board[0].length &&
                  board[ni][nj] == 0) {
                candidates.add(Point(ni, nj));
              }
            }
          }
        }
      }
    }
    
    return candidates.take(20).toList(); // Limit to 20 best candidates
  }
}
```

### 3.4 Scoring Formula

```dart
int calculateScore(int moves, int timeSeconds, String difficulty, bool isWinner) {
  if (!isWinner) return 0;
  
  const baseScore = {
    'easy': 500,
    'medium': 1000,
    'hard': 2000,
  };
  
  final base = baseScore[difficulty] ?? 1000;
  
  // Bonus for quick wins
  final moveBonus = moves < 30 ? 500 : 0;
  final timeBonus = timeSeconds < 180 ? 300 : 0;
  
  return base + moveBonus + timeBonus;
}
```

---

## GAME 4: PUZZLE (JIGSAW)

### 4.1 Tổng quan

**Mô tả**: Jigsaw puzzle with custom images  
**Piece Count**: 9 (3x3), 16 (4x4), 25 (5x5), 36 (6x6)  
**Features**: Image selection, Snap-to-grid, Preview, Shuffle

### 4.2 UI/UX Flow

```
Screen 1: Setup
├─ Choose Image:
│   ├─ Gallery (device)
│   ├─ Camera
│   └─ Preset images (5 images)
├─ Choose Difficulty:
│   ├─ Easy (3x3 = 9 pieces)
│   ├─ Medium (4x4 = 16 pieces)
│   ├─ Hard (5x5 = 25 pieces)
│   └─ Expert (6x6 = 36 pieces)
        │
        ▼
Screen 2: Game Play
┌─────────────────────────────┐
│ Timer: 2:15  Progress: 45%  │
├─────────────────────────────┤
│  ┌─────────────────┐        │
│  │  Empty Slots    │        │
│  │  [▢][▢][▢][▢]  │        │
│  │  [▢][■][■][▢]  │        │
│  └─────────────────┘        │
│                              │
│  Pieces Tray:               │
│  [🖼️][🖼️][🖼️][🖼️][🖼️]  │
├─────────────────────────────┤
│ [Preview] [Shuffle] [Reset] │
└─────────────────────────────┘
```

### 4.3 Algorithm Design

#### **Image Splitter**
```dart
class PuzzleGenerator {
  List<PuzzlePiece> generatePieces(ui.Image image, int gridSize) {
    final pieces = <PuzzlePiece>[];
    final pieceWidth = image.width / gridSize;
    final pieceHeight = image.height / gridSize;
    
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final piece = PuzzlePiece(
          id: row * gridSize + col,
          correctRow: row,
          correctCol: col,
          image: _cropImage(image, col * pieceWidth, row * pieceHeight, 
                           pieceWidth, pieceHeight),
        );
        pieces.add(piece);
      }
    }
    
    pieces.shuffle();
    return pieces;
  }
  
  ui.Image _cropImage(ui.Image source, double x, double y, double w, double h) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    canvas.drawImageRect(
      source,
      Rect.fromLTWH(x, y, w, h),
      Rect.fromLTWH(0, 0, w, h),
      Paint(),
    );
    
    final picture = recorder.endRecording();
    return picture.toImage(w.toInt(), h.toInt());
  }
}
```

#### **Snap-to-Grid Logic**
```dart
class PuzzleBoard {
  final int gridSize;
  final List<PuzzlePiece?> slots;
  
  PuzzleBoard(this.gridSize) 
    : slots = List.filled(gridSize * gridSize, null);
  
  bool tryPlacePiece(PuzzlePiece piece, Offset position) {
    final slotIndex = _getSlotIndex(position);
    if (slotIndex == -1 || slots[slotIndex] != null) return false;
    
    slots[slotIndex] = piece;
    return true;
  }
  
  int _getSlotIndex(Offset position) {
    final col = (position.dx / _slotWidth).floor();
    final row = (position.dy / _slotHeight).floor();
    
    if (col < 0 || col >= gridSize || row < 0 || row >= gridSize) {
      return -1;
    }
    
    return row * gridSize + col;
  }
  
  bool isComplete() {
    for (int i = 0; i < slots.length; i++) {
      final piece = slots[i];
      if (piece == null || piece.correctRow * gridSize + piece.correctCol != i) {
        return false;
      }
    }
    return true;
  }
  
  double getProgress() {
    int correctPieces = 0;
    for (int i = 0; i < slots.length; i++) {
      final piece = slots[i];
      if (piece != null && piece.correctRow * gridSize + piece.correctCol == i) {
        correctPieces++;
      }
    }
    return correctPieces / slots.length;
  }
}
```

### 4.4 Scoring Formula

```dart
int calculateScore(int timeSeconds, int gridSize, int hints) {
  const baseScore = {
    3: 300,  // 3x3
    4: 600,  // 4x4
    5: 1000, // 5x5
    6: 1500, // 6x6
  };
  
  final base = baseScore[gridSize] ?? 600;
  
  // Time bonus (under 5 min for 4x4)
  final targetTime = gridSize * gridSize * 20; // 20s per piece
  final timeBonus = timeSeconds < targetTime ? 500 : 0;
  
  // Hint penalty
  final hintPenalty = hints * 30;
  
  return max(100, base + timeBonus - hintPenalty);
}
```

---

## COMMON COMPONENTS

### Shared Game Infrastructure

```dart
// lib/models/game_session_model.dart
@HiveType(typeId: 14)
class GameSession {
  @HiveField(0) String id;
  @HiveField(1) String gameType;
  @HiveField(2) String difficulty;
  @HiveField(3) DateTime startTime;
  @HiveField(4) DateTime? endTime;
  @HiveField(5) String status; // 'playing', 'paused', 'completed'
  @HiveField(6) Map<String, dynamic> gameState; // Game-specific state
  @HiveField(7) int moves;
  @HiveField(8) int hintsUsed;
}

// lib/services/game_service.dart
class GameService {
  // Save game session
  Future<void> saveSession(GameSession session) async {
    await DatabaseService.gameSessionsBox.put(session.id, session);
  }
  
  // Resume game
  GameSession? getActiveSession(String gameType) {
    return DatabaseService.gameSessionsBox.values
        .where((s) => s.gameType == gameType && s.status == 'playing')
        .firstOrNull;
  }
  
  // Complete game & calculate score
  Future<GameScoreModel> completeGame(GameSession session) async {
    final timeSpent = session.endTime!.difference(session.startTime).inSeconds;
    final score = _calculateScore(session);
    
    final scoreModel = GameScoreModel(
      id: Uuid().v4(),
      userId: DatabaseService.getUser()?.id ?? 'local',
      gameType: session.gameType,
      score: score,
      attempts: session.moves,
      timestamp: DateTime.now(),
      difficulty: session.difficulty,
      timeSpent: timeSpent,
      isSynced: false,
      syncStatus: 'pending',
      version: 1,
    );
    
    await DatabaseService.saveGameScore(scoreModel);
    return scoreModel;
  }
}
```

---

## 📊IMPLEMENTATION TIMELINE (THỨ TỰ ƯU TIÊN MỚI)

> 🎯 **Chiến lược**: Làm game DỄ trước để tạo momentum!

| Tuần | Task | Games | Rủi ro | Ghi chú |
|------|------|-------|--------|----------|
| **2** | **Sudoku** (DỄ nhất) | Sudoku (100%) | ✅ Thấp | Generator + Solver + UI |
| **3** | **Puzzle** (DỄ thứ 2) | Puzzle (100%) | ✅ Thấp | Image split + Snap logic |
| **4** | **Caro** + Isolate | Caro (100%) | ⚠️ Trung | **NHẬ**: Dùng Isolate cho AI! |
| **5** | **Rubik** (KHÓ nhất) | Rubik (50%) | 🔴 Cao | TÌM PACKAGE, không tự viết |
| **5.5** | Rubik tiếp (nếu cần) | Rubik (100%) | 🔴 Cao | Nếu khó quá → BÁO GIÁO VIÊN |
| **6** | Integration + Fix bugs | All 4 games | ⚠️ Trung | Đảm bảo 4 game chạy ổn |

**Cảnh báo**:
- ⚠️ Nếu Tuần 5 Rubik vẫn fail → **CẦN backup plan ngay**
- ✅ Tuần 2-3 phải hoàn thành Sudoku + Puzzle để có 50% yêu cầu

---

**Version**: 1.0  
**Last Updated**: 18/12/2025
