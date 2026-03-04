import 'package:flutter/material.dart';

import '../../../models/game_board.dart';
import '../../../services/game_session_service.dart';
import 'constraint_tile.dart';

class RowConstraintColumn extends StatelessWidget {
  final GameBoard board;
  final List<LineSnapshot> rowStates;
  final int? focusedRow;
  final bool emphasizeAll;
  final double gap;

  const RowConstraintColumn({
    super.key,
    required this.board,
    required this.rowStates,
    required this.focusedRow,
    required this.emphasizeAll,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int row = 0; row < board.size; row++) {
      children.add(
        Expanded(
          child: ConstraintTile(
            sumValue: board.rowSums[row],
            bombValue: board.rowBombCounts[row],
            highlighted: focusedRow == row,
            completed: rowStates[row].isComplete || emphasizeAll,
          ),
        ),
      );
      if (row < board.size - 1) {
        children.add(SizedBox(height: gap));
      }
    }

    return Column(children: children);
  }
}
