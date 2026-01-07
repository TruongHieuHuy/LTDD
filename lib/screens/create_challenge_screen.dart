import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/friend_provider.dart';
import '../providers/auth_provider.dart';
import '../config/gaming_theme.dart';
import '../widgets/gaming/gaming_app_bar.dart';
import '../widgets/gaming/gaming_card.dart';
import '../widgets/gaming/gaming_button.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({Key? key}) : super(key: key);

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  String? _selectedFriendId;
  int _betAmount = 100;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Load friends list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendProvider>().loadFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userCoins = authProvider.user?.coins ?? 0;

    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      appBar: const GamingAppBar(
        title: 'Create Challenge',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Balance
            GamingCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.amber,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Balance',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$userCoins coins',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Select Opponent
            const Text(
              'Select Opponent',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildFriendsList(),

            const SizedBox(height: 24),

            // Bet Amount
            const Text(
              'Bet Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildBetAmountSelector(userCoins),

            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: GamingButton(
                text: _isCreating ? 'Creating...' : 'Send Challenge',
                onPressed: _selectedFriendId != null && _betAmount <= userCoins && !_isCreating
                    ? _createChallenge
                    : null,
                icon: Icons.send,
                isLoading: _isCreating,
              ),
            ),

            const SizedBox(height: 16),

            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GamingTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GamingTheme.accentColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: GamingTheme.accentColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You\'ll play Best of 3 games. Both players vote for each game. Winner takes ${_betAmount * 2} coins!',
                      style: TextStyle(
                        color: GamingTheme.accentColor,
                        fontSize: 12,
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

  Widget _buildFriendsList() {
    return Consumer<FriendProvider>(
      builder: (context, friendProvider, _) {
        if (friendProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: GamingTheme.accentColor,
            ),
          );
        }

        if (friendProvider.friends.isEmpty) {
          return GamingCard(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No friends yet',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: friendProvider.friends.map((friend) {
            final isSelected = _selectedFriendId == friend.id;
            return GamingCard(
              margin: const EdgeInsets.only(bottom: 8),
              borderColor: isSelected ? GamingTheme.accentColor : null,
              onTap: () {
                setState(() {
                  _selectedFriendId = friend.id;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: friend.avatarUrl != null
                          ? NetworkImage(friend.avatarUrl!)
                          : null,
                      child: friend.avatarUrl == null
                          ? Text(
                              friend.username.substring(0, 1).toUpperCase(),
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
                            friend.username,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (friend.totalScore != null)
                            Text(
                              'Score: ${friend.totalScore}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: GamingTheme.accentColor,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBetAmountSelector(int userCoins) {
    return GamingCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Wager:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_betAmount coins',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: GamingTheme.accentColor,
                inactiveTrackColor: Colors.grey.shade800,
                thumbColor: GamingTheme.accentColor,
                overlayColor: GamingTheme.accentColor.withOpacity(0.2),
              ),
              child: Slider(
                value: _betAmount.toDouble(),
                min: 10,
                max: userCoins.toDouble().clamp(10, 10000),
                divisions: ((userCoins.clamp(10, 10000) - 10) / 10).toInt(),
                onChanged: (value) {
                  setState(() {
                    _betAmount = value.toInt();
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '10',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Max: ${userCoins.clamp(10, 10000)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Quick select buttons
            Wrap(
              spacing: 8,
              children: [
                _buildQuickAmountButton(100, userCoins),
                _buildQuickAmountButton(500, userCoins),
                _buildQuickAmountButton(1000, userCoins),
                _buildQuickAmountButton(5000, userCoins),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(int amount, int userCoins) {
    final isAvailable = amount <= userCoins;
    final isSelected = _betAmount == amount;

    return InkWell(
      onTap: isAvailable
          ? () {
              setState(() {
                _betAmount = amount;
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? GamingTheme.accentColor
              : isAvailable
                  ? Colors.grey.shade800
                  : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? GamingTheme.accentColor
                : isAvailable
                    ? Colors.grey.shade700
                    : Colors.grey.shade800,
          ),
        ),
        child: Text(
          '$amount',
          style: TextStyle(
            color: isAvailable ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _createChallenge() async {
    if (_selectedFriendId == null) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final provider = context.read<ChallengeProvider>();
      final challenge = await provider.createChallenge(
        opponentId: _selectedFriendId!,
        betAmount: _betAmount,
      );

      if (challenge != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Challenge sent! Wagered $_betAmount coins'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to challenge list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
