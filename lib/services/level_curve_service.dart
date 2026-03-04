import '../models/level_config.dart';

class LevelCurveService {
  static const _level1 = LevelConfig(
    minSafeValue: 1,
    maxSafeValue: 2,
    minTotalBombs: 5,
    maxTotalBombs: 7,
    zeroBombRowProbability: 0.25,
    fourBombRowProbability: 0.0,
    maxRowSum: 5,
  );

  static const _level2 = LevelConfig(
    minSafeValue: 1,
    maxSafeValue: 3,
    minTotalBombs: 6,
    maxTotalBombs: 9,
    zeroBombRowProbability: 0.23,
    fourBombRowProbability: 0.0,
    maxRowSum: 9,
  );

  static const _level3 = LevelConfig(
    minSafeValue: 1,
    maxSafeValue: 3,
    minTotalBombs: 7,
    maxTotalBombs: 12,
    zeroBombRowProbability: 0.10,
    fourBombRowProbability: 0.05,
    maxRowSum: 9,
  );

  static const _level4 = LevelConfig(
    minSafeValue: 1,
    maxSafeValue: 3,
    minTotalBombs: 8,
    maxTotalBombs: 12,
    zeroBombRowProbability: 0.05,
    fourBombRowProbability: 0.18,
    maxRowSum: 12,
  );

  static const _level5 = LevelConfig(
    minSafeValue: 1,
    maxSafeValue: 4,
    minTotalBombs: 9,
    maxTotalBombs: 10,
    zeroBombRowProbability: 0.02,
    fourBombRowProbability: 0.30,
    maxRowSum: 14,
  );

  static LevelConfig configForLevel(int level) {
    if (level <= 1) return _level1;
    if (level == 2) return _level2;
    if (level == 3) return _level3;
    if (level == 4) return _level4;
    return _level5;
  }

  static int maxBombsPerRowForLevel(int level) {
    if (level <= 1) return 2;
    if (level == 2) return 3;
    return 4;
  }
}
