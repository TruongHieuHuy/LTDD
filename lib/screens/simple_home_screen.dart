import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/gaming_theme.dart';

/// Gaming Hub - Main Dashboard
/// Cyber-themed gaming center with neon aesthetics
class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.username ?? 'Guest';
    final totalScore = authProvider.userProfile?.totalScore ?? 0;
    final level = (totalScore / 1000).floor() + 1;

    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Gaming Header with user stats
            SliverToBoxAdapter(
              child: _buildGamingHeader(context, userName, level, totalScore),
            ),
            
            // Spacer
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            // Games Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.sports_esports, color: GamingTheme.primaryAccent, size: 24),
                    const SizedBox(width: 8),
                    Text('MINI GAMES', style: GamingTheme.h2),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            // Game Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _buildGameCard(
                    context,
                    title: 'Đoán Số',
                    icon: '🎲',
                    color: GamingTheme.easyGreen,
                    route: '/guess_number_game',
                    isNew: true,
                  ),
                  _buildGameCard(
                    context,
                    title: 'Bò & Bê',
                    icon: '🐮',
                    color: GamingTheme.mediumOrange,
                    route: '/cows_bulls_game',
                    isNew: true,
                  ),
                  _buildGameCard(
                    context,
                    title: 'Memory',
                    icon: '🧠',
                    color: GamingTheme.hardRed,
                    route: '/memory_match_game',
                    isNew: true,
                  ),
                  _buildGameCard(
                    context,
                    title: 'Quick Math',
                    icon: '⚡',
                    color: GamingTheme.expertPurple,
                    route: '/quick_math_game',
                    isNew: true,
                  ),
                  _buildGameCard(
                    context,
                    title: 'Rubik',
                    icon: '🎨',
                    color: GamingTheme.rareBlue,
                    route: null,
                    comingSoon: true,
                  ),
                  _buildGameCard(
                    context,
                    title: 'Sudoku',
                    icon: '🔢',
                    color: GamingTheme.epicPurple,
                    route: null,
                    comingSoon: true,
                  ),
                  _buildGameCard(
                    context,
                    title: 'Caro',
                    icon: '⭕',
                    color: GamingTheme.easyGreen,
                    route: null,
                    comingSoon: true,
                  ),
                  _buildGameCard(
                    context,
                    title: 'Puzzle',
                    icon: '🧩',
                    color: GamingTheme.mediumOrange,
                    route: null,
                    comingSoon: true,
                  ),
                ]),
              ),
            ),
            
            // Utilities Section
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.dashboard, color: GamingTheme.secondaryAccent, size: 24),
                    const SizedBox(width: 8),
                    Text('TIỆN ÍCH', style: GamingTheme.h2),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            // Utility Cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildUtilityCard(
                    context,
                    icon: Icons.sports_esports,
                    title: 'PK Challenge',
                    subtitle: 'Thách đấu bạn bè 1v1 🔥',
                    color: Colors.red,
                    route: '/challenge_list',
                  ),
                  const SizedBox(height: 12),
                  _buildUtilityCard(
                    context,
                    icon: Icons.leaderboard,
                    title: 'Bảng xếp hạng',
                    subtitle: 'Xếp hạng người chơi hàng đầu',
                    color: GamingTheme.legendaryGold,
                    route: '/leaderboard',
                  ),
                  const SizedBox(height: 12),
                  _buildUtilityCard(
                    context,
                    icon: Icons.emoji_events,
                    title: 'Thành tích',
                    subtitle: 'Xem thành tích của bạn',
                    color: GamingTheme.epicPurple,
                    route: '/achievements',
                  ),
                  const SizedBox(height: 12),
                  _buildUtilityCard(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: 'Chatbot AI',
                    subtitle: 'Trò chuyện với Gemini',
                    color: GamingTheme.primaryAccent,
                    route: '/chatbot',
                  ),
                  const SizedBox(height: 12),
                  _buildUtilityCard(
                    context,
                    icon: Icons.forum,
                    title: 'Diễn đàn',
                    subtitle: 'Bài đăng cộng đồng',
                    color: GamingTheme.secondaryAccent,
                    route: '/posts',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: GamingTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
                      border: Border.all(color: GamingTheme.border),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Navigate directly to chat screen
                          Navigator.pushNamed(context, '/peer-chat');
                        },
                        borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: GamingTheme.tertiaryAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: GamingTheme.tertiaryAccent, width: 1.5),
                                ),
                                child: Icon(Icons.chat, color: GamingTheme.tertiaryAccent, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Trò chuyện', style: GamingTheme.h3.copyWith(fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text('Nhắn tin với bạn bè', style: GamingTheme.bodyMedium),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 16, color: GamingTheme.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamingHeader(BuildContext context, String userName, int level, int totalScore) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: GamingTheme.gamingGradient,
        borderRadius: BorderRadius.circular(GamingTheme.radiusLarge),
        boxShadow: GamingTheme.neonGlow,
      ),
      child: Row(
        children: [
          // Avatar with level badge
          Stack(
            children: [
              // Glow effect
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: GamingTheme.primaryAccent.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              // Avatar
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    gradient: LinearGradient(
                      colors: [GamingTheme.primaryAccent, GamingTheme.tertiaryAccent],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      userName.substring(0, 1).toUpperCase(),
                      style: GamingTheme.h1.copyWith(fontSize: 28),
                    ),
                  ),
                ),
              ),
              // Level badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: GamingTheme.legendaryGold,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: GamingTheme.legendaryGold.withOpacity(0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    'L$level',
                    style: GamingTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: GamingTheme.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHÀO MỪNG TRỞ LẠI',
                  style: GamingTheme.bodySmall.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: GamingTheme.h2.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.stars, size: 14, color: GamingTheme.legendaryGold),
                    const SizedBox(width: 4),
                    Text(
                      '$totalScore pts',
                      style: GamingTheme.scoreDisplay.copyWith(
                        fontSize: 14,
                        color: GamingTheme.legendaryGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Profile button
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: Icon(Icons.settings, color: Colors.white),
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String icon,
    required Color color,
    String? route,
    bool isNew = false,
    bool comingSoon = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        } else if (comingSoon) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🚧 $title đang được phát triển...'),
              backgroundColor: GamingTheme.mediumOrange,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: GamingTheme.surfaceDark,
          borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
          border: Border.all(
            color: comingSoon ? GamingTheme.border : color,
            width: 2,
          ),
          boxShadow: comingSoon
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with glow
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: comingSoon
                          ? null
                          : [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 16,
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    title,
                    style: GamingTheme.h3.copyWith(
                      fontSize: 16,
                      color: comingSoon ? GamingTheme.textSecondary : color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Badge
            if (isNew || comingSoon)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isNew ? GamingTheme.easyGreen : GamingTheme.mediumOrange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isNew ? 'NEW' : 'SOON',
                    style: GamingTheme.bodySmall.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: GamingTheme.primaryDark,
                    ),
                  ),
                ),
              ),
            // Coming soon overlay
            if (comingSoon)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilityCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: GamingTheme.surfaceDark,
        borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
        border: Border.all(color: GamingTheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GamingTheme.h3.copyWith(fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GamingTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: GamingTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
