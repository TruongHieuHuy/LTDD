class Challenge {
  final String id;
  final String creatorId;
  final String? opponentId;
  
  // Betting
  final int betAmount;
  
  // Game tracking
  final int totalGames;
  final int currentGame;
  final int gamesCompleted;
  
  // Game 1
  final String? game1Type;
  final String? game1CreatorVote;
  final String? game1OpponentVote;
  final int game1CreatorScore;
  final int game1OpponentScore;
  final bool game1Completed;
  
  // Game 2
  final String? game2Type;
  final String? game2CreatorVote;
  final String? game2OpponentVote;
  final int game2CreatorScore;
  final int game2OpponentScore;
  final bool game2Completed;
  
  // Game 3
  final String? game3Type;
  final String? game3CreatorVote;
  final String? game3OpponentVote;
  final int game3CreatorScore;
  final int game3OpponentScore;
  final bool game3Completed;
  
  // Overall scores
  final int creatorWins;
  final int opponentWins;
  
  // Winner
  final String? winnerId;
  final bool isDraw;
  
  // State
  final ChallengeStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime expiresAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  
  // Metadata
  final bool creatorForfeit;
  final bool opponentForfeit;
  
  // Populated user data
  final ChallengeUser? creator;
  final ChallengeUser? opponent;
  final ChallengeUser? winner;

  Challenge({
    required this.id,
    required this.creatorId,
    this.opponentId,
    required this.betAmount,
    this.totalGames = 3,
    this.currentGame = 1,
    this.gamesCompleted = 0,
    this.game1Type,
    this.game1CreatorVote,
    this.game1OpponentVote,
    this.game1CreatorScore = 0,
    this.game1OpponentScore = 0,
    this.game1Completed = false,
    this.game2Type,
    this.game2CreatorVote,
    this.game2OpponentVote,
    this.game2CreatorScore = 0,
    this.game2OpponentScore = 0,
    this.game2Completed = false,
    this.game3Type,
    this.game3CreatorVote,
    this.game3OpponentVote,
    this.game3CreatorScore = 0,
    this.game3OpponentScore = 0,
    this.game3Completed = false,
    this.creatorWins = 0,
    this.opponentWins = 0,
    this.winnerId,
    this.isDraw = false,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    required this.expiresAt,
    this.completedAt,
    this.cancelledAt,
    this.creatorForfeit = false,
    this.opponentForfeit = false,
    this.creator,
    this.opponent,
    this.winner,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      creatorId: json['creatorId'],
      opponentId: json['opponentId'],
      betAmount: json['betAmount'] ?? 100,
      totalGames: json['totalGames'] ?? 3,
      currentGame: json['currentGame'] ?? 1,
      gamesCompleted: json['gamesCompleted'] ?? 0,
      game1Type: json['game1Type'],
      game1CreatorVote: json['game1CreatorVote'],
      game1OpponentVote: json['game1OpponentVote'],
      game1CreatorScore: json['game1CreatorScore'] ?? 0,
      game1OpponentScore: json['game1OpponentScore'] ?? 0,
      game1Completed: json['game1Completed'] ?? false,
      game2Type: json['game2Type'],
      game2CreatorVote: json['game2CreatorVote'],
      game2OpponentVote: json['game2OpponentVote'],
      game2CreatorScore: json['game2CreatorScore'] ?? 0,
      game2OpponentScore: json['game2OpponentScore'] ?? 0,
      game2Completed: json['game2Completed'] ?? false,
      game3Type: json['game3Type'],
      game3CreatorVote: json['game3CreatorVote'],
      game3OpponentVote: json['game3OpponentVote'],
      game3CreatorScore: json['game3CreatorScore'] ?? 0,
      game3OpponentScore: json['game3OpponentScore'] ?? 0,
      game3Completed: json['game3Completed'] ?? false,
      creatorWins: json['creatorWins'] ?? 0,
      opponentWins: json['opponentWins'] ?? 0,
      winnerId: json['winnerId'],
      isDraw: json['isDraw'] ?? false,
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == json['status'].toString().toUpperCase(),
        orElse: () => ChallengeStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
      expiresAt: DateTime.parse(json['expiresAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      creatorForfeit: json['creatorForfeit'] ?? false,
      opponentForfeit: json['opponentForfeit'] ?? false,
      creator: json['creator'] != null ? ChallengeUser.fromJson(json['creator']) : null,
      opponent: json['opponent'] != null ? ChallengeUser.fromJson(json['opponent']) : null,
      winner: json['winner'] != null ? ChallengeUser.fromJson(json['winner']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'opponentId': opponentId,
      'betAmount': betAmount,
      'totalGames': totalGames,
      'currentGame': currentGame,
      'gamesCompleted': gamesCompleted,
      'game1Type': game1Type,
      'game1CreatorVote': game1CreatorVote,
      'game1OpponentVote': game1OpponentVote,
      'game1CreatorScore': game1CreatorScore,
      'game1OpponentScore': game1OpponentScore,
      'game1Completed': game1Completed,
      'game2Type': game2Type,
      'game2CreatorVote': game2CreatorVote,
      'game2OpponentVote': game2OpponentVote,
      'game2CreatorScore': game2CreatorScore,
      'game2OpponentScore': game2OpponentScore,
      'game2Completed': game2Completed,
      'game3Type': game3Type,
      'game3CreatorVote': game3CreatorVote,
      'game3OpponentVote': game3OpponentVote,
      'game3CreatorScore': game3CreatorScore,
      'game3OpponentScore': game3OpponentScore,
      'game3Completed': game3Completed,
      'creatorWins': creatorWins,
      'opponentWins': opponentWins,
      'winnerId': winnerId,
      'isDraw': isDraw,
      'status': status.name.toUpperCase(),
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'creatorForfeit': creatorForfeit,
      'opponentForfeit': opponentForfeit,
      'creator': creator?.toJson(),
      'opponent': opponent?.toJson(),
      'winner': winner?.toJson(),
    };
  }
  
  // Helper methods
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  bool isCreator(String userId) => creatorId == userId;
  
  bool isOpponent(String userId) => opponentId == userId;
  
  bool isParticipant(String userId) => isCreator(userId) || isOpponent(userId);
  
  String? getGameType(int gameNumber) {
    switch (gameNumber) {
      case 1:
        return game1Type;
      case 2:
        return game2Type;
      case 3:
        return game3Type;
      default:
        return null;
    }
  }
  
  bool isGameCompleted(int gameNumber) {
    switch (gameNumber) {
      case 1:
        return game1Completed;
      case 2:
        return game2Completed;
      case 3:
        return game3Completed;
      default:
        return false;
    }
  }
}

// User data in challenge
class ChallengeUser {
  final String id;
  final String username;
  final String? avatarUrl;
  final int? totalScore;
  final int? totalGamesPlayed;
  final int? coins;

  ChallengeUser({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.totalScore,
    this.totalGamesPlayed,
    this.coins,
  });

  factory ChallengeUser.fromJson(Map<String, dynamic> json) {
    return ChallengeUser(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      totalScore: json['totalScore'],
      totalGamesPlayed: json['totalGamesPlayed'],
      coins: json['coins'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
      'totalScore': totalScore,
      'totalGamesPlayed': totalGamesPlayed,
      'coins': coins,
    };
  }
}

enum ChallengeStatus {
  pending,  // Waiting for opponent to accept
  active,   // Accepted and in progress
  completed, // Finished with winner/draw
  expired,  // Timed out
  cancelled, // Rejected or cancelled
}
