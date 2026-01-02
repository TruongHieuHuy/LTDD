import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/auth_provider.dart';
import '../models/challenge.dart';
import '../config/gaming_theme.dart';
import '../widgets/gaming/gaming_app_bar.dart';
import '../widgets/gaming/gaming_card.dart';
import '../widgets/gaming/gaming_button.dart';
import 'create_challenge_screen.dart';
import 'challenge_detail_screen.dart';

class ChallengeListScreen extends StatefulWidget {
  const ChallengeListScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeListScreen> createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<ChallengeProvider>();
    await Future.wait([
      provider.loadPendingChallenges(),
      provider.loadActiveChallenges(),
      provider.loadChallengeHistory(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      appBar: GamingAppBar(
        title: 'PK Challenges',
        showBackButton: true,
        actions: [
          Consumer<ChallengeProvider>(
            builder: (context, provider, _) {
              final pendingCount = provider.pendingCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      _tabController.animateTo(0); // Go to Pending tab
                    },
                  ),
                  if (pendingCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: GamingTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '$pendingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: GamingTheme.primaryLight,
            child: TabBar(
              controller: _tabController,
              indicatorColor: GamingTheme.accentColor,
              labelColor: GamingTheme.accentColor,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(
                  child: Consumer<ChallengeProvider>(
                    builder: (context, provider, _) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Pending'),
                        if (provider.pendingCount > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: GamingTheme.accentColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${provider.pendingCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Tab(text: 'Active'),
                const Tab(text: 'History'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTab(),
                _buildActiveTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateChallengeScreen(),
            ),
          );
        },
        backgroundColor: GamingTheme.accentColor,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('New Challenge'),
      ),
    );
  }

  // ==================== PENDING TAB ====================
  Widget _buildPendingTab() {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: GamingTheme.accentColor,
            ),
          );
        }

        if (provider.pendingChallenges.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox_outlined,
            title: 'No Pending Challenges',
            subtitle: 'Create a new challenge to compete with friends!',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadPendingChallenges(),
          color: GamingTheme.accentColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.pendingChallenges.length,
            itemBuilder: (context, index) {
              final challenge = provider.pendingChallenges[index];
              return _buildPendingChallengeCard(challenge);
            },
          ),
        );
      },
    );
  }

