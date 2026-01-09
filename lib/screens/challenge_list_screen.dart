import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/auth_provider.dart';
import '../models/challenge.dart';
import '../config/gaming_theme.dart';
import 'challenge_detail_screen.dart';

class ChallengeListScreen extends StatefulWidget {
  const ChallengeListScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeListScreen> createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen> with SingleTickerProviderStateMixin {
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
    await provider.loadPendingChallenges();
    await provider.loadActiveChallenges();
    await provider.loadChallengeHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      appBar: AppBar(
        title: const Text('Thách Đấu PK'),
        backgroundColor: GamingTheme.primaryDark,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: GamingTheme.primaryAccent,
          labelColor: GamingTheme.primaryAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Chờ xác nhận'),
            Tab(text: 'Đang đấu'),
            Tab(text: 'Lịch sử'),
          ],
        ),
      ),
      body: Consumer<ChallengeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: GamingTheme.primaryAccent),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPendingTab(provider),
              _buildActiveTab(provider),
              _buildHistoryTab(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create_challenge'),
        backgroundColor: GamingTheme.primaryAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPendingTab(ChallengeProvider provider) {
    if (provider.pendingChallenges.isEmpty) {
      return _buildEmptyState('Không có thách đấu nào');
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadPendingChallenges(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.pendingChallenges.length,
        itemBuilder: (context, index) {
          final challenge = provider.pendingChallenges[index];
          return _buildPendingCard(challenge);
        },
      ),
    );
  }

  Widget _buildActiveTab(ChallengeProvider provider) {
    if (provider.activeChallenges.isEmpty) {
      return _buildEmptyState('Chưa có trận đấu nào');
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadActiveChallenges(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.activeChallenges.length,
        itemBuilder: (context, index) {
          final challenge = provider.activeChallenges[index];
          return _buildActiveCard(challenge);
        },
      ),
    );
  }

  Widget _buildHistoryTab(ChallengeProvider provider) {
    if (provider.historyChallenges.isEmpty) {
      return _buildEmptyState('Chưa có lịch sử');
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadChallengeHistory(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.historyChallenges.length,
        itemBuilder: (context, index) {
          final challenge = provider.historyChallenges[index];
          return _buildHistoryCard(challenge);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPendingCard(Challenge challenge) {
    final authProvider = context.read<AuthProvider>();
    final isCreator = challenge.isCreator(authProvider.userId ?? '');
    final opponent = isCreator ? challenge.opponent : challenge.creator;

    return Card(
      color: GamingTheme.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(opponent?.username.substring(0, 1).toUpperCase() ?? '?'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCreator ? 'Đang chờ ${opponent?.username}' : 'Thách đấu từ ${opponent?.username}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Cược: ${challenge.betAmount} xu',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isCreator) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptChallenge(challenge.id),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Chấp nhận'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rejectChallenge(challenge.id),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Từ chối'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard(Challenge challenge) {
    final authProvider = context.read<AuthProvider>();
    final isCreator = challenge.isCreator(authProvider.userId ?? '');
    final opponent = isCreator ? challenge.opponent : challenge.creator;

    return Card(
      color: GamingTheme.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChallengeDetailScreen(challengeId: challenge.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(opponent?.username.substring(0, 1).toUpperCase() ?? '?'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'vs ${opponent?.username}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Ván ${challenge.currentGame}/3 • ${challenge.creatorWins}-${challenge.opponentWins}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: GamingTheme.primaryAccent, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Challenge challenge) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId ?? '';
    final isCreator = challenge.isCreator(userId);
    final opponent = isCreator ? challenge.opponent : challenge.creator;
    final isWinner = challenge.winnerId == userId;
    final isDraw = challenge.isDraw;

    return Card(
      color: GamingTheme.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(opponent?.username.substring(0, 1).toUpperCase() ?? '?'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'vs ${opponent?.username}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${challenge.creatorWins}-${challenge.opponentWins} • ${challenge.betAmount} xu',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDraw
                    ? Colors.grey.shade800
                    : isWinner
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isDraw ? 'Hòa' : isWinner ? 'Thắng' : 'Thua',
                style: TextStyle(
                  color: isDraw ? Colors.grey : isWinner ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptChallenge(String challengeId) async {
    try {
      await context.read<ChallengeProvider>().acceptChallenge(challengeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã chấp nhận thách đấu!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectChallenge(String challengeId) async {
    try {
      await context.read<ChallengeProvider>().rejectChallenge(challengeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã từ chối thách đấu'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
