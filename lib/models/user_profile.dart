/// User profile data
class UserProfile {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final int totalGamesPlayed;
  final int totalScore;
  final String role; // USER, ADMIN, MODERATOR

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.totalGamesPlayed = 0,
    this.totalScore = 0,
    this.role = 'USER',
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
    };
  }
}
