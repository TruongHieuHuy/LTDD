/// Game statistics
class GameStats {
  final String gameType;
  final int totalGames;
  final int maxScore;
  final double avgScore;
  final double avgTimeSpent;

  GameStats({
    required this.gameType,
    required this.totalGames,
    required this.maxScore,
    required this.avgScore,
    required this.avgTimeSpent,
  });

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      gameType: json['gameType'],
      totalGames: json['_count']['id'],
      maxScore: json['_max']['score'] ?? 0,
      avgScore: (json['_avg']['score'] ?? 0).toDouble(),
      avgTimeSpent: (json['_avg']['timeSpent'] ?? 0).toDouble(),
    );
  }
}
