import 'cell.dart';

class GameBoard {
  final int size;
  late List<List<Cell>> grid;
  late List<int> rowSums;
  late List<int> colSums;
  late List<int> rowBombCounts;
  late List<int> colBombCounts;

  GameBoard({required this.size});

  GameBoard clone() {
    final copy = GameBoard(size: size);
    copy.grid =
        grid.map((row) => row.map((cell) => cell.clone()).toList()).toList();
    copy.rowSums = List<int>.from(rowSums);
    copy.colSums = List<int>.from(colSums);
    copy.rowBombCounts = List<int>.from(rowBombCounts);
    copy.colBombCounts = List<int>.from(colBombCounts);
    return copy;
  }
}
