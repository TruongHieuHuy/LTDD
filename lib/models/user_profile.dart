/// User profile data
class UserProfile {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final int totalGamesPlayed;
  final int totalScore;
  final String role; // USER, ADMIN, MODERATOR
  final int coins;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.totalGamesPlayed = 0,
    this.totalScore = 0,
    this.role = 'USER',
    this.coins = 1000,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try {
      return UserProfile(
        id: (json['id'] ?? '').toString(),
        username: json['username']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        avatarUrl: json['avatarUrl']?.toString(),
        totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
        totalScore: json['totalScore'] ?? 0,
        role: json['role']?.toString() ?? 'USER',
        coins: json['coins'] ?? 1000,
      );
    } catch (e) {
      print('Error parsing UserProfile: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'role': role,
      'coins': coins,
    };
  }
}
