import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/auth_provider.dart';
import '../config/gaming_theme.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({Key? key}) : super(key: key);

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  String? _selectedFriendId;
  int _betAmount = 100;
  bool _isCreating = false;

  // Mock friends list (temporary - replace with real FriendProvider later)
  final List<Map<String, String>> _mockFriends = [
    {'id': 'user_1', 'name': 'Nguyễn Văn A', 'avatar': '👤'},
    {'id': 'user_2', 'name': 'Trần Thị B', 'avatar': '👩'},
    {'id': 'user_3', 'name': 'Lê Văn C', 'avatar': '🧑'},
    {'id': 'user_4', 'name': 'Phạm Thị D', 'avatar': '👧'},
    {'id': 'user_5', 'name': 'Hoàng Văn E', 'avatar': '👨'},
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual coins from user when coins field is added to UserProfile
    final userCoins = 1000; // Hardcoded for now

    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      appBar: AppBar(
        title: const Text('Create Challenge'),
        backgroundColor: GamingTheme.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Balance
            Card(
              color: GamingTheme.surfaceDark,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.amber, size: 32),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Balance', style: TextStyle(color: Colors.grey)),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            ..._mockFriends.map((friend) => _buildFriendCard(friend)),

            const SizedBox(height: 24),

            // Bet Amount
            const Text(
              'Bet Amount',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Card(
              color: GamingTheme.surfaceDark,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Wager:', style: TextStyle(color: Colors.white)),
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
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
                    Slider(
                      value: _betAmount.toDouble(),
                      min: 10,
                      max: userCoins.toDouble().clamp(10, 10000),
                      divisions: ((userCoins.clamp(10, 10000) - 10) / 10).toInt(),
                      activeColor: GamingTheme.primaryAccent,
                      onChanged: (value) {
                        setState(() {
                          _betAmount = value.toInt();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('10', style: TextStyle(color: Colors.grey)),
                        Text('Max: ${userCoins.clamp(10, 10000)}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [100, 500, 1000, 5000]
                          .where((amount) => amount <= userCoins)
                          .map((amount) => _buildQuickAmountButton(amount))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedFriendId != null && _betAmount <= userCoins && !_isCreating
                    ? _createChallenge
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GamingTheme.primaryAccent,
                  padding: const EdgeInsets.all(16),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Send Challenge', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 16),

            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GamingTheme.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GamingTheme.primaryAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: GamingTheme.primaryAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Best of 3 games. Winner takes ${_betAmount * 2} coins!',
                      style: TextStyle(color: GamingTheme.primaryAccent, fontSize: 12),
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

  Widget _buildFriendCard(Map<String, String> friend) {
    final isSelected = _selectedFriendId == friend['id'];

    return Card(
      color: isSelected ? GamingTheme.primaryAccent.withOpacity(0.2) : GamingTheme.surfaceDark,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFriendId = friend['id'];
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(friend['avatar']!, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  friend['name']!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: GamingTheme.primaryAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(int amount) {
    final isSelected = _betAmount == amount;

    return InkWell(
      onTap: () {
        setState(() {
          _betAmount = amount;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? GamingTheme.primaryAccent : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$amount',
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
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
      await provider.createChallenge(
        opponentId: _selectedFriendId!,
        betAmount: _betAmount,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Challenge sent! Wagered $_betAmount coins'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
