import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/config_url.dart';
import '../utils/url_helper.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';
import '../models/friend_data.dart';
import '../models/friend_request_data.dart';

/// Màn hình tìm kiếm và kết bạn
class SearchFriendsScreen extends StatefulWidget {
  const SearchFriendsScreen({super.key});

  @override
  State<SearchFriendsScreen> createState() => _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends State<SearchFriendsScreen> {
  final _searchController = TextEditingController();
  final _apiService = ApiService();

  List<UserProfile> _searchResults = [];
  List<FriendRequestData> _sentRequests = [];
  List<FriendRequestData> _receivedRequests = [];
  List<FriendData> _friends = [];
  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isInitializing = true);
    try {
      // Load sent requests, received requests and friends list
      final allRequests = await _apiService.getFriendRequests();
      final authProvider = context.read<AuthProvider>();
      final myUserId = authProvider.userId;

      // Separate sent and received requests
      _sentRequests = allRequests
          .where((req) => req.senderId == myUserId && req.status == 'pending')
          .toList();

      _receivedRequests = allRequests
          .where((req) => req.receiverId == myUserId && req.status == 'pending')
          .toList();

      _friends = await _apiService.getFriends();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu bạn bè: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _isInitializing = false);
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _apiService.searchUsers(query.trim());
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tìm kiếm thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendFriendRequest(
    String receiverId,
    String receiverName,
  ) async {
    try {
      await _apiService.sendFriendRequest(
        receiverId: receiverId,
        message: 'Xin chào! Kết bạn nhé!',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi lời mời kết bạn đến $receiverName'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload to update sent requests
        await _loadInitialData();
        // Clear search and reload
        _searchController.clear();
        setState(() => _searchResults = []);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Gửi lời mời thất bại';

        // Handle specific error cases
        if (e.toString().contains('already exists') ||
            e.toString().contains('400')) {
          errorMessage =
              'Bạn đã gửi lời mời kết bạn cho người này rồi hoặc đã là bạn bè';
        } else if (e.toString().contains('not found') ||
            e.toString().contains('404')) {
          errorMessage = 'Không tìm thấy người dùng';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );

        // Reload to get latest state
        await _loadInitialData();
      }
    }
  }

  bool _isAlreadyFriend(String userId) {
    return _friends.any((friend) => friend.id == userId);
  }

  bool _hasRequestSent(String userId) {
    // Check if we sent a request to them
    final sentToUser = _sentRequests.any(
      (req) => req.receiverId == userId && req.status == 'pending',
    );

    // Check if they sent a request to us
    final receivedFromUser = _receivedRequests.any(
      (req) => req.senderId == userId && req.status == 'pending',
    );

    return sentToUser || receivedFromUser;
  }

  String _getRequestStatusLabel(String userId) {
    // Check if we sent a request to them
    final sentToUser = _sentRequests.any(
      (req) => req.receiverId == userId && req.status == 'pending',
    );

    // Check if they sent a request to us
    final receivedFromUser = _receivedRequests.any(
      (req) => req.senderId == userId && req.status == 'pending',
    );

    if (receivedFromUser) {
      return 'Đã nhận lời mời';
    } else if (sentToUser) {
      return 'Đã gửi';
    }
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tìm bạn bè')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tìm bạn bè'),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo username hoặc email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
              ),
              onChanged: (value) {
                _searchUsers(value);
              },
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      final isMyself = user.id == authProvider.userProfile?.id;
                      final isFriend = _isAlreadyFriend(user.id.toString());
                      final hasRequestSent = _hasRequestSent(
                        user.id.toString(),
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            child: user.avatarUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      UrlHelper.getFullImageUrl(user.avatarUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Text(
                                        user.username[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    user.username[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          title: Text(
                            user.username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email),
                              if (user.totalScore > 0)
                                Text(
                                  '🏆 ${user.totalScore} điểm',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber[700],
                                  ),
                                ),
                            ],
                          ),
                          trailing: isMyself
                              ? const Chip(
                                  label: Text('Bạn'),
                                  backgroundColor: Colors.grey,
                                )
                              : isFriend
                              ? const Chip(
                                  label: Text('Bạn bè'),
                                  backgroundColor: Colors.green,
                                )
                              : hasRequestSent
                              ? Chip(
                                  label: Text(
                                    _getRequestStatusLabel(user.id.toString()),
                                  ),
                                  backgroundColor: Colors.orange,
                                )
                              : ElevatedButton.icon(
                                  onPressed: () => _sendFriendRequest(
                                    user.id.toString(),
                                    user.username,
                                  ),
                                  icon: const Icon(Icons.person_add, size: 18),
                                  label: const Text('Kết bạn'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Nhập tên hoặc email để tìm bạn bè'
                : 'Không tìm thấy người dùng nào',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
