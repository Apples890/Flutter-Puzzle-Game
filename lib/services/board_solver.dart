import '../models/game_board.dart';

class BoardSolver {
  static int countSolutions(
    GameBoard board, {
    int maxSolutions = 2,
  }) {
    final size = board.size;
    final rowBombUsed = List.filled(size, 0);
    final colBombUsed = List.filled(size, 0);
    final rowSafeSumUsed = List.filled(size, 0);
    final colSafeSumUsed = List.filled(size, 0);

    final rowRemainingValues = List.generate(size, (_) => List.filled(size + 1, 0));
    final colRemainingValues = List.generate(size, (_) => List.filled(size + 1, 0));

    for (int r = 0; r < size; r++) {
      for (int c = size - 1; c >= 0; c--) {
        rowRemainingValues[r][c] =
            rowRemainingValues[r][c + 1] + board.grid[r][c].value;
      }
    }
    for (int c = 0; c < size; c++) {
      for (int r = size - 1; r >= 0; r--) {
        colRemainingValues[c][r] =
            colRemainingValues[c][r + 1] + board.grid[r][c].value;
      }
    }

    int solutions = 0;

    bool canStillMatch({
      required int r,
      required int c,
      required int rowBombs,
      required int colBombs,
      required int rowSafe,
      required int colSafe,
    }) {
      final rowBombTarget = board.rowBombCounts[r];
      final colBombTarget = board.colBombCounts[c];
      final rowSumTarget = board.rowSums[r];
      final colSumTarget = board.colSums[c];

      final rowCellsLeft = size - c - 1;
      final colCellsLeft = size - r - 1;

      if (rowBombs > rowBombTarget || colBombs > colBombTarget) return false;
      if (rowBombs + rowCellsLeft < rowBombTarget) return false;
      if (colBombs + colCellsLeft < colBombTarget) return false;

      if (rowSafe > rowSumTarget || colSafe > colSumTarget) return false;
      if (rowSafe + rowRemainingValues[r][c + 1] < rowSumTarget) return false;
      if (colSafe + colRemainingValues[c][r + 1] < colSumTarget) return false;

      if (c == size - 1 &&
          (rowBombs != rowBombTarget || rowSafe != rowSumTarget)) {
        return false;
      }
      if (r == size - 1 &&
          (colBombs != colBombTarget || colSafe != colSumTarget)) {
        return false;
      }

      return true;
    }

    void search(int index) {
      if (solutions >= maxSolutions) return;
      if (index == size * size) {
        solutions += 1;
        return;
      }

      final r = index ~/ size;
      final c = index % size;
      final value = board.grid[r][c].value;

      final bombRow = rowBombUsed[r] + 1;
      final bombCol = colBombUsed[c] + 1;
      if (canStillMatch(
        r: r,
        c: c,
        rowBombs: bombRow,
        colBombs: bombCol,
        rowSafe: rowSafeSumUsed[r],
        colSafe: colSafeSumUsed[c],
      )) {
        rowBombUsed[r] = bombRow;
        colBombUsed[c] = bombCol;
        search(index + 1);
        rowBombUsed[r] -= 1;
        colBombUsed[c] -= 1;
      }

      final safeRow = rowSafeSumUsed[r] + value;
      final safeCol = colSafeSumUsed[c] + value;
      if (canStillMatch(
        r: r,
        c: c,
        rowBombs: rowBombUsed[r],
        colBombs: colBombUsed[c],
        rowSafe: safeRow,
        colSafe: safeCol,
      )) {
        rowSafeSumUsed[r] = safeRow;
        colSafeSumUsed[c] = safeCol;
        search(index + 1);
        rowSafeSumUsed[r] -= value;
        colSafeSumUsed[c] -= value;
      }
    }

    search(0);
    return solutions;
  }
}
