import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_score_model.dart';
import '../../providers/game_provider.dart';
import '../../config/gaming_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all';
  late AnimationController _podiumController;

  // 8 games mapping
  final Map<String, Map<String, dynamic>> _gameFilters = {
    'all': {'label': 'Tất cả', 'emoji': '🎮', 'color': GamingTheme.primaryAccent},
    'guess_number': {'label': 'Đoán Số', 'emoji': '🎲', 'color': GamingTheme.easyGreen},
    'cows_bulls': {'label': 'Bò & Bê', 'emoji': '🐮', 'color': GamingTheme.mediumOrange},
    'memory_match': {'label': 'Memory', 'emoji': '🧠', 'color': GamingTheme.hardRed},
    'quick_math': {'label': 'Quick Math', 'emoji': '⚡', 'color': GamingTheme.expertPurple},
    'rubik': {'label': 'Rubik', 'emoji': '🎨', 'color': GamingTheme.rareBlue},
    'sudoku': {'label': 'Sudoku', 'emoji': '🔢', 'color': GamingTheme.epicPurple},
    'caro': {'label': 'Caro', 'emoji': '⭕', 'color': GamingTheme.easyGreen},
    'puzzle': {'label': 'Puzzle', 'emoji': '🧩', 'color': GamingTheme.legendaryGold},
  };

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
      backgroundColor: GamingTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (topThree.isNotEmpty)
                      _buildPodium(topThree)
                    else
                      _buildEmptyState(),
                    const SizedBox(height: 30),
                    ...others.asMap().entries.map((entry) {
                      return _buildLeaderboardItem(entry.value, entry.key + 4);
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: GamingTheme.gamingGradient,
        boxShadow: GamingTheme.neonGlow,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            '🏆 BẢNG XẾP HẠNG',
            style: GamingTheme.h2.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _gameFilters.length,
        itemBuilder: (context, index) {
          final key = _gameFilters.keys.elementAt(index);
          final filter = _gameFilters[key]!;
          final isSelected = _selectedFilter == key;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildFilterChip(
              filter['label'],
              key,
              filter['emoji'],
              filter['color'],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String emoji, Color color) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
          _podiumController.forward(from: 0); // Replay animation
        });
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 70,
          maxWidth: 120,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : GamingTheme.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : GamingTheme.border,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GamingTheme.bodySmall.copyWith(
                  color: isSelected ? color : GamingTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: GamingTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có dữ liệu',
            style: GamingTheme.h3.copyWith(color: GamingTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Chơi game để lên bảng xếp hạng!',
            style: GamingTheme.bodyMedium,
          ),
        ],
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
              _buildPodiumPlace(topThree[1], 2, 120, GamingTheme.commonGray, 0.3),
            if (topThree.isNotEmpty)
              _buildPodiumPlace(topThree[0], 1, 150, GamingTheme.legendaryGold, 0.0),
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
        curve: Interval(animationDelay, 1.0, curve: Curves.elasticOut),
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
              backgroundColor: GamingTheme.surfaceDark,
              child: Text(
                rank == 1 ? '👑' : rank == 2 ? '🥈' : '🥉',
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          // Name
          SizedBox(
            width: 80,
            child: Text(
              score.playerName,
              style: GamingTheme.bodyMedium.copyWith(
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
            style: GamingTheme.scoreDisplay.copyWith(
              fontSize: rank == 1 ? 16 : 14,
              color: Colors.white,
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
                style: GamingTheme.h2.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(GameScoreModel score, int rank) {
    final gameInfo = _gameFilters[score.gameType];
    final gameColor = gameInfo?['color'] ?? GamingTheme.primaryAccent;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GamingTheme.surfaceDark,
        borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
        border: Border.all(
          color: GamingTheme.border,
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
              color: gameColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: gameColor, width: 2),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: GamingTheme.bodyMedium.copyWith(
                  color: gameColor,
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
                  style: GamingTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${gameInfo?['emoji'] ?? '🎮'} ${gameInfo?['label'] ?? score.gameType}',
                      style: GamingTheme.bodySmall.copyWith(
                        color: GamingTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${score.attempts} lượt',
                      style: GamingTheme.bodySmall.copyWith(
                        color: GamingTheme.textSecondary,
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
            style: GamingTheme.scoreDisplay.copyWith(
              fontSize: 20,
              color: gameColor,
            ),
          ),
        ],
      ),
    );
  }
}
