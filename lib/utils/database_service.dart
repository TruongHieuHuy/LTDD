import 'package:hive_flutter/hive_flutter.dart';
import '../models/alarm_model.dart';
import '../models/translation_history_model.dart';
import '../models/app_settings_model.dart';
import '../models/game_score_model.dart';
import '../models/achievement_model.dart';

class DatabaseService {
  static const String alarmsBoxName = 'alarms';
  static const String translationsBoxName = 'translations';
  static const String settingsBoxName = 'settings';
  static const String gameScoresBoxName = 'game_scores';
  static const String achievementsBoxName = 'achievements';
  static const String settingsKey = 'app_settings';

  // Boxes
  static Box<AlarmModel>? _alarmsBox;
  static Box<TranslationHistoryModel>? _translationsBox;
  static Box<AppSettingsModel>? _settingsBox;
  static Box<GameScoreModel>? _gameScoresBox;
  static Box<AchievementModel>? _achievementsBox;

  // Getters
  static Box<AlarmModel> get alarmsBox => _alarmsBox!;
  static Box<TranslationHistoryModel> get translationsBox => _translationsBox!;
  static Box<AppSettingsModel> get settingsBox => _settingsBox!;
  static Box<GameScoreModel> get gameScoresBox => _gameScoresBox!;
  static Box<AchievementModel> get achievementsBox => _achievementsBox!;

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(AlarmModelAdapter());
    Hive.registerAdapter(TranslationHistoryModelAdapter());
    Hive.registerAdapter(AppSettingsModelAdapter());
    Hive.registerAdapter(GameScoreModelAdapter());
    Hive.registerAdapter(AchievementModelAdapter());

    // Open boxes
    _alarmsBox = await Hive.openBox<AlarmModel>(alarmsBoxName);
    _translationsBox = await Hive.openBox<TranslationHistoryModel>(
      translationsBoxName,
    );
    _settingsBox = await Hive.openBox<AppSettingsModel>(settingsBoxName);
    _gameScoresBox = await Hive.openBox<GameScoreModel>(gameScoresBoxName);
    _achievementsBox = await Hive.openBox<AchievementModel>(
      achievementsBoxName,
    );

    // Initialize settings if not exists
    if (_settingsBox!.isEmpty) {
      await _settingsBox!.put(settingsKey, AppSettingsModel());
    }

