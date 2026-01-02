class SudokuSolver {
  /// Kiểm tra số hợp lệ tại vị trí
  static bool isValid(List<List<int>> board, int row, int col, int num) {
    // Kiểm tra hàng
    for (int x = 0; x < 9; x++) {
      if (board[row][x] == num) return false;
    }
    
    // Kiểm tra cột
    for (int x = 0; x < 9; x++) {
      if (board[x][col] == num) return false;
    }
    
    // Kiểm tra ô 3x3
    final startRow = row - (row % 3);
    final startCol = col - (col % 3);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i + startRow][j + startCol] == num) return false;
      }
    }
    
    return true;
  }

  /// Giải Sudoku bằng backtracking
  static bool solve(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (isValid(board, row, col, num)) {
              board[row][col] = num;
              
              if (solve(board)) {
                return true;
              }
              
              board[row][col] = 0; // Backtrack
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Copy board
  static List<List<int>> copyBoard(List<List<int>> board) {
    return board.map((row) => List<int>.from(row)).toList();
  }

  /// Chuyển mảng 1D -> 2D
  static List<List<int>> to2D(List<int> flat) {
    final board = <List<int>>[];
    for (int i = 0; i < 9; i++) {
      board.add(flat.sublist(i * 9, i * 9 + 9));
    }
    return board;
  }

  /// Chuyển mảng 2D -> 1D
  static List<int> to1D(List<List<int>> board) {
    return board.expand((row) => row).toList();
  }
}