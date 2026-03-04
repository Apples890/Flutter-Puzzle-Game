import 'package:flutter/material.dart';

class GameHeader extends StatelessWidget {
  final int score;
  final VoidCallback onReset;

  const GameHeader({
    super.key,
    required this.score,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Score',
                style: TextStyle(
                  color: Color(0xFF9FB6CF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: score.toDouble()),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Text(
                    value.round().toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Logic Bomb',
              style: titleStyle,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x1FFFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded, color: Colors.white),
                tooltip: 'Reset run',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
