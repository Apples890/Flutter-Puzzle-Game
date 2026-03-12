import 'dart:developer' as dev;

import '../models/cell.dart';
import '../models/game_board.dart';

bool validateBoardIntegrity(GameBoard board) {
  try {
    final size = board.size;
    if (board.grid.length != size ||
        board.rowSums.length != size ||
        board.colSums.length != size ||
        board.rowBombCounts.length != size ||
        board.colBombCounts.length != size) {
      return false;
    }

    for (final row in board.grid) {
      if (row.length != size) return false;
    }

    for (int r = 0; r < size; r++) {
      int safeSum = 0;
      int bombCount = 0;
      for (int c = 0; c < size; c++) {
        final cell = board.grid[r][c];
        if (cell.isBomb) {
          bombCount += 1;
        } else {
          safeSum += cell.value;
        }
      }

      if (safeSum != board.rowSums[r]) return false;
      if (bombCount != board.rowBombCounts[r]) return false;
    }

    for (int c = 0; c < size; c++) {
      int safeSum = 0;
      int bombCount = 0;
      for (int r = 0; r < size; r++) {
        final cell = board.grid[r][c];
        if (cell.isBomb) {
          bombCount += 1;
        } else {
          safeSum += cell.value;
        }
      }

      if (safeSum != board.colSums[c]) return false;
      if (bombCount != board.colBombCounts[c]) return false;
    }

    return true;
  } on Object {
    return false;
  }
}

void revealEntireBoard(GameBoard board) {
  for (final row in board.grid) {
    for (final cell in row) {
      cell.visibility = CellVisibility.revealed;
    }
  }
}

void printBoard(GameBoard board) {
  for (final row in board.grid) {
    final values = row
        .map((cell) => cell.isBomb ? 'B' : cell.value.toString())
        .join(' ');
    dev.log(values, name: 'LogicBombBoard');
  }
}
