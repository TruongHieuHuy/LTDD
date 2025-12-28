/// Friend Data
class FriendData {
  final String friendshipId;
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final int totalScore;
  final int totalGamesPlayed;
  final DateTime friendsSince;

  FriendData({
    required this.friendshipId,
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.totalScore,
    required this.totalGamesPlayed,
    required this.friendsSince,
  });

  factory FriendData.fromJson(Map<String, dynamic> json) {
    return FriendData(
      friendshipId: json['friendshipId'],
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      totalScore: json['totalScore'] ?? 0,
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      friendsSince: DateTime.parse(json['friendsSince']),
    );
  }
}
