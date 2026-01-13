import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/gaming_theme.dart';
import '../services/api_service.dart';

/// Admin Dashboard Screen - Chỉ dành cho ADMIN và MODERATOR
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  List<dynamic>? _activities;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await ApiService().getAdminStats();
      final activities = await ApiService().getRecentActivities();

      if (mounted) {
        setState(() {
          _stats = stats;
          _activities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.amber),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Admin Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Làm mới',
          ),
          // Switch to User View
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/modular');
            },
            tooltip: 'Chuyển sang giao diện User',
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: GamingTheme.primaryAccent,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          color: GamingTheme.hardRed, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Đã xảy ra lỗi tải dữ liệu',
                        style: GamingTheme.h3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: GamingTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GamingTheme.primaryAccent,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Header
                      _buildWelcomeHeader(authProvider),
                      const SizedBox(height: 24),

                      // Statistics Cards
                      _buildStatisticsCards(),
                      const SizedBox(height: 24),

                      // Quick Actions
                      Text(
                        'Quản lý',
                        style: GamingTheme.h2,
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),

                      // Recent Activity
                      _buildRecentActivity(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWelcomeHeader(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurple.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              authProvider.isAdmin
                  ? Icons.admin_panel_settings
                  : Icons.verified_user,
              size: 35,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${authProvider.username ?? "Admin"}!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    authProvider.userRole,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    if (_stats == null) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Tổng User',
                '${_stats!['totalUsers']}',
                Icons.people,
                GamingTheme.primaryAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Games Played',
                '${_stats!['totalGameSessions']}',
                Icons.sports_esports,
                GamingTheme.easyGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Challenges',
                '${_stats!['totalChallenges']}',
                Icons.flash_on,
                GamingTheme.hardRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Bài viết',
                '${_stats!['totalPosts']}',
                Icons.article,
                GamingTheme.mediumOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GamingTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GamingTheme.h2.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GamingTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'title': 'Quản lý User',
        'icon': Icons.people_outline,
        'color': Colors.blue,
        'onTap': () => _showComingSoon(context, 'Quản lý User'),
      },
      {
        'title': 'Quản lý Games',
        'icon': Icons.sports_esports_outlined,
        'color': Colors.green,
        'onTap': () => _showComingSoon(context, 'Quản lý Games'),
      },
      {
        'title': 'Leaderboard',
        'icon': Icons.leaderboard,
        'color': Colors.orange,
        'onTap': () => Navigator.pushNamed(context, '/leaderboard'),
      },
      {
        'title': 'Achievements',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'onTap': () => Navigator.pushNamed(context, '/achievements'),
      },
      {
        'title': 'Reports',
        'icon': Icons.report_problem_outlined,
        'color': Colors.red,
        'onTap': () => _showComingSoon(context, 'Reports'),
      },
      {
        'title': 'Settings',
        'icon': Icons.settings_outlined,
        'color': Colors.purple,
        'onTap': () => _showComingSoon(context, 'Settings'),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(
          action['title'] as String,
          action['icon'] as IconData,
          action['color'] as Color,
          action['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: GamingTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GamingTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    if (_activities == null || _activities!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Chưa có hoạt động nào gần đây',
            style: GamingTheme.bodySmall,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hoạt động gần đây',
              style: GamingTheme.h2,
            ),
            TextButton(
              onPressed: _fetchData,
              child: const Text('Làm mới'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: GamingTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activities!.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: Colors.white10,
            ),
            itemBuilder: (context, index) {
              final activity = _activities![index];
              return _buildActivityItem(
                activity['message'] ?? '',
                _formatTime(activity['timestamp']),
                _getIconForType(activity['type']),
                _getColorForType(activity['color']),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'high_score':
        return Icons.star;
      case 'challenge':
        return Icons.flash_on;
      case 'post':
        return Icons.article;
      case 'new_user':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String? colorName) {
    switch (colorName) {
      case 'gold':
        return GamingTheme.legendaryGold;
      case 'red':
        return GamingTheme.hardRed;
      case 'blue':
        return GamingTheme.rareBlue;
      case 'green':
        return GamingTheme.easyGreen;
      default:
        return GamingTheme.primaryAccent;
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'Vừa xong';
      if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
      if (difference.inHours < 24) return '${difference.inHours} giờ trước';
      return '${difference.inDays} ngày trước';
    } catch (e) {
      return '';
    }
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GamingTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        time,
        style: GamingTheme.bodySmall,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.construction, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Coming Soon'),
          ],
        ),
        content: Text('Tính năng "$feature" đang được phát triển!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
