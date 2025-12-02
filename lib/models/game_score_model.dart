import 'package:hive/hive.dart';

part 'game_score_model.g.dart';

@HiveType(typeId: 3)
class GameScoreModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String playerName;

  @HiveField(2)
  String gameType; // 'guess_number' or 'cows_bulls'

  @HiveField(3)
  int score; // Điểm số (càng ít lượt càng cao điểm)

  @HiveField(4)
  int attempts; // Số lần thử

  @HiveField(5)
  DateTime timestamp;

  @HiveField(6)
  String difficulty; // 'easy', 'normal', 'hard', '6digit', '12digit'

  @HiveField(7)
  int timeSpent; // Thời gian chơi (giây)

  GameScoreModel({
    required this.id,
    required this.playerName,
    required this.gameType,
    required this.score,
    required this.attempts,
    required this.timestamp,
    required this.difficulty,
    this.timeSpent = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'playerName': playerName,
    'gameType': gameType,
    'score': score,
    'attempts': attempts,
    'timestamp': timestamp.toIso8601String(),
    'difficulty': difficulty,
    'timeSpent': timeSpent,
  };

  factory GameScoreModel.fromJson(Map<String, dynamic> json) => GameScoreModel(
    id: json['id'],
    playerName: json['playerName'],
    gameType: json['gameType'],
    score: json['score'],
    attempts: json['attempts'],
    timestamp: DateTime.parse(json['timestamp']),
    difficulty: json['difficulty'],
    timeSpent: json['timeSpent'] ?? 0,
  );
}