  Widget _buildPendingChallengeCard(Challenge challenge) {
    final auth = context.read<AuthProvider>();
    final isCreator = challenge.creatorId == auth.userId;
    final opponent = isCreator ? challenge.opponent : challenge.creator;

    return GamingCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: opponent?.avatarUrl != null
                      ? NetworkImage(opponent!.avatarUrl!)
                      : null,
                  child: opponent?.avatarUrl == null
                      ? Text(
                          opponent?.username.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(fontSize: 20),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCreator
                            ? 'Challenge Sent to ${opponent?.username}'
                            : '${opponent?.username} challenged you!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${challenge.betAmount} coins',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeLeft(challenge.expiresAt),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Actions
            if (!isCreator) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GamingButton(
                      text: 'Accept',
                      onPressed: () => _acceptChallenge(challenge),
                      icon: Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GamingButton(
                      text: 'Reject',
                      onPressed: () => _rejectChallenge(challenge),
                      backgroundColor: Colors.red.shade700,
                      icon: Icons.cancel,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'Waiting for ${opponent?.username} to respond...',
                style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== ACTIVE TAB ====================
  Widget _buildActiveTab() {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: GamingTheme.accentColor,
            ),
          );
        }

        if (provider.activeChallenges.isEmpty) {
          return _buildEmptyState(
            icon: Icons.sports_esports_outlined,
            title: 'No Active Matches',
            subtitle: 'Accept a challenge to start competing!',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadActiveChallenges(),
          color: GamingTheme.accentColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.activeChallenges.length,
            itemBuilder: (context, index) {
              final challenge = provider.activeChallenges[index];
              return _buildActiveChallengeCard(challenge);
            },
          ),
        );
      },
    );
  }

  Widget _buildActiveChallengeCard(Challenge challenge) {
    final auth = context.read<AuthProvider>();
    final isCreator = challenge.creatorId == auth.userId;

    return GamingCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChallengeDetailScreen(challengeId: challenge.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Players
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlayerInfo(challenge.creator!, isYou: isCreator),
                Column(
                  children: [
                    Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GamingTheme.accentColor,
                      ),
                    ),
                    Text(
                      '${challenge.creatorWins} - ${challenge.opponentWins}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                _buildPlayerInfo(challenge.opponent!, isYou: !isCreator),
              ],
            ),

            const Divider(height: 24),

            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGameProgress(1, challenge),
                _buildGameProgress(2, challenge),
                _buildGameProgress(3, challenge),
              ],
            ),

            const SizedBox(height: 12),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: GamingTheme.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GamingTheme.accentColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_filled,
                    size: 16,
                    color: GamingTheme.accentColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Game ${challenge.currentGame} - ${_getChallengeStatus(challenge)}',
                    style: TextStyle(
                      color: GamingTheme.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HISTORY TAB ====================
  Widget _buildHistoryTab() {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: GamingTheme.accentColor,
            ),
          );
        }

        if (provider.historyChallenges.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            title: 'No History',
            subtitle: 'Complete challenges to see your match history',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadChallengeHistory(),
          color: GamingTheme.accentColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.historyChallenges.length,
            itemBuilder: (context, index) {
              final challenge = provider.historyChallenges[index];
              return _buildHistoryChallengeCard(challenge);
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryChallengeCard(Challenge challenge) {
    final auth = context.read<AuthProvider>();
    final isCreator = challenge.creatorId == auth.userId;
    final isWinner = challenge.winnerId == auth.userId;
    final isDraw = challenge.isDraw;

    return GamingCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildPlayerInfo(challenge.creator!, isYou: isCreator, compact: true),
                      const SizedBox(width: 8),
                      Text(
                        '${challenge.creatorWins}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  ' - ',
                  style: TextStyle(color: Colors.grey),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${challenge.opponentWins}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildPlayerInfo(challenge.opponent!, isYou: !isCreator, compact: true),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Result
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDraw
                    ? Colors.grey.shade800
                    : isWinner
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isDraw
                        ? Icons.handshake
                        : isWinner
                            ? Icons.emoji_events
                            : Icons.sentiment_dissatisfied,
                    color: isDraw
                        ? Colors.grey
                        : isWinner
                            ? Colors.amber
                            : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isDraw
                          ? 'Draw - Coins Refunded'
                          : isWinner
                              ? 'Victory! +${challenge.betAmount * 2} coins'
                              : 'Defeat - ${challenge.betAmount} coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildPlayerInfo(ChallengeUser player, {required bool isYou, bool compact = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: compact ? 16 : 24,
          backgroundImage: player.avatarUrl != null
              ? NetworkImage(player.avatarUrl!)
              : null,
          child: player.avatarUrl == null
              ? Text(
                  player.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(fontSize: compact ? 14 : 20),
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          isYou ? 'You' : player.username,
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.bold,
            color: isYou ? GamingTheme.accentColor : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGameProgress(int gameNumber, Challenge challenge) {
    final isCompleted = challenge.isGameCompleted(gameNumber);
    final isCurrent = challenge.currentGame == gameNumber;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.shade700
                : isCurrent
                    ? GamingTheme.accentColor
                    : Colors.grey.shade800,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white)
                : Text(
                    '$gameNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Game $gameNumber',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  String _formatTimeLeft(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h left';
    } else {
      return '${remaining.inMinutes}m left';
    }
  }

  String _getChallengeStatus(Challenge challenge) {
    final gameType = challenge.getGameType(challenge.currentGame);
    if (gameType != null) {
      return 'Playing';
    } else {
      return 'Vote for game';
    }
  }

  Future<void> _acceptChallenge(Challenge challenge) async {
    final provider = context.read<ChallengeProvider>();
    final success = await provider.acceptChallenge(challenge.id);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Challenge accepted! Let\'s play!'),
          backgroundColor: Colors.green,
        ),
      );
      _tabController.animateTo(1); // Switch to Active tab
    }
  }

  Future<void> _rejectChallenge(Challenge challenge) async {
    final provider = context.read<ChallengeProvider>();
    final success = await provider.rejectChallenge(challenge.id);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Challenge rejected'),
        ),
      );
    }
  }
}
