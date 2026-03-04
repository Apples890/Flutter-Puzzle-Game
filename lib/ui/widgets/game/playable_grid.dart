import 'package:flutter/material.dart';

import '../../../models/cell.dart';
import '../../../models/game_board.dart';
import '../../../services/game_session_service.dart';
import 'tile_widget.dart';

class PlayableGrid extends StatelessWidget {
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
  final void Function(int row, int col) onTileLongPress;

  const PlayableGrid({
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
    required this.onTileLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final size = board.size;
    final rowChildren = <Widget>[];

    for (int row = 0; row < size; row++) {
      final colChildren = <Widget>[];
      for (int col = 0; col < size; col++) {
        final cell = board.grid[row][col];
        final rowState = rowStates[row];
        final colState = colStates[col];
        final isDimmed = cell.visibility == CellVisibility.hidden &&
            (rowState.bombsExhausted || colState.bombsExhausted);
        final isHighlighted = focusedRow == row || focusedCol == col;
        final isLineComplete = rowState.isComplete || colState.isComplete;

        colChildren.add(
          Expanded(
            child: TileWidget(
              key: ValueKey('tile-$boardVersion-$row-$col'),
              cell: cell,
              onTap: locked ? null : () => onTileTap(row, col),
              onLongPress: locked ? null : () => onTileLongPress(row, col),
              highlighted: isHighlighted,
              dimmed: isDimmed,
              completedLine: isLineComplete,
              playBombAnimation: bombAnimationToken > 0 &&
                  bombAnimationRow == row &&
                  bombAnimationCol == col,
            ),
          ),
        );

        if (col < size - 1) {
          colChildren.add(SizedBox(width: gap));
        }
      }

      rowChildren.add(
        Expanded(
          child: Row(children: colChildren),
        ),
      );
      if (row < size - 1) {
        rowChildren.add(SizedBox(height: gap));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD2E0F1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rowChildren,
        ),
      ),
    );
  }
}
