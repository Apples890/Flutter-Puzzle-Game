import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/game_session_service.dart';
import '../../services/stats_service.dart';
import '../../services/board_integrity_tools.dart';
import '../widgets/game/board_container.dart';
import '../widgets/game/game_header.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final GameSessionService _session = GameSessionService();

  int? _focusedRow;
  int? _focusedCol;
  int? _animatedBombRow;
  int? _animatedBombCol;
  int _bombAnimationToken = 0;

  Timer? _focusTimer;
  late final AnimationController _loseShakeController;
  late final AnimationController _winGlowController;

  @override
  void initState() {
    super.initState();
    _loseShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _winGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _loseShakeController.dispose();
    _winGlowController.dispose();
    super.dispose();
  }

  void _onTileTap(int row, int col) {
    final result = _session.revealCell(row, col);
    if (!result.changed) {
      _pulseFocus(row, col);
      return;
    }

    if (result.hitBomb) {
      HapticFeedback.heavyImpact();
      unawaited(StatsService.updateHighScore(_session.points));
      unawaited(StatsService.updateHighestLevel(_session.level));
      _triggerLoseVisuals(row, col);
    } else {
      HapticFeedback.selectionClick();
      unawaited(StatsService.updateHighScore(_session.points));
      if (result.completedLevel) {
        unawaited(StatsService.updateHighestLevel(_session.level));
        _triggerWinVisuals();
      }
    }

    setState(() {
      if (result.hitBomb) {
        _animatedBombRow = row;
        _animatedBombCol = col;
        _bombAnimationToken += 1;
      }
    });
    _pulseFocus(row, col);
  }

  void _onTileLongPress(int row, int col) {
    final result = _session.toggleFlag(row, col);
    if (!result.changed) {
      _pulseFocus(row, col);
      return;
    }

    HapticFeedback.lightImpact();
    if (result.completedLevel) {
      unawaited(StatsService.updateHighestLevel(_session.level));
      _triggerWinVisuals();
    }

    setState(() {});
    _pulseFocus(row, col);
  }

  void _pulseFocus(int row, int col) {
    _focusTimer?.cancel();
    setState(() {
      _focusedRow = row;
      _focusedCol = col;
    });
    _focusTimer = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() {
        _focusedRow = null;
        _focusedCol = null;
      });
    });
  }

  void _triggerLoseVisuals(int row, int col) {
    _loseShakeController.forward(from: 0);
    _animatedBombRow = row;
    _animatedBombCol = col;
  }

  void _triggerWinVisuals() {
    _winGlowController.forward(from: 0);
  }

  void _resetRun() {
    setState(() {
      _session.startRun(resetLevel: true);
      _clearVisualState();
    });
  }

  void _retryLayer() {
    setState(() {
      _session.restartLevel();
      _clearVisualState();
    });
  }

  void _nextLayer() {
    setState(() {
      _session.moveToNextLevel();
      _clearVisualState();
    });
  }

  void _clearVisualState() {
    _focusTimer?.cancel();
    _focusedRow = null;
    _focusedCol = null;
    _animatedBombRow = null;
    _animatedBombCol = null;
    _loseShakeController.value = 0;
    _winGlowController.value = 0;
  }

  void _debugRevealBoard() {
    setState(() {
      revealEntireBoard(_session.board);
    });
    printBoard(_session.board);
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
                  onDebugReveal: kDebugMode ? _debugRevealBoard : null,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _pill('Layer ${_session.level}'),
                      _pill('${_session.totalBombs} bombs'),
                      _pill(
                        _session.levelComplete
                            ? 'Layer Cleared'
                            : _session.gameOver
                            ? 'System Failed'
                            : 'Deduce',
                        accent: _session.levelComplete || _session.gameOver,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildBoardRegion(rowStates, colStates)),
                const SizedBox(height: 16),
                _buildFooterAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoardRegion(
    List<LineSnapshot> rowStates,
    List<LineSnapshot> colStates,
  ) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _loseShakeController,
              _winGlowController,
            ]),
            builder: (context, _) {
              final shakeT = _loseShakeController.value;
              final shakeX = math.sin(shakeT * math.pi * 7) * (1 - shakeT) * 10;
              final glowT = _winGlowController.value;
              final double glowPulse =
                  (math.sin(glowT * math.pi)).clamp(0.0, 1.0).toDouble();
              final glowColor = const Color(
                0x8847C08B,
              ).withOpacity(glowPulse * 0.6);

              return Transform.translate(
                offset: Offset(shakeX, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      if (glowPulse > 0)
                        BoxShadow(
                          color: glowColor,
                          blurRadius: 20 + (glowPulse * 22),
                          spreadRadius: glowPulse * 3,
                        ),
                    ],
                  ),
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
                    emphasizeConstraints: _session.levelComplete,
                    onTileTap: _onTileTap,
                    onTileLongPress: _onTileLongPress,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _session.gameOver ? 0.28 : 0,
              child: Container(color: Colors.black),
            ),
          ),
        ),
        if (_session.gameOver || _session.levelComplete)
          Center(
            child: _BoardStatusOverlay(
              title: _session.gameOver ? 'System Failed' : 'Layer Cleared',
              subtitle:
                  _session.levelComplete ? 'Security Node Deactivated' : null,
            ),
          ),
      ],
    );
  }

  Widget _buildFooterAction() {
    if (_session.levelComplete) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _nextLayer,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Next layer'),
        ),
      );
    }

    if (_session.gameOver) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _retryLayer,
          icon: const Icon(Icons.replay_rounded),
          label: const Text('Retry layer'),
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

class _BoardStatusOverlay extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _BoardStatusOverlay({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xA6112133),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x66FFFFFF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: Color(0xFFD1E2F4),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
