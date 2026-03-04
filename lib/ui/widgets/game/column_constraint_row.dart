import 'package:flutter/material.dart';

import '../../../models/game_board.dart';
import '../../../services/game_session_service.dart';
import 'constraint_tile.dart';

class ColumnConstraintRow extends StatelessWidget {
  final GameBoard board;
  final List<LineSnapshot> colStates;
  final int? focusedCol;
  final bool emphasizeAll;
  final double gap;

  const ColumnConstraintRow({
    super.key,
    required this.board,
    required this.colStates,
    required this.focusedCol,
    required this.emphasizeAll,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int col = 0; col < board.size; col++) {
      children.add(
        Expanded(
          child: ConstraintTile(
            sumValue: board.colSums[col],
            bombValue: board.colBombCounts[col],
            highlighted: focusedCol == col,
            completed: colStates[col].isComplete || emphasizeAll,
          ),
        ),
      );
      if (col < board.size - 1) {
        children.add(SizedBox(width: gap));
      }
    }

    return Row(children: children);
  }
}
