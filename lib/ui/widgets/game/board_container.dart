import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/game_board.dart';
import '../../../services/game_session_service.dart';
import 'board_layout.dart';

class BoardContainer extends StatelessWidget {
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
  final void Function(int row, int col) onTileTap;

  const BoardContainer({
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
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final side = math.max(0.0, math.min(constraints.maxWidth, constraints.maxHeight));

        return Center(
          child: SizedBox.square(
            dimension: side,
            child: BoardLayout(
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
        );
      },
    );
  }
}
