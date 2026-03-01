
import 'dart:math';
import '../models/game_board.dart';
import '../models/cell.dart';

class BoardGenerator {
  static GameBoard generate(int size, int bombCount, int minVal, int maxVal) {
    final random = Random();
    final board = GameBoard(size: size);

    board.grid = List.generate(
      size,
      (_) => List.generate(size, (_) => Cell(isBomb: false, value: 0)),
    );

    int bombsPlaced = 0;
    while (bombsPlaced < bombCount) {
      int r = random.nextInt(size);
      int c = random.nextInt(size);
      if (!board.grid[r][c].isBomb) {
        board.grid[r][c] = Cell(isBomb: true, value: 0);
        bombsPlaced++;
      }
    }

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (!board.grid[r][c].isBomb) {
          board.grid[r][c] = Cell(
            isBomb: false,
            value: minVal + random.nextInt(maxVal - minVal + 1),
          );
        }
      }
    }

    board.rowSums = List.filled(size, 0);
    board.colSums = List.filled(size, 0);
    board.rowBombCounts = List.filled(size, 0);
    board.colBombCounts = List.filled(size, 0);

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final cell = board.grid[r][c];
        if (cell.isBomb) {
          board.rowBombCounts[r]++;
          board.colBombCounts[c]++;
        } else {
          board.rowSums[r] += cell.value;
          board.colSums[c] += cell.value;
        }
      }
    }

    return board;
  }
}
