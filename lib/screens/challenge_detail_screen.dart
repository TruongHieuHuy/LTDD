import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/auth_provider.dart';
import '../models/challenge.dart';
import '../config/gaming_theme.dart';
import 'games/guess_number_game_screen.dart';
import 'games/cows_bulls_game_screen.dart';
import 'games/memory_match_game_screen.dart';
import 'games/quick_math_game_screen.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({Key? key, required this.challengeId})
    : super(key: key);

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  String? _votedGameType;
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  Future<void> _loadChallenge() async {
    await context.read<ChallengeProvider>().loadChallengeDetails(
      widget.challengeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      appBar: AppBar(
        title: const Text('Challenge Match'),
        backgroundColor: GamingTheme.primaryDark,
      ),
      body: Consumer2<ChallengeProvider, AuthProvider>(
        builder: (context, challengeProvider, authProvider, _) {
          final challenge = challengeProvider.currentChallenge;

          if (challengeProvider.isLoading || challenge == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: GamingTheme.primaryAccent,
              ),
            );
          }

          final isCreator = challenge.isCreator(authProvider.userId ?? '');

          return RefreshIndicator(
            onRefresh: _loadChallenge,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Players Header
                  _buildPlayersHeader(challenge, isCreator),
                  const SizedBox(height: 24),

                  // Match Progress
                  _buildMatchProgress(challenge),
                  const SizedBox(height: 24),

                  // Current Game Status
                  if (challenge.status == ChallengeStatus.active)
                    _buildCurrentGameStatus(
                      challenge,
                      isCreator,
                      authProvider.userId!,
                    ),

                  // Winner Announcement
                  if (challenge.status == ChallengeStatus.completed)
                    _buildWinnerAnnouncement(challenge, authProvider.userId!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayersHeader(Challenge challenge, bool isCreator) {
    return Card(
      color: GamingTheme.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Creator
                _buildPlayerColumn(
                  challenge.creator!,
                  challenge.creatorWins,
                  isCreator,
                ),

                // VS
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: GamingTheme.primaryAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${challenge.creatorWins} - ${challenge.opponentWins}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                // Opponent
                _buildPlayerColumn(
                  challenge.opponent!,
                  challenge.opponentWins,
                  !isCreator,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bet Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Prize Pool: ${challenge.betAmount * 2} coins',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildPlayerColumn(ChallengeUser player, int wins, bool isYou) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: player.avatarUrl != null
              ? NetworkImage(player.avatarUrl!)
              : null,
          child: player.avatarUrl == null
              ? Text(
                  player.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 28),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          isYou ? 'You' : player.username,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isYou ? GamingTheme.primaryAccent : Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$wins ${wins == 1 ? "win" : "wins"}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchProgress(Challenge challenge) {
    return Card(
      color: GamingTheme.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Match Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGameCard(1, challenge),
                _buildGameCard(2, challenge),
                _buildGameCard(3, challenge),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(int gameNumber, Challenge challenge) {
    final isCompleted = challenge.isGameCompleted(gameNumber);
    final isCurrent = challenge.currentGame == gameNumber && !isCompleted;
    final gameType = challenge.getGameType(gameNumber);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.green.shade900
              : isCurrent
              ? GamingTheme.primaryAccent.withOpacity(0.2)
              : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? Colors.green
                : isCurrent
                ? GamingTheme.primaryAccent
                : Colors.grey.shade800,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Game $gameNumber',
              style: TextStyle(
                fontSize: 12,
                color: isCompleted || isCurrent ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green, size: 32)
            else if (isCurrent)
              Icon(
                Icons.play_circle_filled,
                color: GamingTheme.primaryAccent,
                size: 32,
              )
            else
              const Icon(Icons.lock, color: Colors.grey, size: 32),
            if (gameType != null) ...[
              const SizedBox(height: 8),
              Text(
                _getGameName(gameType),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentGameStatus(
    Challenge challenge,
    bool isCreator,
    String userId,
  ) {
    final currentGame = challenge.currentGame;
    final gameType = challenge.getGameType(currentGame);

    // Check if user has voted
    final userVote = isCreator
        ? (currentGame == 1
              ? challenge.game1CreatorVote
              : currentGame == 2
              ? challenge.game2CreatorVote
              : challenge.game3CreatorVote)
        : (currentGame == 1
              ? challenge.game1OpponentVote
              : currentGame == 2
              ? challenge.game2OpponentVote
              : challenge.game3OpponentVote);

    final hasVoted = userVote != null || _votedGameType != null;

    if (gameType == null) {
      // Voting phase
      return Card(
        color: GamingTheme.surfaceDark,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.how_to_vote, color: GamingTheme.primaryAccent),
                  const SizedBox(width: 12),
                  Text(
                    'Vote for Game $currentGame',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (hasVoted)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GamingTheme.primaryAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: GamingTheme.primaryAccent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You voted for ${_getGameName(_votedGameType ?? userVote!)}. Waiting for opponent...',
                          style: TextStyle(color: GamingTheme.primaryAccent),
                        ),
                      ),
                    ],
                  ),
                )
              else
                _buildGameVotingOptions(challenge, currentGame),
            ],
          ),
        ),
      );
    } else {
      // Game selected
      return Card(
        color: GamingTheme.surfaceDark,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.videogame_asset,
                size: 48,
                color: GamingTheme.primaryAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'Game $currentGame: ${_getGameName(gameType)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ready to play!',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startGame(gameType, challenge, currentGame),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GamingTheme.primaryAccent,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Play Now', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildGameVotingOptions(Challenge challenge, int gameNumber) {
    final games = [
      {'type': 'GUESS_NUMBER', 'name': 'Guess Number', 'icon': Icons.dialpad},
      {'type': 'COWS_BULLS', 'name': 'Cows & Bulls', 'icon': Icons.pets},
      {'type': 'MEMORY_MATCH', 'name': 'Memory Match', 'icon': Icons.grid_on},
      {'type': 'QUICK_MATH', 'name': 'Quick Math', 'icon': Icons.calculate},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: games.map((game) {
        return Card(
          color: GamingTheme.surfaceDark,
          child: InkWell(
            onTap: _isVoting
                ? null
                : () => _voteForGame(game['type'] as String, gameNumber),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    game['icon'] as IconData,
                    size: 40,
                    color: GamingTheme.primaryAccent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    game['name'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWinnerAnnouncement(Challenge challenge, String userId) {
    final isWinner = challenge.winnerId == userId;
    final isDraw = challenge.isDraw;

    return Card(
      color: GamingTheme.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              isDraw
                  ? Icons.handshake
                  : isWinner
                  ? Icons.emoji_events
                  : Icons.sentiment_dissatisfied,
              size: 64,
              color: isDraw
                  ? Colors.grey
                  : isWinner
                  ? Colors.amber
                  : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isDraw
                  ? 'Match Drawn!'
                  : isWinner
                  ? '🎉 Victory! 🎉'
                  : 'Defeat',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDraw
                    ? Colors.grey
                    : isWinner
                    ? Colors.amber
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isDraw
                  ? 'All games tied! Coins refunded.'
                  : isWinner
                  ? 'You won ${challenge.betAmount * 2} coins!'
                  : 'You lost ${challenge.betAmount} coins.',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            if (!isDraw) ...[
              const SizedBox(height: 24),
              Text(
                'Winner: ${challenge.winner?.username}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: GamingTheme.primaryAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getGameName(String gameType) {
    switch (gameType) {
      case 'GUESS_NUMBER':
        return 'Guess Number';
      case 'COWS_BULLS':
        return 'Cows & Bulls';
      case 'MEMORY_MATCH':
        return 'Memory Match';
      case 'QUICK_MATH':
        return 'Quick Math';
      default:
        return gameType;
    }
  }

  Future<void> _voteForGame(String gameType, int gameNumber) async {
    setState(() {
      _isVoting = true;
      _votedGameType = gameType;
    });

    try {
      final provider = context.read<ChallengeProvider>();
      await provider.voteForGame(
        challengeId: widget.challengeId,
        gameNumber: gameNumber,
        gameType: gameType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voted for ${_getGameName(gameType)}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _votedGameType = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    }
  }

  void _startGame(String gameType, Challenge challenge, int gameNumber) {
    Widget gameScreen;

    switch (gameType) {
      case 'GUESS_NUMBER':
        gameScreen = const GuessNumberGameScreen();
        break;
      case 'COWS_BULLS':
        gameScreen = const CowsBullsGameScreen();
        break;
      case 'MEMORY_MATCH':
        gameScreen = const MemoryMatchGameScreen();
        break;
      case 'QUICK_MATH':
        gameScreen = const QuickMathGameScreen();
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => gameScreen)).then(
      (_) {
        _loadChallenge();
      },
    );
  }
}
