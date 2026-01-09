import 'package:flutter/material.dart';
import '../models/navigation_models.dart';
import '../screens/home_screen.dart';
import '../screens/simple_home_screen.dart';
import '../screens/translate_screen.dart';
import '../screens/alarm_screen.dart';
import '../screens/youtube_screen.dart';
import '../screens/group_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/games/guess_number_game_screen.dart';
import '../screens/games/cows_bulls_game_screen.dart';
import '../screens/games/memory_match_game_screen.dart';
import '../screens/games/quick_math_game_screen.dart';
import '../screens/games/leaderboard_screen.dart';
import '../screens/games/achievement_screen.dart';
import '../screens/chatbot_screen.dart';
import '../screens/peer_chat_list_screen.dart';
import '../screens/social_test_screen.dart';
import '../screens/posts_screen.dart';
import '../screens/products_screen.dart';
import '../screens/categories_screen.dart';

/// Configuration for modular navigation system
class NavigationConfig {
  static List<NavigationCategory> getCategories() {
    return [
      // Category 1: Home (Trang chủ)
      NavigationCategory(
        id: 'home',
        name: 'Trang chủ',
        icon: Icons.home,
        items: [
          NavigationItem(
            id: 'home',
            name: 'Trang chủ',
            icon: Icons.home,
            screen: const SimpleHomeScreen(),
            route: '/home',
          ),
        ],
      ),

      // Category 2: Profile (Hồ sơ)
      NavigationCategory(
        id: 'profile',
        name: 'Hồ sơ',
        icon: Icons.person_outline,
        items: [
          NavigationItem(
            id: 'personal',
            name: 'Cá nhân',
            icon: Icons.account_circle,
            screen: const ProfileScreen(),
            route: '/profile',
          ),
        ],
      ),
    ];
  }

  static NavigationItem? getDefaultItem() {
    return getCategories()[0].items[0]; // Default: Translate screen
  }
}

/// Games Hub - Central screen for all games
class GamesHub extends StatelessWidget {
  const GamesHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trò chơi'), centerTitle: true),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildGameCard(
            context: context,
            title: 'Đoán Số',
            icon: Icons.casino,
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GuessNumberGameScreen(),
              ),
            ),
          ),
          _buildGameCard(
            context: context,
            title: 'Bò & Bê',
            icon: Icons.psychology,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CowsBullsGameScreen(),
              ),
            ),
          ),
          _buildGameCard(
            context: context,
            title: 'Lật Thẻ',
            icon: Icons.extension,
            color: Colors.indigo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MemoryMatchGameScreen(),
              ),
            ),
          ),
          _buildGameCard(
            context: context,
            title: 'Quick Math',
            icon: Icons.calculate,
            color: Colors.deepPurple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QuickMathGameScreen(),
              ),
            ),
          ),
          _buildGameCard(
            context: context,
            title: 'Bảng Xếp Hạng',
            icon: Icons.leaderboard,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LeaderboardScreen(),
              ),
            ),
          ),
          _buildGameCard(
            context: context,
            title: 'Thành Tích',
            icon: Icons.emoji_events,
            color: Colors.amber,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AchievementScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.7), color],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Coming Soon screen for features under development
class ComingSoonScreen extends StatelessWidget {
  final String feature;

  const ComingSoonScreen({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(feature), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 120,
              color: Colors.orange.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sắp ra mắt',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Tính năng "$feature" đang được phát triển',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
