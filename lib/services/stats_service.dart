import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static const _highScoreKey = 'high_score';
  static const _highestLevelKey = 'highest_level';

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  static Future<int> getHighScore() async {
    final prefs = await _prefs();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  static Future<int> getHighestLevel() async {
    final prefs = await _prefs();
    return prefs.getInt(_highestLevelKey) ?? 1;
  }

  static Future<void> updateHighScore(int score) async {
    final prefs = await _prefs();
    final current = prefs.getInt(_highScoreKey) ?? 0;
    if (score > current) {
      await prefs.setInt(_highScoreKey, score);
    }
  }

  static Future<void> updateHighestLevel(int level) async {
    final prefs = await _prefs();
    final current = prefs.getInt(_highestLevelKey) ?? 1;
    if (level > current) {
      await prefs.setInt(_highestLevelKey, level);
    }
  }
}
