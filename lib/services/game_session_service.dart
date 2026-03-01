import '../core/constants.dart';
import '../models/cell.dart';
import '../models/game_board.dart';
import 'board_generator.dart';

enum RevealType { ignored, safe, bomb, levelComplete }

class RevealResult {
  final RevealType type;
  final int value;

  const RevealResult(this.type, {this.value = 0});

  bool get changed => type != RevealType.ignored;
  bool get hitBomb => type == RevealType.bomb;
  bool get completedLevel => type == RevealType.levelComplete;
}

class LineSnapshot {
  final int safeSum;
  final int bombsRevealed;
  final int hiddenCount;
  final int revealedCount;
  final bool bombsExhausted;
  final bool isComplete;

  const LineSnapshot({
    required this.safeSum,
    required this.bombsRevealed,
    required this.hiddenCount,
    required this.revealedCount,
    required this.bombsExhausted,
    required this.isComplete,
  });
}

class GameSessionService {
  final int boardSize;
  final int bombCount;

  late GameBoard board;
  int level = 1;
  int points = 0;
  bool gameOver = false;
  bool levelComplete = false;
  int boardVersion = 0;

  int _safeRevealed = 0;
  late int _safeTotal;

  GameSessionService({
    this.boardSize = AppConstants.boardSize,
    this.bombCount = 7,
  }) {
    startRun();
  }

  void startRun({bool resetLevel = false}) {
    if (resetLevel) level = 1;
    _buildBoard();
    points = 0;
    gameOver = false;
    levelComplete = false;
    _safeRevealed = 0;
    _safeTotal = boardSize * boardSize - bombCount;
  }

  void restartLevel() {
    _buildBoard();
    points = 0;
    gameOver = false;
    levelComplete = false;
    _safeRevealed = 0;
  }

  void moveToNextLevel() {
    level += 1;
    startRun();
  }

  RevealResult revealCell(int row, int col) {
    if (gameOver || levelComplete) {
      return const RevealResult(RevealType.ignored);
    }

    final cell = board.grid[row][col];
    if (cell.visibility != CellVisibility.hidden) {
      return const RevealResult(RevealType.ignored);
    }

    cell.visibility = CellVisibility.revealed;
    if (cell.isBomb) {
      gameOver = true;
      return const RevealResult(RevealType.bomb);
    }

    points += cell.value;
    _safeRevealed += 1;

    if (_safeRevealed >= _safeTotal) {
      levelComplete = true;
      return RevealResult(RevealType.levelComplete, value: cell.value);
    }

    return RevealResult(RevealType.safe, value: cell.value);
  }

  LineSnapshot rowSnapshot(int row) {
    int safeSum = 0;
    int bombsRevealed = 0;
    int revealedCount = 0;
    int hiddenCount = 0;

    for (final cell in board.grid[row]) {
      if (cell.visibility == CellVisibility.hidden) {
        hiddenCount += 1;
      } else {
        revealedCount += 1;
        if (cell.isBomb) {
          bombsRevealed += 1;
        } else {
          safeSum += cell.value;
        }
      }
    }

    final targetBombs = board.rowBombCounts[row];
    final targetSum = board.rowSums[row];
    final remainingBombs = targetBombs - bombsRevealed;
    final bombsExhausted =
        remainingBombs <= 0 || hiddenCount == remainingBombs || safeSum == targetSum;
    final isComplete = safeSum == targetSum || hiddenCount == 0;

    return LineSnapshot(
      safeSum: safeSum,
      bombsRevealed: bombsRevealed,
      hiddenCount: hiddenCount,
      revealedCount: revealedCount,
      bombsExhausted: bombsExhausted,
      isComplete: isComplete,
    );
  }

  LineSnapshot colSnapshot(int col) {
    int safeSum = 0;
    int bombsRevealed = 0;
    int revealedCount = 0;
    int hiddenCount = 0;

    for (int row = 0; row < board.size; row++) {
      final cell = board.grid[row][col];
      if (cell.visibility == CellVisibility.hidden) {
        hiddenCount += 1;
      } else {
        revealedCount += 1;
        if (cell.isBomb) {
          bombsRevealed += 1;
        } else {
          safeSum += cell.value;
        }
      }
    }

    final targetBombs = board.colBombCounts[col];
    final targetSum = board.colSums[col];
    final remainingBombs = targetBombs - bombsRevealed;
    final bombsExhausted =
        remainingBombs <= 0 || hiddenCount == remainingBombs || safeSum == targetSum;
    final isComplete = safeSum == targetSum || hiddenCount == 0;

    return LineSnapshot(
      safeSum: safeSum,
      bombsRevealed: bombsRevealed,
      hiddenCount: hiddenCount,
      revealedCount: revealedCount,
      bombsExhausted: bombsExhausted,
      isComplete: isComplete,
    );
  }

  void _buildBoard() {
    board = BoardGenerator.generate(
      boardSize,
      bombCount,
      1,
      3 + level,
    );
    boardVersion += 1;
  }
}
