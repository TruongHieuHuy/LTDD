import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/achievement_model.dart';

/// Screen displaying all achievements with user progress
class AchievementsScreen extends StatefulWidget {
  final String userId;

  const AchievementsScreen({super.key, required this.userId});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserAchievementData> _achievements = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String _selectedCategory = 'all';

  final Map<String, String> _categoryNames = {
    'all': 'Tất Cả',
    'general': 'Chung',
    'games': 'Game',
    'social': 'Xã Hội',
    'milestone': 'Cột Mốc',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAchievements();
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _categoryNames.keys.elementAt(_tabController.index);
      });
    }
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      final achievements = await ApiService().getUserAchievements(
        widget.userId.hashCode,
      );

      setState(() {
        _achievements = achievements.cast<UserAchievementData>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải achievements: $e')));
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ApiService().getAchievementStats(
        widget.userId.hashCode,
      );
      setState(() => _stats = stats);
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> _checkNewAchievements() async {
    try {
      final newlyUnlocked = await ApiService().checkAchievements(
        widget.userId.hashCode,
      );

      if (newlyUnlocked.isNotEmpty && mounted) {
        // Show unlock animation
        _showUnlockDialog(newlyUnlocked);

        // Reload achievements
        await _loadAchievements();
        await _loadStats();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có achievement mới')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  void _showUnlockDialog(List newlyUnlocked) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'Chúc Mừng! 🎉',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn đã mở khóa ${newlyUnlocked.length} achievement mới!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...newlyUnlocked.map(
                (ach) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        ach['icon'] ?? '🏆',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ach['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${ach['points'] ?? 0} điểm',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tuyệt vời!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<UserAchievementData> get _filteredAchievements {
    if (_selectedCategory == 'all') return _achievements;
    return _achievements.where((a) => a.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlockedCount = _achievements.where((a) => a.unlocked).length;
    final totalPoints = _stats?['totalPoints'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thành Tích'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkNewAchievements,
            tooltip: 'Kiểm tra achievement mới',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categoryNames.values.map((name) => Tab(text: name)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.emoji_events,
                        label: 'Đã Mở',
                        value: '$unlockedCount/${_achievements.length}',
                        color: Colors.amber,
                      ),
                      _buildStatItem(
                        icon: Icons.star,
                        label: 'Tổng Điểm',
                        value: totalPoints.toString(),
                        color: Colors.blue,
                      ),
                      _buildStatItem(
                        icon: Icons.trending_up,
                        label: 'Tiến Độ',
                        value:
                            '${(_achievements.isEmpty ? 0 : (unlockedCount / _achievements.length * 100)).toStringAsFixed(0)}%',
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),

                // Achievements List
                Expanded(
                  child: _filteredAchievements.isEmpty
                      ? const Center(child: Text('Không có achievement nào'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredAchievements.length,
                          itemBuilder: (context, index) {
                            final achievement = _filteredAchievements[index];
                            return _buildAchievementCard(achievement);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAchievementCard(UserAchievementData achievement) {
    final isUnlocked = achievement.unlocked;
    final progress = achievement.progress;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isUnlocked ? 4 : 1,
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isUnlocked
                ? Colors.amber.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              achievement.icon,
              style: TextStyle(
                fontSize: 32,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
          ),
        ),
        title: Text(
          achievement.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(
                fontSize: 12,
                color: isUnlocked ? Colors.grey[600] : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            if (!isUnlocked && progress > 0) ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnlocked ? Icons.check_circle : Icons.lock,
              color: isUnlocked ? Colors.green : Colors.grey,
            ),
            Text(
              '${achievement.points} pts',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.amber : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
