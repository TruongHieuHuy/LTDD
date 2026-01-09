import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/challenge_provider.dart';
import '../providers/auth_provider.dart';
import '../models/challenge.dart';
import '../config/gaming_theme.dart';
import '../widgets/gaming/gaming_app_bar.dart';
import '../widgets/gaming/gaming_card.dart';
import '../widgets/gaming/gaming_button.dart';
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
  late ConfettiController _confettiController;
  String? _votedGameType;
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadChallenge();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
      appBar: const GamingAppBar(
        title: 'Challenge Match',
        showBackButton: true,
      appBar: AppBar(
        title: const Text('Chi Tiết Trận Đấu'),
        backgroundColor: GamingTheme.primaryDark,
      ),
      body: Consumer2<ChallengeProvider, AuthProvider>(
        builder: (context, challengeProvider, authProvider, _) {
          final challenge = challengeProvider.currentChallenge;

          if (challengeProvider.isLoading || challenge == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: GamingTheme.accentColor,
                color: GamingTheme.primaryAccent,
              ),
            );
          }

          final isCreator = challenge.creatorId == authProvider.userId;

          return RefreshIndicator(
            onRefresh: _loadChallenge,
            color: GamingTheme.accentColor,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Players Header
                      _buildPlayersHeader(challenge, isCreator),

                      const SizedBox(height: 24),

                      // Match Progress
                      _buildMatchProgress(challenge),
                  // Current Game Status
                  if (challenge.status == ChallengeStatus.active)
                    _buildCurrentGameStatus(
                      challenge,
                      isCreator,
                      authProvider.userId!,
                    ),

                      const SizedBox(height: 24),

                      // Current Game Status
                      if (challenge.status == ChallengeStatus.active)
                        _buildCurrentGameStatus(challenge, isCreator, authProvider.userId!),

                      // Winner Announcement
                      if (challenge.status == ChallengeStatus.completed)
                        _buildWinnerAnnouncement(challenge, authProvider.userId!),
                    ],
                  ),
                ),

                // Confetti for winner
                if (challenge.status == ChallengeStatus.completed &&
                    challenge.winnerId == authProvider.userId)
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      numberOfParticles: 30,
                      colors: const [
                        Colors.amber,
                        GamingTheme.accentColor,
                        Colors.green,
                        Colors.blue,
                        Colors.red,
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayersHeader(Challenge challenge, bool isCreator) {
    return GamingCard(
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
                        color: GamingTheme.accentColor,
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
                    'Giải thưởng: ${challenge.betAmount * 2} xu',
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
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
        Stack(
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
            if (isYou)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: GamingTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
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
          isYou ? 'Bạn' : player.username,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isYou ? GamingTheme.accentColor : Colors.white,
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
            '$wins ${wins == 1 ? "thắng" : "thắng"}',
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
    return GamingCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiến Độ Trận Đấu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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

    // Get scores
    int creatorScore = 0;
    int opponentScore = 0;
    if (isCompleted) {
      switch (gameNumber) {
        case 1:
          creatorScore = challenge.game1CreatorScore;
          opponentScore = challenge.game1OpponentScore;
          break;
        case 2:
          creatorScore = challenge.game2CreatorScore;
          opponentScore = challenge.game2OpponentScore;
          break;
        case 3:
          creatorScore = challenge.game3CreatorScore;
          opponentScore = challenge.game3OpponentScore;
          break;
      }
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.green.shade900
              : isCurrent
                  ? GamingTheme.accentColor.withOpacity(0.2)
                  : Colors.grey.shade900,
              ? GamingTheme.primaryAccent.withOpacity(0.2)
              : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? Colors.green
                : isCurrent
                    ? GamingTheme.accentColor
                    : Colors.grey.shade800,
                ? GamingTheme.primaryAccent
                : Colors.grey.shade800,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Ván $gameNumber',
              style: TextStyle(
                fontSize: 12,
                color: isCompleted || isCurrent ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (isCompleted)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              )
            else if (isCurrent)
              Icon(
                Icons.play_circle_filled,
                color: GamingTheme.accentColor,
                color: GamingTheme.primaryAccent,
                size: 32,
              )
            else
              Icon(
                Icons.lock,
                color: Colors.grey,
                size: 32,
              ),
            if (gameType != null) ...[
              const SizedBox(height: 8),
              Text(
                _getGameName(gameType),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ],
            if (isCompleted) ...[
              const SizedBox(height: 8),
              Text(
                '$creatorScore - $opponentScore',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
      return GamingCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.how_to_vote,
                    color: GamingTheme.accentColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Bầu Chọn Game Ván $currentGame',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                    color: GamingTheme.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: GamingTheme.accentColor,
                        color: GamingTheme.primaryAccent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You voted for ${_getGameName(_votedGameType ?? userVote!)}. Waiting for opponent...',
                          style: TextStyle(
                            color: GamingTheme.accentColor,
                          ),
                          'Bạn đã bầu cho ${_getGameName(_votedGameType ?? userVote!)}. Chờ đối thủ...',
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
      // Game selected, time to play
      return GamingCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.videogame_asset,
                size: 48,
                color: GamingTheme.accentColor,
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
                'Both players selected this game!',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
                color: GamingTheme.primaryAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'Ván $currentGame: ${_getGameName(gameType)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text('Sẵn sàng chưa!', style: TextStyle(color: Colors.grey)),
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
                child: GamingButton(
                  text: 'Play Now',
                  onPressed: () => _startGame(gameType, challenge, currentGame),
                  icon: Icons.play_arrow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GamingTheme.primaryAccent,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Chơi Ngay', style: TextStyle(fontSize: 16)),
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
      {'type': 'GUESS_NUMBER', 'name': 'Đoán Số', 'icon': Icons.dialpad},
      {'type': 'COWS_BULLS', 'name': 'Bò & Bê', 'icon': Icons.pets},
      {'type': 'MEMORY_MATCH', 'name': 'Lật Hình', 'icon': Icons.grid_on},
      {'type': 'QUICK_MATH', 'name': 'Toán Nhanh', 'icon': Icons.calculate},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: games.map((game) {
        return GamingCard(
          onTap: _isVoting ? null : () => _voteForGame(game['type'] as String, gameNumber),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  game['icon'] as IconData,
                  size: 40,
                  color: GamingTheme.accentColor,
                ),
                const SizedBox(height: 12),
                Text(
                  game['name'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWinnerAnnouncement(Challenge challenge, String userId) {
    final isWinner = challenge.winnerId == userId;
    final isDraw = challenge.isDraw;

    // Play confetti for winner
    if (isWinner && !_confettiController.state.toString().contains('playing')) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
      });
    }

    return GamingCard(
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
                  ? Colors.amber
                  : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isDraw ? 'Hòa!' : isWinner ? '🎉 Thắng! 🎉' : 'Thua Cuộc',
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
                    ? Colors.amber
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isDraw
                  ? 'All games tied! Coins refunded to both players.'
                  : isWinner
                      ? 'You won ${challenge.betAmount * 2} coins!'
                      : 'You lost ${challenge.betAmount} coins.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
                  ? 'Hòa tất cả! Xu được hoàn.'
                  : isWinner
                      ? 'Bạn đã thắng ${challenge.betAmount * 2} xu!'
                      : 'Bạn đã thua ${challenge.betAmount} xu.',
                  ? 'You won ${challenge.betAmount * 2} coins!'
                  : 'You lost ${challenge.betAmount} coins.',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            if (!isDraw) ...[
              const SizedBox(height: 24),
              Text(
                'Winner: ${challenge.winner?.username}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: GamingTheme.accentColor,
                'Người thắng: ${challenge.winner?.username}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GamingTheme.primaryAccent),
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
        return 'Đoán Số';
      case 'COWS_BULLS':
        return 'Bò & Bê';
      case 'MEMORY_MATCH':
        return 'Lật Hình';
      case 'QUICK_MATH':
        return 'Toán Nhanh';
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
            content: Text('Đã bầu cho ${_getGameName(gameType)}!'),
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
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
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

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => gameScreen),
    ).then((_) {
      // Reload challenge after game
      _loadChallenge();
    });
    Navigator.push(context, MaterialPageRoute(builder: (_) => gameScreen)).then(
      (_) {
        _loadChallenge();
      },
    );
  }
}
