import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Giao diện trang chủ đơn giản, dễ sử dụng
class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.username ?? 'Guest';

    return Scaffold(
      // Xóa backgroundColor, dùng Container bọc để gradient nền toàn màn hình
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf8fafc), // Màu sáng chủ đạo
              Color(0xFFe0c3fc), // Tím nhạt
              Color(0xFFa1c4fd), // Xanh nhạt
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header đơn giản
                _buildSimpleHeader(userName, isDark, context, authProvider),
                const SizedBox(height: 32),

                // Danh sách trò chơi
                _buildSectionTitle('Trò chơi', isDark),
                const SizedBox(height: 16),
                _buildGamesList(context, isDark),
                const SizedBox(height: 32),

                // Tiện ích
                _buildSectionTitle('Tiện ích', isDark),
                const SizedBox(height: 16),
                _buildUtilitiesList(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleHeader(
    String userName,
    bool isDark,
    BuildContext context,
    AuthProvider authProvider,
  ) {
    // Calculate level based on total score
    final totalScore = authProvider.userProfile?.totalScore ?? 0;
    final level = (totalScore / 1000).floor() + 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D667eea),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar với level badge - có thể nhấn để vào profile
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing effect
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4DFFFFFF),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.transparent,
                    child: Text(
                      userName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Level badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 10, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          '$level',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào!',
                  style: TextStyle(fontSize: 14, color: Color(0xE6FFFFFF)),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Nhấn avatar để xem profile',
                  style: TextStyle(fontSize: 11, color: Color(0xCCFFFFFF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildGamesList(BuildContext context, bool isDark) {
    return Column(
      children: [
        // 4 game đã có - có thể chơi
        _buildSimpleCard(
          context,
          icon: Icons.casino,
          title: 'Đoán số',
          subtitle: 'Guess Number Game',
          color: Colors.blue,
          isDark: isDark,
          badge: 'MỚI',
          onTap: () => Navigator.pushNamed(context, '/guess_number_game'),
        ),
        const SizedBox(height: 12),
        _buildSimpleCard(
          context,
          icon: Icons.pets,
          title: 'Bulls & Cows',
          subtitle: 'Trò chơi logic',
          color: Colors.teal,
          isDark: isDark,
          badge: 'MỚI',
          onTap: () => Navigator.pushNamed(context, '/cows_bulls_game'),
        ),
        const SizedBox(height: 12),
        _buildSimpleCard(
          context,
          icon: Icons.style,
          title: 'Memory Match',
          subtitle: 'Lật thẻ ghép đôi',
          color: Colors.pink,
          isDark: isDark,
          badge: 'MỚI',
          onTap: () => Navigator.pushNamed(context, '/memory_match_game'),
        ),
        const SizedBox(height: 12),
        _buildSimpleCard(
          context,
          icon: Icons.calculate,
          title: 'Quick Math',
          subtitle: 'Toán nhanh',
          color: Colors.indigo,
          isDark: isDark,
          badge: 'MỚI',
          onTap: () => Navigator.pushNamed(context, '/quick_math_game'),
        ),
        const SizedBox(height: 12),
        // 4 game đang phát triển
        _buildSimpleCard(
          context,
          icon: Icons.extension,
          title: 'Rubik\'s Cube',
          subtitle: 'Giải khối Rubik 3x3',
          color: Colors.red,
          isDark: isDark,
          badge: 'SẮP RA MẮT',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🚧 Đang phát triển...')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSimpleCard(
          context,
          icon: Icons.grid_3x3,
          title: 'Sudoku',
          subtitle: 'Trò chơi điền số',
          color: Colors.purple,
          isDark: isDark,
          badge: 'SẮP RA MẮT',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🚧 Đang phát triển...')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSimpleCard(
          context,
          icon: Icons.circle_outlined,
          title: 'Caro',
          subtitle: 'Cờ caro 5 ô',
          color: Colors.green,
          isDark: isDark,
          badge: 'SẮP RA MẮT',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🚧 Đang phát triển...')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSimpleCard(
          context,
          icon: Icons.apps,
          title: 'Puzzle',
          subtitle: 'Ghép hình',
          color: Colors.orange,
          isDark: isDark,
          badge: 'SẮP RA MẮT',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🚧 Đang phát triển...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUtilitiesList(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildSimpleCard(
          context,
          icon: Icons.translate,
          title: 'Dịch thuật',
          subtitle: 'Dịch văn bản nhiều ngôn ngữ',
          color: Colors.blue,
          isDark: isDark,
          onTap: () => Navigator.pushNamed(context, '/translate'),
        ),
        const SizedBox(height: 12),
        _buildSimpleCard(
          context,
          icon: Icons.chat_bubble_outline,
          title: 'AI Chatbot',
          subtitle: 'Trò chuyện với AI',
          color: Colors.teal,
          isDark: isDark,
          onTap: () => Navigator.pushNamed(context, '/chatbot'),
        ),
        const SizedBox(height: 12),
        _buildSimpleCard(
          context,
          icon: Icons.leaderboard,
          title: 'Bảng xếp hạng',
          subtitle: 'Xem điểm số cao nhất',
          color: Colors.amber,
          isDark: isDark,
          onTap: () => Navigator.pushNamed(context, '/leaderboard'),
        ),
      ],
    );
  }

  Widget _buildSimpleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badge == 'MỚI'
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
