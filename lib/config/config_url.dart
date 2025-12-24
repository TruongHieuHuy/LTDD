import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigUrl {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      // Đường dẫn mặc định nếu không đọc được .env
      return "http://10.0.2.2:3000";
    }
    return url;
  }

  // Các endpoint API
  static String get apiAuth => "$baseUrl/api/auth";
  static String get apiGames => "$baseUrl/api/games";
  static String get apiFriends => "$baseUrl/api/friends";
  static String get apiPosts => "$baseUrl/api/posts";
  static String get apiLeaderboard => "$baseUrl/api/leaderboard";
  static String get apiAchievements => "$baseUrl/api/achievements";
}
