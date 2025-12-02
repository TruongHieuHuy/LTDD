import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/game_utils/game_colors.dart';
import '../../models/game_score_model.dart';
import '../../providers/game_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all'; // 'all', 'guess_number', 'cows_bulls'
  late AnimationController _podiumController;

  @override
  void initState() {
    super.initState();
    _podiumController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _podiumController.dispose();
    super.dispose();
  }

  List<GameScoreModel> get _filteredScores {
    final gameProvider = Provider.of<GameProvider>(context);
    return gameProvider.getLeaderboard(
      gameType: _selectedFilter == 'all' ? null : _selectedFilter,
      limit: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topThree = _filteredScores.take(3).toList();
    final others = _filteredScores.skip(3).take(7).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterChips(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (topThree.isNotEmpty) _buildPodium(topThree),
                      const SizedBox(height: 30),
                      ...others.asMap().entries.map((entry) {
                        return _buildLeaderboardItem(
                          entry.value,
                          entry.key + 4,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameColors.darkGray.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: GameColors.neonCyan),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            '🏆 BẢNG XẾP HẠNG',
            style: TextStyle(
              color: GameColors.neonYellow,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterChip('Tất cả', 'all', '🎮'),
          _buildFilterChip('Đoán Số', 'guess_number', '🎲'),
          _buildFilterChip('Bò & Bê', 'cows_bulls', '🐮'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String emoji) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? GameColors.neonPink : GameColors.darkCharcoal,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? GameColors.neonPink : GameColors.textGray,
            width: 2,
          ),
        ),
        child: Text(
          '$emoji $label',
          style: TextStyle(
            color: isSelected ? GameColors.textWhite : GameColors.textGray,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List<GameScoreModel> topThree) {
    return AnimatedBuilder(
      animation: _podiumController,
      builder: (context, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (topThree.length > 1)
              _buildPodiumPlace(topThree[1], 2, 120, GameColors.textGray, 0.8),
            if (topThree.isNotEmpty)
              _buildPodiumPlace(
                topThree[0],
                1,
                150,
                GameColors.neonYellow,
                1.0,
              ),
            if (topThree.length > 2)
              _buildPodiumPlace(topThree[2], 3, 100, Color(0xFFCD7F32), 0.6),
          ],
        );
      },
    );
  }

  Widget _buildPodiumPlace(
    GameScoreModel score,
    int rank,
    double height,
    Color color,
    double animationDelay,
  ) {
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _podiumController,
        curve: Interval(animationDelay * 0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    return Transform.scale(
      scale: animation.value,
      child: Column(
        children: [
          // Avatar
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: rank == 1 ? 35 : 30,
              backgroundColor: GameColors.darkGray,
              child: Text(
                rank == 1
                    ? '👑'
                    : rank == 2
                    ? '🥈'
                    : '🥉',
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          // Name
          SizedBox(
            width: 80,
            child: Text(
              score.playerName,
              style: TextStyle(
                color: color,
                fontSize: rank == 1 ? 14 : 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Score
          Text(
            '${score.score} pts',
            style: TextStyle(
              color: GameColors.textWhite,
              fontSize: rank == 1 ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          // Podium block
          Container(
            width: 80,
            height: height * animation.value,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: GameColors.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(GameScoreModel score, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.darkGray.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: GameColors.neonCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: GameColors.darkCharcoal,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: GameColors.neonCyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.playerName,
                  style: const TextStyle(
                    color: GameColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      score.gameType == 'guess_number'
                          ? '🎲 Đoán Số'
                          : '🐮 Bò Bê',
                      style: const TextStyle(
                        color: GameColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${score.attempts} lượt',
                      style: const TextStyle(
                        color: GameColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Score
          Text(
            '${score.score}',
            style: const TextStyle(
              color: GameColors.neonYellow,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
