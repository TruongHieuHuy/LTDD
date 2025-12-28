/// Game score data
class GameScoreData {
  final String id;
  final String gameType;
  final int score;
  final int attempts;
  final String difficulty;
  final int timeSpent;
  final Map<String, dynamic>? gameData;
  final DateTime createdAt;

  GameScoreData({
    required this.id,
    required this.gameType,
    required this.score,
    required this.attempts,
    required this.difficulty,
    required this.timeSpent,
    this.gameData,
    required this.createdAt,
  });

  factory GameScoreData.fromJson(Map<String, dynamic> json) {
    return GameScoreData(
      id: json['id'],
      gameType: json['gameType'],
      score: json['score'],
      attempts: json['attempts'],
      difficulty: json['difficulty'],
      timeSpent: json['timeSpent'],
      gameData: json['gameData'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
