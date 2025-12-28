import './user_profile.dart';

/// Leaderboard entry
class LeaderboardEntry {
  final String id;
  final String gameType;
  final int score;
  final String difficulty;
  final int timeSpent;
  final UserProfile user;
  final DateTime createdAt;

  LeaderboardEntry({
    required this.id,
    required this.gameType,
    required this.score,
    required this.difficulty,
    required this.timeSpent,
    required this.user,
    required this.createdAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'],
      gameType: json['gameType'],
      score: json['score'],
      difficulty: json['difficulty'],
      timeSpent: json['timeSpent'],
      user: UserProfile.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
