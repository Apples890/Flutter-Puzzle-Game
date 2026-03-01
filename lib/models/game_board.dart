
import 'cell.dart';

class GameBoard {
  final int size;
  late List<List<Cell>> grid;
  late List<int> rowSums;
  late List<int> colSums;
  late List<int> rowBombCounts;
  late List<int> colBombCounts;

  GameBoard({required this.size});
}
