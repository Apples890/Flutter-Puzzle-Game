class LevelConfig {
  final int minSafeValue;
  final int maxSafeValue;
  final int minTotalBombs;
  final int maxTotalBombs;
  final double zeroBombRowProbability;
  final double fourBombRowProbability;
  final int maxRowSum;

  const LevelConfig({
    required this.minSafeValue,
    required this.maxSafeValue,
    required this.minTotalBombs,
    required this.maxTotalBombs,
    required this.zeroBombRowProbability,
    required this.fourBombRowProbability,
    required this.maxRowSum,
  });
}