    // Initialize achievements if not exists
    if (_achievementsBox!.isEmpty) {
      await _initializeAchievements();
    }
  }

  /// Initialize all achievements with locked state
  static Future<void> _initializeAchievements() async {
    for (var achievement in Achievements.all) {
      await _achievementsBox!.put(achievement.id, achievement);
    }
  }

  /// Close all boxes
  static Future<void> close() async {
    await _alarmsBox?.close();
    await _translationsBox?.close();
    await _settingsBox?.close();
    await _gameScoresBox?.close();
    await _achievementsBox?.close();
  }

  /// Clear all data (for testing/reset)
  static Future<void> clearAll() async {
    await _alarmsBox?.clear();
    await _translationsBox?.clear();
    await _settingsBox?.clear();
    await _gameScoresBox?.clear();
    await _achievementsBox?.clear();
    // Reinitialize settings
    await _settingsBox?.put(settingsKey, AppSettingsModel());
    // Reinitialize achievements
    await _initializeAchievements();
  }

  // ============ ALARM OPERATIONS ============

  static Future<void> saveAlarm(AlarmModel alarm) async {
    await _alarmsBox!.put(alarm.id, alarm);
  }

  static List<AlarmModel> getAllAlarms() {
    return _alarmsBox!.values.toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  static AlarmModel? getAlarm(String id) {
    return _alarmsBox!.get(id);
  }

  static Future<void> deleteAlarm(String id) async {
    await _alarmsBox!.delete(id);
  }

  static Future<void> updateAlarm(AlarmModel alarm) async {
    await _alarmsBox!.put(alarm.id, alarm);
  }

  static List<AlarmModel> getEnabledAlarms() {
    return _alarmsBox!.values.where((alarm) => alarm.isEnabled).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  // ============ TRANSLATION HISTORY OPERATIONS ============

  static Future<void> saveTranslation(
    TranslationHistoryModel translation,
  ) async {
    await _translationsBox!.put(translation.id, translation);
  }

  static List<TranslationHistoryModel> getAllTranslations({int? limit}) {
    final list = _translationsBox!.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return limit != null ? list.take(limit).toList() : list;
  }

  static Future<void> deleteTranslation(String id) async {
    await _translationsBox!.delete(id);
  }

  static Future<void> clearTranslationHistory() async {
    await _translationsBox!.clear();
  }

  static List<TranslationHistoryModel> searchTranslations(String query) {
    return _translationsBox!.values
        .where(
          (trans) =>
              trans.sourceText.toLowerCase().contains(query.toLowerCase()) ||
              trans.translatedText.toLowerCase().contains(query.toLowerCase()),
        )
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // ============ SETTINGS OPERATIONS ============

  static AppSettingsModel getSettings() {
    return _settingsBox!.get(settingsKey) ?? AppSettingsModel();
  }

  static Future<void> updateSettings(AppSettingsModel settings) async {
    await _settingsBox!.put(settingsKey, settings);
  }

  static Future<void> updateDarkMode(bool isDarkMode) async {
    final settings = getSettings();
    settings.isDarkMode = isDarkMode;
    await updateSettings(settings);
  }

  static Future<void> updateNotifications(bool enabled) async {
    final settings = getSettings();
    settings.notificationsEnabled = enabled;
    await updateSettings(settings);
  }

  static Future<void> updateBiometric(bool enabled) async {
    final settings = getSettings();
    settings.biometricEnabled = enabled;
    await updateSettings(settings);
  }

  static Future<void> updateLanguage(String languageCode) async {
    final settings = getSettings();
    settings.selectedLanguage = languageCode;
    await updateSettings(settings);
  }

  // ============ GAME SCORE OPERATIONS ============

  /// Save a game score
  static Future<void> saveGameScore(GameScoreModel score) async {
    await _gameScoresBox!.put(score.id, score);
  }

  /// Get all game scores sorted by score (highest first)
  static List<GameScoreModel> getAllGameScores() {
    return _gameScoresBox!.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  /// Get leaderboard with filtering
  static List<GameScoreModel> getLeaderboard({
    String? gameType,
    int limit = 10,
  }) {
    var scores = _gameScoresBox!.values.toList();

    // Filter by game type if specified
    if (gameType != null && gameType != 'all') {
      scores = scores.where((s) => s.gameType == gameType).toList();
    }

    // Sort by score (highest first)
    scores.sort((a, b) => b.score.compareTo(a.score));

    // Return limited results
    return scores.take(limit).toList();
  }

  /// Get player's best score for a game type
  static GameScoreModel? getBestScore(String playerName, String gameType) {
    final scores = _gameScoresBox!.values
        .where((s) => s.playerName == playerName && s.gameType == gameType)
        .toList();

    if (scores.isEmpty) return null;

    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores.first;
  }

  /// Get player's total games played
  static int getTotalGamesPlayed(String playerName) {
    return _gameScoresBox!.values
        .where((s) => s.playerName == playerName)
        .length;
  }

  /// Get player's win streak
  static int getWinStreak(String playerName) {
    final scores =
        _gameScoresBox!.values.where((s) => s.playerName == playerName).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 0;
    for (var score in scores) {
      if (score.score > 0) {
        // Assuming score > 0 means won
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Delete a game score
  static Future<void> deleteGameScore(String id) async {
    await _gameScoresBox!.delete(id);
  }

  /// Clear all game scores
  static Future<void> clearGameScores() async {
    await _gameScoresBox!.clear();
  }

  // ============ ACHIEVEMENT OPERATIONS ============

  /// Get all achievements
  static List<AchievementModel> getAllAchievements() {
    return _achievementsBox!.values.toList();
  }

  /// Get unlocked achievements
  static List<AchievementModel> getUnlockedAchievements() {
    return _achievementsBox!.values.where((a) => a.isUnlocked).toList();
  }

  /// Get locked achievements
  static List<AchievementModel> getLockedAchievements() {
    return _achievementsBox!.values.where((a) => !a.isUnlocked).toList();
  }

  /// Get achievement by ID
  static AchievementModel? getAchievement(String id) {
    return _achievementsBox!.get(id);
  }

  /// Unlock an achievement
  static Future<AchievementModel?> unlockAchievement(String id) async {
    final achievement = _achievementsBox!.get(id);
    if (achievement != null && !achievement.isUnlocked) {
      achievement.isUnlocked = true;
      achievement.unlockedAt = DateTime.now();
      await _achievementsBox!.put(id, achievement);
      return achievement;
    }
    return null;
  }

  /// Check if achievement is unlocked
  static bool isAchievementUnlocked(String id) {
    final achievement = _achievementsBox!.get(id);
    return achievement?.isUnlocked ?? false;
  }

  /// Get achievement unlock percentage
  static double getAchievementProgress() {
    final total = _achievementsBox!.length;
    final unlocked = _achievementsBox!.values.where((a) => a.isUnlocked).length;
    return total > 0 ? (unlocked / total) : 0.0;
  }

  /// Reset all achievements (lock all)
  static Future<void> resetAchievements() async {
    final achievements = _achievementsBox!.values.toList();
    for (var achievement in achievements) {
      achievement.isUnlocked = false;
      achievement.unlockedAt = null;
      await _achievementsBox!.put(achievement.id, achievement);
    }
  }

  // ============ GAME STATS & ACHIEVEMENT CHECKING ============

  /// Check and unlock achievements based on game performance
  static Future<List<AchievementModel>> checkAndUnlockAchievements({
    required String playerName,
    required String gameType,
    required int attempts,
    required int timeSpent,
    required String difficulty,
  }) async {
    final unlockedAchievements = <AchievementModel>[];

    // First Win
    if (getTotalGamesPlayed(playerName) == 1) {
      final achievement = await unlockAchievement('first_win');
      if (achievement != null) unlockedAchievements.add(achievement);
    }

    // Lucky King (win in 3 attempts or less)
    if (attempts <= 3) {
      final achievement = await unlockAchievement('lucky_king');
      if (achievement != null) unlockedAchievements.add(achievement);
    }

    // Perfect Game (win in 1 attempt)
    if (attempts == 1) {
      final achievement = await unlockAchievement('perfect_game');
      if (achievement != null) unlockedAchievements.add(achievement);
    }

    // Speed Demon (win in under 30 seconds)
    if (timeSpent < 30) {
      final achievement = await unlockAchievement('speed_demon');
      if (achievement != null) unlockedAchievements.add(achievement);
    }

    // Hard Mode Master (5 wins on hard difficulty)
    if (difficulty == 'hard' || difficulty == '12digit') {
      final hardWins = _gameScoresBox!.values
          .where(
            (s) =>
                s.playerName == playerName &&
                (s.difficulty == 'hard' || s.difficulty == '12digit'),
          )
          .length;
      if (hardWins >= 5) {
        final achievement = await unlockAchievement('hard_mode_master');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
    }

    // Ultimate Hacker (10 game win streak)
    if (getWinStreak(playerName) >= 10) {
      final achievement = await unlockAchievement('ultimate_hacker');
      if (achievement != null) unlockedAchievements.add(achievement);
    }

    // Super Cow Brain (Win 12-digit Cows & Bulls)
    if (gameType == 'cows_bulls' && difficulty == '12digit') {
      final achievement = await unlockAchievement('super_cow_brain');
      if (achievement != null) unlockedAchievements.add(achievement);
    }

    // Troll Master (encounter 50+ meme messages - tracked separately)
    // Persistent Player (play 100 games - tracked separately)

    return unlockedAchievements;
  }
}
