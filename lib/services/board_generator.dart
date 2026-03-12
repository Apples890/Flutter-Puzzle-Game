import 'dart:math';

import '../models/cell.dart';
import '../models/game_board.dart';
import 'board_integrity_tools.dart';
import 'board_solver.dart';
import 'level_curve_service.dart';

class BoardGenerator {
  static GameBoard generate(int size, int bombCount, int minVal, int maxVal) {
    final random = Random();
    GameBoard board;

    do {
      board = _generateClassicCandidate(
        size: size,
        bombCount: bombCount,
        minVal: minVal,
        maxVal: maxVal,
        random: random,
      );
    } while (!validateBoardIntegrity(board));

    assert(validateBoardIntegrity(board));
    return board;
  }

  static GameBoard generateForLevel(
    int size,
    int level, {
    int maxAttempts = 4000,
  }) {
    final random = Random();
    final config = LevelCurveService.configForLevel(level);
    final maxBombsPerRow = LevelCurveService.maxBombsPerRowForLevel(level);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final totalBombs = _randInRange(
        random,
        config.minTotalBombs,
        config.maxTotalBombs,
      );

      final rowBombCounts = _buildRowBombTargets(
        size: size,
        totalBombs: totalBombs,
        maxBombsPerRow: maxBombsPerRow,
        zeroBombRowProbability: config.zeroBombRowProbability,
        fourBombRowProbability: config.fourBombRowProbability,
        random: random,
      );
      if (rowBombCounts == null) continue;

      final values = List.generate(
        size,
        (_) => List.generate(
          size,
          (_) => _randInRange(random, config.minSafeValue, config.maxSafeValue),
        ),
      );

      final isBomb = List.generate(size, (_) => List.filled(size, false));
      for (int r = 0; r < size; r++) {
        final cols = List<int>.generate(size, (i) => i)..shuffle(random);
        for (int i = 0; i < rowBombCounts[r]; i++) {
          isBomb[r][cols[i]] = true;
        }
      }

      final board = GameBoard(size: size);
      _populateBoard(board, values, isBomb);

      if (_rowSumExceeded(board, config.maxRowSum)) continue;
      if (!validateBoardIntegrity(board)) continue;
      if (BoardSolver.countSolutions(board, maxSolutions: 2) != 1) continue;

      assert(validateBoardIntegrity(board));
      return board;
    }

    throw StateError(
      'Unable to generate uniquely solvable board for level $level',
    );
  }

  static int _randInRange(Random random, int min, int max) {
    return min + random.nextInt(max - min + 1);
  }

  static GameBoard _generateClassicCandidate({
    required int size,
    required int bombCount,
    required int minVal,
    required int maxVal,
    required Random random,
  }) {
    final board = GameBoard(size: size);
    final values = List.generate(
      size,
      (_) => List.generate(
        size,
        (_) => minVal + random.nextInt(maxVal - minVal + 1),
      ),
    );

    final isBomb = List.generate(size, (_) => List.filled(size, false));
    int bombsPlaced = 0;
    while (bombsPlaced < bombCount) {
      final r = random.nextInt(size);
      final c = random.nextInt(size);
      if (!isBomb[r][c]) {
        isBomb[r][c] = true;
        bombsPlaced++;
      }
    }

    _populateBoard(board, values, isBomb);
    return board;
  }

  static void _populateBoard(
    GameBoard board,
    List<List<int>> values,
    List<List<bool>> isBomb,
  ) {
    final size = board.size;
    board.grid = List.generate(size, (r) {
      return List.generate(size, (c) {
        return Cell(isBomb: isBomb[r][c], value: values[r][c]);
      });
    });

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
  }

  static bool _rowSumExceeded(GameBoard board, int maxRowSum) {
    for (final sum in board.rowSums) {
      if (sum > maxRowSum) return true;
    }
    return false;
  }

  static List<int>? _buildRowBombTargets({
    required int size,
    required int totalBombs,
    required int maxBombsPerRow,
    required double zeroBombRowProbability,
    required double fourBombRowProbability,
    required Random random,
  }) {
    final rowCounts = List.filled(size, -1);

    for (int r = 0; r < size; r++) {
      if (random.nextDouble() < zeroBombRowProbability) {
        rowCounts[r] = 0;
      }
    }

    if (maxBombsPerRow >= 4) {
      for (int r = 0; r < size; r++) {
        if (rowCounts[r] != -1) continue;
        if (random.nextDouble() < fourBombRowProbability) {
          rowCounts[r] = 4;
        }
      }
    }

    int fixedBombs = 0;
    int remainingRows = 0;
    for (final count in rowCounts) {
      if (count >= 0) {
        fixedBombs += count;
      } else {
        remainingRows++;
      }
    }

    final maxPossible = fixedBombs + (remainingRows * maxBombsPerRow);
    if (totalBombs < fixedBombs || totalBombs > maxPossible) return null;

    int bombsLeft = totalBombs - fixedBombs;
    final openRows = <int>[];
    for (int r = 0; r < size; r++) {
      if (rowCounts[r] == -1) {
        rowCounts[r] = 0;
        openRows.add(r);
      }
    }

    while (bombsLeft > 0) {
      final candidates = <int>[];
      for (final r in openRows) {
        if (rowCounts[r] < maxBombsPerRow) {
          candidates.add(r);
        }
      }
      if (candidates.isEmpty) return null;

      final row = candidates[random.nextInt(candidates.length)];
      rowCounts[row] += 1;
      bombsLeft -= 1;
    }

    return rowCounts;
  }
}
