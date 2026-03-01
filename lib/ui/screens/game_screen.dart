import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/game_session_service.dart';
import '../../services/stats_service.dart';
import '../widgets/game/board_container.dart';
import '../widgets/game/game_header.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameSessionService _session = GameSessionService();

  int? _focusedRow;
  int? _focusedCol;
  int? _animatedBombRow;
  int? _animatedBombCol;
  int _bombAnimationToken = 0;

  void _onTileTap(int row, int col) {
    final result = _session.revealCell(row, col);
    if (!result.changed) {
      setState(() {
        _focusedRow = row;
        _focusedCol = col;
      });
      return;
    }

    if (result.hitBomb) {
      HapticFeedback.heavyImpact();
      unawaited(StatsService.updateHighScore(_session.points));
      unawaited(StatsService.updateHighestLevel(_session.level));
    } else {
      HapticFeedback.selectionClick();
      unawaited(StatsService.updateHighScore(_session.points));
      if (result.completedLevel) {
        unawaited(StatsService.updateHighestLevel(_session.level));
      }
    }

    setState(() {
      _focusedRow = row;
      _focusedCol = col;
      if (result.hitBomb) {
        _animatedBombRow = row;
        _animatedBombCol = col;
        _bombAnimationToken += 1;
      }
    });
  }

  void _resetRun() {
    setState(() {
      _session.startRun(resetLevel: true);
      _clearFocus();
    });
  }

  void _retryLevel() {
    setState(() {
      _session.restartLevel();
      _clearFocus();
    });
  }

  void _nextLevel() {
    setState(() {
      _session.moveToNextLevel();
      _clearFocus();
    });
  }

  void _clearFocus() {
    _focusedRow = null;
    _focusedCol = null;
    _animatedBombRow = null;
    _animatedBombCol = null;
  }

  @override
  Widget build(BuildContext context) {
    final rowStates = List.generate(_session.board.size, _session.rowSnapshot);
    final colStates = List.generate(_session.board.size, _session.colSnapshot);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF08121E), Color(0xFF12293F), Color(0xFF1A3552)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GameHeader(
                  score: _session.points,
                  onReset: _resetRun,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _pill('Level ${_session.level}'),
                      _pill('${_session.bombCount} bombs'),
                      _pill(
                        _session.levelComplete
                            ? 'Solved'
                            : _session.gameOver
                                ? 'Bombed'
                                : 'Deduce',
                        accent: _session.levelComplete || _session.gameOver,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BoardContainer(
                    board: _session.board,
                    rowStates: rowStates,
                    colStates: colStates,
                    boardVersion: _session.boardVersion,
                    focusedRow: _focusedRow,
                    focusedCol: _focusedCol,
                    bombAnimationToken: _bombAnimationToken,
                    bombAnimationRow: _animatedBombRow,
                    bombAnimationCol: _animatedBombCol,
                    locked: _session.gameOver || _session.levelComplete,
                    onTileTap: _onTileTap,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFooterAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterAction() {
    if (_session.levelComplete) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _nextLevel,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Next level'),
        ),
      );
    }

    if (_session.gameOver) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _retryLevel,
          icon: const Icon(Icons.replay_rounded),
          label: const Text('Retry level'),
        ),
      );
    }

    return const SizedBox(
      width: double.infinity,
      child: Text(
        'Use row and column constraints to deduce safe cells.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFB7CCE2),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _pill(String label, {bool accent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent ? const Color(0x3347C08B) : const Color(0x24FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent ? const Color(0xFF47C08B) : const Color(0x33FFFFFF),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
