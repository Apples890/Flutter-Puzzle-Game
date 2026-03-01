import 'package:flutter/material.dart';

class ConstraintTile extends StatelessWidget {
  final int sumValue;
  final int bombValue;
  final bool highlighted;
  final bool completed;

  const ConstraintTile({
    super.key,
    required this.sumValue,
    required this.bombValue,
    required this.highlighted,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final base = completed
        ? const Color(0xFFD8F5E8)
        : highlighted
            ? const Color(0xFFDEEAFA)
            : const Color(0xFFEAF0F8);

    final border =
        completed ? const Color(0xFF64B88E) : const Color(0xFFC6D3E3);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: completed ? 0.78 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.2),
          boxShadow: completed
              ? [
                  const BoxShadow(
                    color: Color(0x7A64B88E),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final spacing = constraints.maxHeight > 42 ? 4.0 : 2.0;
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$sumValue',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF35506E),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$bombValue',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF2C4B68),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
