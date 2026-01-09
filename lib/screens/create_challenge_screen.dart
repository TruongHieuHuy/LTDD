import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
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
  bool _isLoading = true;
  List<Map<String, dynamic>> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final friendsData = await apiService.getFriends();
      
      setState(() {
        _friends = friendsData.map((friend) => {
          'id': friend.id,
          'username': friend.username,
          'email': friend.email,
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading friends: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual coins from user when coins field is added to UserProfile
    final userCoins = 1000; // Hardcoded for now

    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      appBar: AppBar(
        title: const Text('Tạo Thách Đấu'),
        backgroundColor: GamingTheme.primaryDark,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: GamingTheme.primaryAccent),
            )
          : SingleChildScrollView(
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
                              const Text('Số xu của bạn', style: TextStyle(color: Colors.grey)),
                              Text(
                                '$userCoins xu',
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
                    'Chọn đối thủ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  
                  // Real friends list from backend
                  if (_friends.isEmpty)
                    Card(
                      color: GamingTheme.surfaceDark,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.people_outline, size: 48, color: Colors.grey.shade700),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có bạn bè nào',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kết bạn trước để thách đấu!',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ..._friends.map((friend) {
                      return _buildFriendCard(friend);
                    }).toList(),

                  const SizedBox(height: 24),

                  // Bet Amount
                  const Text(
                    'Số xu cược',
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
                              const Text('Cược:', style: TextStyle(color: Colors.white)),
                              Row(
                                children: [
                                  const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_betAmount xu',
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
                              Text('Tối đa: ${userCoins.clamp(10, 10000)}', style: const TextStyle(color: Colors.grey)),
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
                          : const Text('Gửi thách đấu', style: TextStyle(fontSize: 16)),
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
                            'Đấu 3 ván - người thắng nhận ${_betAmount * 2} xu!',
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

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    final friendId = friend['id']?.toString() ?? '';
    final username = friend['username'] ?? friendId;
    final isSelected = _selectedFriendId == friendId;

    return Card(
      color: isSelected ? GamingTheme.primaryAccent.withOpacity(0.2) : GamingTheme.surfaceDark,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFriendId = friendId;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(username.substring(0, 1).toUpperCase()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    if (friend['email'] != null)
                      Text(
                        friend['email'],
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                  ],
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
            content: Text('Đã gửi thách đấu! Cược $_betAmount xu'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
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
