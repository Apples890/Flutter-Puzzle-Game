import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/cell.dart';

class TileWidget extends StatefulWidget {
  final Cell cell;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool highlighted;
  final bool dimmed;
  final bool completedLine;
  final bool playBombAnimation;

  const TileWidget({
    super.key,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
    required this.highlighted,
    required this.dimmed,
    required this.completedLine,
    required this.playBombAnimation,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bombController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _bombController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    if (widget.playBombAnimation) {
      _bombController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.playBombAnimation && widget.playBombAnimation) {
      _bombController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bombController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRevealed = widget.cell.visibility == CellVisibility.revealed;
    final hiddenFace = _buildHiddenFace();
    final revealedFace = _buildRevealedFace();

    return AnimatedBuilder(
      animation: _bombController,
      builder: (context, _) {
        final bombT = _bombController.value;
        final shake = math.sin(bombT * math.pi * 10) * (1 - bombT) * 6;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            scale: _pressed ? 0.96 : 1.0,
            child: GestureDetector(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress == null
                  ? null
                  : () {
                      setState(() => _pressed = false);
                      widget.onLongPress?.call();
                    },
              onTapDown: widget.onTap == null
                  ? null
                  : (_) => setState(() => _pressed = true),
              onTapCancel: widget.onTap == null
                  ? null
                  : () => setState(() => _pressed = false),
              onTapUp: widget.onTap == null
                  ? null
                  : (_) => setState(() => _pressed = false),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: widget.dimmed
                    ? 0.56
                    : widget.completedLine
                        ? 0.82
                        : 1,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(end: isRevealed ? 1 : 0),
                  builder: (context, revealT, _) {
                    final angle = revealT * math.pi;
                    final showingFront = angle <= (math.pi / 2);
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: showingFront
                          ? hiddenFace
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _bombPulseWrapper(revealedFace, bombT),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bombPulseWrapper(Widget child, double t) {
    if (!widget.cell.isBomb) return child;
    final pulse = (math.sin(t * math.pi * 5) + 1) / 2;
    final base = const Color(0xFFD93636);
    final glow = Color.lerp(base, const Color(0xFFFF8A80), pulse * 0.6)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: glow.withOpacity(0.45),
            blurRadius: 12 + (pulse * 6),
            spreadRadius: pulse * 2,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHiddenFace() {
    final isFlagged = widget.cell.visibility == CellVisibility.flagged;
    final borderColor =
        isFlagged ? const Color(0xFFF0C671) : widget.highlighted ? const Color(0xFF7CA9E6) : const Color(0xFFC6D8F0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isFlagged
            ? const Color(0xFFF6EED9)
            : widget.highlighted
                ? const Color(0xFFDCEAFF)
                : const Color(0xFFE9F1FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          const SizedBox.expand(),
          if (isFlagged)
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(
                Icons.flag_outlined,
                size: 14,
                color: Color(0xFFB98C2E),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRevealedFace() {
    final Color bgColor;
    final Widget content;

    if (widget.cell.isBomb) {
      bgColor = const Color(0xFFD93636);
      content = const Icon(Icons.bolt_rounded, size: 24, color: Colors.white);
    } else {
      bgColor = const Color(0xFFFDFEFF);
      content = Text(
        widget.cell.value.toString(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF0E2D52),
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.cell.isBomb
              ? const Color(0xFFFF8A80)
              : const Color(0xFFD2E1F4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: content),
    );
  }
}
