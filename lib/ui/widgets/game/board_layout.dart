import 'package:flutter/material.dart';

import '../../../models/game_board.dart';
import '../../../services/game_session_service.dart';
import 'column_constraint_row.dart';
import 'playable_grid.dart';
import 'row_constraint_column.dart';

class BoardLayout extends StatelessWidget {
  final GameBoard board;
  final List<LineSnapshot> rowStates;
  final List<LineSnapshot> colStates;
  final int boardVersion;
  final int? focusedRow;
  final int? focusedCol;
  final int bombAnimationToken;
  final int? bombAnimationRow;
  final int? bombAnimationCol;
  final bool locked;
  final double gap;
  final void Function(int row, int col) onTileTap;

  const BoardLayout({
    super.key,
    required this.board,
    required this.rowStates,
    required this.colStates,
    required this.boardVersion,
    required this.focusedRow,
    required this.focusedCol,
    required this.bombAnimationToken,
    required this.bombAnimationRow,
    required this.bombAnimationCol,
    required this.locked,
    required this.gap,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: PlayableGrid(
                  board: board,
                  rowStates: rowStates,
                  colStates: colStates,
                  boardVersion: boardVersion,
                  focusedRow: focusedRow,
                  focusedCol: focusedCol,
                  bombAnimationToken: bombAnimationToken,
                  bombAnimationRow: bombAnimationRow,
                  bombAnimationCol: bombAnimationCol,
                  locked: locked,
                  gap: gap,
                  onTileTap: onTileTap,
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                flex: 1,
                child: RowConstraintColumn(
                  board: board,
                  rowStates: rowStates,
                  focusedRow: focusedRow,
                  gap: gap,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: gap),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: ColumnConstraintRow(
                  board: board,
                  colStates: colStates,
                  focusedCol: focusedCol,
                  gap: gap,
                ),
              ),
              SizedBox(width: gap),
              const Expanded(
                flex: 1,
                child: _BoardCorner(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BoardCorner extends StatelessWidget {
  const _BoardCorner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC9D4E3)),
      ),
      child: const SizedBox.expand(),
    );
  }
}
