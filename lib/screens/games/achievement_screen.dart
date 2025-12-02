import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/game_utils/game_colors.dart';
import '../../models/achievement_model.dart';
import '../../providers/game_provider.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    _controllers = List.generate(
      gameProvider.achievements.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      ),
    );
    _animateAchievements();
  }

  void _animateAchievements() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getRarityLabel(String rarity) {
    switch (rarity) {
      case 'common':
        return 'THƯỜNG';
      case 'rare':
        return 'HIẾM';
      case 'epic':
        return 'SỬ THI';
      case 'legendary':
        return 'HUYỀN THOẠI';
      default:
        return 'UNKNOWN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final achievements = gameProvider.achievements;
    final unlockedCount = gameProvider.achievementCount;
    final totalCount = achievements.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(unlockedCount, totalCount),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    final isUnlocked = achievement.isUnlocked;
                    return _buildAchievementCard(
                      achievement,
                      isUnlocked,
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int unlocked, int total) {
    final percentage = (unlocked / total * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameColors.darkGray.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: GameColors.neonCyan),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                '🏅 HUY HIỆU',
                style: TextStyle(
                  color: GameColors.neonYellow,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Progress bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$unlocked/$total Đã Mở Khóa',
                      style: const TextStyle(
                        color: GameColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: GameColors.neonPink,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: unlocked / total,
                    minHeight: 10,
                    backgroundColor: GameColors.darkCharcoal,
                    valueColor: const AlwaysStoppedAnimation(
                      GameColors.neonPink,
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

  Widget _buildAchievementCard(
    AchievementModel achievement,
    bool isUnlocked,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _controllers[index],
      builder: (context, child) {
        final animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _controllers[index],
            curve: Curves.elasticOut,
          ),
        );

        return Transform.scale(
          scale: animation.value,
          child: GestureDetector(
            onTap: () => _showAchievementDetail(achievement, isUnlocked),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: [
                          _getRarityColor(achievement.rarity),
                          _getRarityColor(achievement.rarity).withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [GameColors.darkCharcoal, GameColors.darkGray],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border.all(
                  color: isUnlocked
                      ? _getRarityColor(achievement.rarity)
                      : GameColors.textGray,
                  width: 2,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: _getRarityColor(
                            achievement.rarity,
                          ).withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rarity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? _getRarityColor(achievement.rarity)
                            : GameColors.darkGray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getRarityLabel(achievement.rarity),
                        style: TextStyle(
                          color: isUnlocked
                              ? GameColors.textWhite
                              : GameColors.textGray,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Icon
                    Opacity(
                      opacity: isUnlocked ? 1.0 : 0.3,
                      child: Text(
                        achievement.iconEmoji,
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                    // Title
                    Text(
                      achievement.name,
                      style: TextStyle(
                        color: isUnlocked
                            ? GameColors.textWhite
                            : GameColors.textGray,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Lock indicator
                    if (!isUnlocked)
                      const Icon(
                        Icons.lock,
                        color: GameColors.textGray,
                        size: 20,
                      )
                    else
                      const Icon(
                        Icons.check_circle,
                        color: GameColors.neonGreen,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAchievementDetail(AchievementModel achievement, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getRarityColor(achievement.rarity),
                _getRarityColor(achievement.rarity).withOpacity(0.5),
                GameColors.darkGray,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _getRarityColor(achievement.rarity),
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rarity badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getRarityColor(achievement.rarity),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getRarityLabel(achievement.rarity),
                  style: const TextStyle(
                    color: GameColors.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Icon
              Text(achievement.iconEmoji, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              // Title
              Text(
                achievement.name,
                style: const TextStyle(
                  color: GameColors.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              // Description
              Text(
                achievement.description,
                style: const TextStyle(
                  color: GameColors.textGray,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? GameColors.neonGreen.withOpacity(0.2)
                      : GameColors.darkCharcoal,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUnlocked ? Icons.check_circle : Icons.lock,
                      color: isUnlocked
                          ? GameColors.neonGreen
                          : GameColors.textGray,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isUnlocked ? 'ĐÃ MỞ KHÓA' : 'CHƯA MỞ KHÓA',
                      style: TextStyle(
                        color: isUnlocked
                            ? GameColors.neonGreen
                            : GameColors.textGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Close button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameColors.neonCyan,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'ĐÓNG',
                  style: TextStyle(
                    color: GameColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
