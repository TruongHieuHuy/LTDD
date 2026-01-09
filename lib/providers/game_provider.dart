import 'package:flutter/foundation.dart';
import '../models/game_score_model.dart';
import '../models/achievement_model.dart';
import '../utils/database_service.dart';
import '../services/api_service.dart';

class GameProvider extends ChangeNotifier {
  String _playerName = 'Player';
  List<GameScoreModel> _scores = [];
  List<AchievementModel> _achievements = [];
  bool _isLoading = false;
  int _memeEncounters = 0;

  // Getters
  String get playerName => _playerName;
  List<GameScoreModel> get scores => _scores;
  List<AchievementModel> get achievements => _achievements;
  bool get isLoading => _isLoading;
  int get memeEncounters => _memeEncounters;

  List<AchievementModel> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  List<AchievementModel> get lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked).toList();

  int get totalGamesPlayed => _scores.length;

  int get achievementCount => unlockedAchievements.length;

  double get achievementProgress {
    if (_achievements.isEmpty) return 0.0;
    return unlockedAchievements.length / _achievements.length;
  }

  /// Initialize provider - load data from Hive
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _scores = DatabaseService.getAllGameScores();
      _achievements = DatabaseService.getAllAchievements();
      _memeEncounters = _loadMemeEncounters();
    } catch (e) {
      debugPrint('Error initializing GameProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set player name
  void setPlayerName(String name) {
    _playerName = name;
    notifyListeners();
  }

  /// Save game score and check achievements
  Future<List<AchievementModel>> saveGameScore({
    required String gameType,
    required int score,
    required int attempts,
    required String difficulty,
    required int timeSpent,
  }) async {
    // Create score model
    final scoreModel = GameScoreModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playerName: _playerName,
      gameType: gameType,
      score: score,
      attempts: attempts,
      timestamp: DateTime.now(),
      difficulty: difficulty,
      timeSpent: timeSpent,
    );

    // Save to database
    await DatabaseService.saveGameScore(scoreModel);

    // Reload scores
    _scores = DatabaseService.getAllGameScores();

    // Check and unlock achievements
    final newAchievements = await DatabaseService.checkAndUnlockAchievements(
      playerName: _playerName,
      gameType: gameType,
      attempts: attempts,
      timeSpent: timeSpent,
      difficulty: difficulty,
    );

    // Reload achievements
    _achievements = DatabaseService.getAllAchievements();

    notifyListeners();
    return newAchievements;
  }

  /// Get leaderboard with filtering (Local)
  List<GameScoreModel> getLeaderboard({String? gameType, int limit = 10}) {
    return DatabaseService.getLeaderboard(gameType: gameType, limit: limit);
  }

  /// Fetch Global Leaderboard from API
  Future<List<dynamic>> fetchGlobalLeaderboard({
    String gameType = 'all',
    String difficulty = 'all',
    int limit = 10,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Use ApiService to get global data
      // Note: ApiService returns List<LeaderboardEntry>
      final entries = await ApiService().getLeaderboard(
        gameType: gameType,
        difficulty: difficulty,
        limit: limit,
      );
      
      _isLoading = false;
      notifyListeners();
      return entries;
    } catch (e) {
      debugPrint('Error fetching global leaderboard: $e');
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  /// Get player's best score for a game
  GameScoreModel? getBestScore(String gameType) {
    return DatabaseService.getBestScore(_playerName, gameType);
  }

  /// Increment meme encounter counter
  Future<void> incrementMemeEncounters() async {
    _memeEncounters++;
    await _saveMemeEncounters(_memeEncounters);

    // Check for Troll Master achievement (50 meme encounters)
    if (_memeEncounters >= 50) {
      final achievement = await DatabaseService.unlockAchievement(
        'troll_master',
      );
      if (achievement != null) {
        _achievements = DatabaseService.getAllAchievements();
        notifyListeners();
      }
    }
  }

  /// Check for Persistent Player achievement (100 games)
  Future<void> checkPersistentPlayer() async {
    if (totalGamesPlayed >= 100) {
      final achievement = await DatabaseService.unlockAchievement(
        'persistent_player',
      );
      if (achievement != null) {
        _achievements = DatabaseService.getAllAchievements();
        notifyListeners();
      }
    }
  }

  /// Load meme encounters from persistent storage
  int _loadMemeEncounters() {
    // TODO: Store in Hive settings or separate counter
    return 0; // Placeholder
  }

  /// Save meme encounters to persistent storage
  Future<void> _saveMemeEncounters(int count) async {
    // TODO: Store in Hive settings or separate counter
  }

  /// Manually unlock achievement (for testing)
  Future<void> unlockAchievement(String id) async {
    final achievement = await DatabaseService.unlockAchievement(id);
    if (achievement != null) {
      _achievements = DatabaseService.getAllAchievements();
      notifyListeners();
    }
  }

  /// Reset all achievements
  Future<void> resetAchievements() async {
    await DatabaseService.resetAchievements();
    _achievements = DatabaseService.getAllAchievements();
    notifyListeners();
  }

  /// Clear all game data
  Future<void> clearGameData() async {
    await DatabaseService.clearGameScores();
    await DatabaseService.resetAchievements();
    _scores = [];
    _achievements = DatabaseService.getAllAchievements();
    _memeEncounters = 0;
    notifyListeners();
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    final guessNumberGames = _scores
        .where((s) => s.gameType == 'guess_number')
        .length;
    final cowsBullsGames = _scores
        .where((s) => s.gameType == 'cows_bulls')
        .length;

    final avgAttempts = _scores.isEmpty
        ? 0.0
        : _scores.map((s) => s.attempts).reduce((a, b) => a + b) /
              _scores.length;

    final avgTime = _scores.isEmpty
        ? 0.0
        : _scores.map((s) => s.timeSpent).reduce((a, b) => a + b) /
              _scores.length;

    return {
      'totalGames': totalGamesPlayed,
      'guessNumberGames': guessNumberGames,
      'cowsBullsGames': cowsBullsGames,
      'achievementsUnlocked': achievementCount,
      'achievementProgress': achievementProgress,
      'avgAttempts': avgAttempts,
      'avgTimeSeconds': avgTime,
      'memeEncounters': _memeEncounters,
    };
  }
}
