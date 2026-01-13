import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../config/config_url.dart';
import '../utils/url_helper.dart';

import '../models/user_profile.dart';
import '../models/post_data.dart';
// import '../models/friend_data.dart';
// import '../models/friend_request_data.dart';

/// Màn hình hiển thị thông tin profile người dùng
class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? _userProfile;
  List<PostData> _userPosts = [];
  bool _isLoading = true;
  bool _isFriend = false;
  bool _isRequestSent = false;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserPosts();
    _checkFriendStatus();
  }

  Future<void> _loadUserProfile() async {
    // Giả lập load user profile - bạn có thể thêm API endpoint để lấy user profile
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();

      // Load posts của user để lấy thông tin user từ post
      final posts = await apiService.getPosts(userId: widget.userId, limit: 1);
      if (posts.isNotEmpty) {
        setState(() {
          _userProfile = posts[0].user;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải thông tin: $e')));
      }
    }
  }

  Future<void> _loadUserPosts() async {
    try {
      final apiService = ApiService();

      final posts = await apiService.getPosts(userId: widget.userId, limit: 50);
      setState(() => _userPosts = posts);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải bài đăng: $e')));
      }
    }
  }

  Future<void> _checkFriendStatus() async {
    try {
      final apiService = ApiService();

      // Kiểm tra xem đã là bạn bè chưa

      final friendsList = await apiService.getFriends();
      final isFriend = friendsList.any((f) => f.id == widget.userId.toString());

      // Kiểm tra xem đã gửi lời mời kết bạn chưa

      final requestsList = await apiService.getFriendRequests();
      final isRequestSent = requestsList.any(
        (r) => r.receiverId == widget.userId.toString(),
      );

      setState(() {
        _isFriend = isFriend;
        _isRequestSent = isRequestSent;
      });
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _handleAddFriend() async {
    try {
      final apiService = ApiService();

      await apiService.sendFriendRequest(receiverId: widget.userId.toString());

      setState(() => _isRequestSent = true);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã gửi lời mời kết bạn')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _handleFollow() async {
    try {
      final apiService = ApiService();

      final result = await apiService.toggleFollow(widget.userId);

      setState(() => _isFollowing = result['isFollowing'] ?? false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['isFollowing'] ? 'Đã theo dõi' : 'Đã hủy theo dõi',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  void _handleMessage() {
    // Navigate to chat screen with this user
    Navigator.pushNamed(
      context,
      '/peer-chat',
      arguments: {
        'friendId': widget.userId,
        'friendUsername': _userProfile?.username ?? 'User',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwnProfile = widget.userId == authProvider.userId;
    final isAdmin = authProvider.isAdmin;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Không tìm thấy người dùng')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_userProfile!.username),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Chuyển về trang Admin',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/admin');
              },
            ),
          if (!isOwnProfile)
            IconButton(
              icon: Icon(
                _isFollowing
                    ? Icons.notifications_active
                    : Icons.notifications_none,
              ),
              onPressed: _handleFollow,
              tooltip: _isFollowing ? 'Hủy theo dõi' : 'Theo dõi',
            ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _userProfile!.avatarUrl != null
                      ? NetworkImage(
                          UrlHelper.getFullImageUrl(_userProfile!.avatarUrl),
                        )
                      : null,
                  child: _userProfile!.avatarUrl == null
                      ? Text(
                          _userProfile!.username[0].toUpperCase(),
                          style: const TextStyle(fontSize: 40),
                        )
                      : null,
                ),
                const SizedBox(height: 16),

                // Username
                Text(
                  _userProfile!.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Email
                Text(
                  _userProfile!.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      title: 'Bài đăng',
                      value: _userPosts.length.toString(),
                    ),
                    _StatCard(
                      title: 'Điểm số',
                      value: _userProfile!.totalScore.toString(),
                    ),
                    _StatCard(
                      title: 'Trò chơi',
                      value: _userProfile!.totalGamesPlayed.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Action Buttons
                if (!isOwnProfile)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isFriend)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleMessage,
                            icon: const Icon(Icons.message),
                            label: const Text('Nhắn tin'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        )
                      else if (_isRequestSent)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.check),
                            label: const Text('Đã gửi lời mời'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleAddFriend,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Kết bạn'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (_isFriend) const SizedBox(width: 12),
                      if (_isFriend)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleFollow,
                            icon: Icon(
                              _isFollowing
                                  ? Icons.notifications_active
                                  : Icons.notifications_none,
                            ),
                            label: Text(
                              _isFollowing ? 'Đã theo dõi' : 'Theo dõi',
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),

                if (isOwnProfile)
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to edit profile
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Chỉnh sửa profile'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(),

          // Posts Grid Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.grid_on),
                const SizedBox(width: 8),
                Text(
                  'Bài đăng (${_userPosts.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Posts Grid
          Expanded(
            child: _userPosts.isEmpty
                ? const Center(child: Text('Chưa có bài đăng nào'))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _userPosts.length,
                    itemBuilder: (context, index) {
                      final post = _userPosts[index];
                      return GestureDetector(
                        onTap: () {
                          // TODO: Navigate to post detail
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: post.imageUrl != null
                              ? Image.network(
                                  post.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _PostThumbnail(content: post.content),
                                )
                              : _PostThumbnail(content: post.content),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============ STAT CARD WIDGET ============

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}

// ============ POST THUMBNAIL WIDGET ============

class _PostThumbnail extends StatelessWidget {
  final String content;

  const _PostThumbnail({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Center(
        child: Text(
          content.length > 50 ? '${content.substring(0, 50)}...' : content,
          style: const TextStyle(fontSize: 12),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
