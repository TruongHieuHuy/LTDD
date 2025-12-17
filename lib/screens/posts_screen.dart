import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// Màn hình hiển thị danh sách posts (giống Facebook feed)
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _myPostsScrollController = ScrollController();

  List<PostData> _allPosts = [];
  List<PostData> _myPosts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  int _myPostsPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _myPostsScrollController.addListener(_onMyPostsScroll);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _myPostsScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  void _onMyPostsScroll() {
    if (_myPostsScrollController.position.pixels ==
        _myPostsScrollController.position.maxScrollExtent) {
      _loadMoreMyPosts();
    }
  }

  Future<void> _loadPosts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _currentPage = 0;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      final posts = await apiService.getPosts(limit: _pageSize, offset: 0);

      setState(() {
        _allPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải bài đăng: $e')));
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      _currentPage++;
      final posts = await apiService.getPosts(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      setState(() {
        _allPosts.addAll(posts);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _loadMyPosts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _myPostsPage = 0;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      final posts = await apiService.getPosts(
        limit: _pageSize,
        offset: 0,
        userId: authProvider.userId,
      );

      setState(() {
        _myPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải bài đăng: $e')));
      }
    }
  }

  Future<void> _loadMoreMyPosts() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      _myPostsPage++;
      final posts = await apiService.getPosts(
        limit: _pageSize,
        offset: _myPostsPage * _pageSize,
        userId: authProvider.userId,
      );

      setState(() {
        _myPosts.addAll(posts);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _handleLike(PostData post) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      // Optimistic update
      setState(() {
        final index = _allPosts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          final updatedPost = PostData.fromJson({
            'id': post.id,
            'userId': post.userId,
            'content': post.content,
            'imageUrl': post.imageUrl,
            'visibility': post.visibility,
            'likeCount': post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
            'commentCount': post.commentCount,
            'shareCount': post.shareCount,
            'createdAt': post.createdAt.toIso8601String(),
            'updatedAt': post.updatedAt.toIso8601String(),
            'user': {
              'id': post.user.id,
              'username': post.user.username,
              'email': post.user.email,
              'avatarUrl': post.user.avatarUrl,
              'totalScore': post.user.totalScore,
              'totalGamesPlayed': post.user.totalGamesPlayed,
            },
            'isLiked': !post.isLiked,
            'isSaved': post.isSaved,
          });
          _allPosts[index] = updatedPost;
        }

        final myIndex = _myPosts.indexWhere((p) => p.id == post.id);
        if (myIndex != -1) {
          final updatedPost = PostData.fromJson({
            'id': post.id,
            'userId': post.userId,
            'content': post.content,
            'imageUrl': post.imageUrl,
            'visibility': post.visibility,
            'likeCount': post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
            'commentCount': post.commentCount,
            'shareCount': post.shareCount,
            'createdAt': post.createdAt.toIso8601String(),
            'updatedAt': post.updatedAt.toIso8601String(),
            'user': {
              'id': post.user.id,
              'username': post.user.username,
              'email': post.user.email,
              'avatarUrl': post.user.avatarUrl,
              'totalScore': post.user.totalScore,
              'totalGamesPlayed': post.user.totalGamesPlayed,
            },
            'isLiked': !post.isLiked,
            'isSaved': post.isSaved,
          });
          _myPosts[myIndex] = updatedPost;
        }
      });

      await apiService.toggleLike(post.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
      // Revert on error
      _loadPosts();
    }
  }

  Future<void> _handleSave(PostData post) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      final result = await apiService.toggleSavePost(post.id);

      setState(() {
        final index = _allPosts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          final updatedPost = PostData.fromJson({
            'id': post.id,
            'userId': post.userId,
            'content': post.content,
            'imageUrl': post.imageUrl,
            'visibility': post.visibility,
            'likeCount': post.likeCount,
            'commentCount': post.commentCount,
            'shareCount': post.shareCount,
            'createdAt': post.createdAt.toIso8601String(),
            'updatedAt': post.updatedAt.toIso8601String(),
            'user': {
              'id': post.user.id,
              'username': post.user.username,
              'email': post.user.email,
              'avatarUrl': post.user.avatarUrl,
              'totalScore': post.user.totalScore,
              'totalGamesPlayed': post.user.totalGamesPlayed,
            },
            'isLiked': post.isLiked,
            'isSaved': result['isSaved'] ?? !post.isSaved,
          });
          _allPosts[index] = updatedPost;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['isSaved'] ? 'Đã lưu bài viết' : 'Đã bỏ lưu'),
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

  Future<void> _handleDelete(PostData post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa bài đăng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      await apiService.deletePost(post.id);

      setState(() {
        _allPosts.removeWhere((p) => p.id == post.id);
        _myPosts.removeWhere((p) => p.id == post.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa bài đăng')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _handleFollow(PostData post) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      final result = await apiService.toggleFollow(post.userId);

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

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreatePostDialog(
        onPostCreated: () {
          _loadPosts();
          if (_tabController.index == 1) {
            _loadMyPosts();
          }
        },
      ),
    );
  }

  void _showEditPostDialog(PostData post) {
    showDialog(
      context: context,
      builder: (context) => _EditPostDialog(
        post: post,
        onPostUpdated: () {
          _loadPosts();
          if (_tabController.index == 1) {
            _loadMyPosts();
          }
        },
      ),
    );
  }

  void _showCommentSheet(PostData post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CommentBottomSheet(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài đăng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.pushNamed(context, '/saved-posts');
            },
            tooltip: 'Bài đăng đã lưu',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 1 && _myPosts.isEmpty) {
              _loadMyPosts();
            }
          },
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Bài đăng của bạn'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Posts Tab
          RefreshIndicator(
            onRefresh: _loadPosts,
            child: _isLoading && _allPosts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _allPosts.isEmpty
                ? const Center(child: Text('Chưa có bài đăng nào'))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _allPosts.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _allPosts.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _PostCard(
                        post: _allPosts[index],
                        currentUserId: authProvider.userId ?? 0,
                        onLike: () => _handleLike(_allPosts[index]),
                        onComment: () => _showCommentSheet(_allPosts[index]),
                        onSave: () => _handleSave(_allPosts[index]),
                        onDelete: () => _handleDelete(_allPosts[index]),
                        onEdit: () => _showEditPostDialog(_allPosts[index]),
                        onFollow: () => _handleFollow(_allPosts[index]),
                        onAvatarTap: () {
                          Navigator.pushNamed(
                            context,
                            '/user-profile',
                            arguments: _allPosts[index].userId,
                          );
                        },
                      );
                    },
                  ),
          ),

          // My Posts Tab
          RefreshIndicator(
            onRefresh: _loadMyPosts,
            child: _isLoading && _myPosts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _myPosts.isEmpty
                ? const Center(child: Text('Bạn chưa có bài đăng nào'))
                : ListView.builder(
                    controller: _myPostsScrollController,
                    itemCount: _myPosts.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _myPosts.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _PostCard(
                        post: _myPosts[index],
                        currentUserId: authProvider.userId ?? 0,
                        onLike: () => _handleLike(_myPosts[index]),
                        onComment: () => _showCommentSheet(_myPosts[index]),
                        onSave: () => _handleSave(_myPosts[index]),
                        onDelete: () => _handleDelete(_myPosts[index]),
                        onEdit: () => _showEditPostDialog(_myPosts[index]),
                        onFollow: () => _handleFollow(_myPosts[index]),
                        onAvatarTap: () {
                          Navigator.pushNamed(
                            context,
                            '/user-profile',
                            arguments: _myPosts[index].userId,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ============ POST CARD WIDGET ============

class _PostCard extends StatelessWidget {
  final PostData post;
  final int currentUserId;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onFollow;
  final VoidCallback onAvatarTap;

  const _PostCard({
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onDelete,
    required this.onEdit,
    required this.onFollow,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOwnPost = post.userId == currentUserId;
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar, username, time
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onAvatarTap,
                  child: CircleAvatar(
                    backgroundImage: post.user.avatarUrl != null
                        ? NetworkImage(post.user.avatarUrl!)
                        : null,
                    child: post.user.avatarUrl == null
                        ? Text(post.user.username[0].toUpperCase())
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'save':
                        onSave();
                        break;
                      case 'follow':
                        onFollow();
                        break;
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    if (isOwnPost) {
                      return [
                        PopupMenuItem(
                          value: 'save',
                          child: Row(
                            children: [
                              Icon(
                                post.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(post.isSaved ? 'Đã lưu' : 'Lưu bài viết'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Sửa'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ];
                    } else {
                      return [
                        PopupMenuItem(
                          value: 'save',
                          child: Row(
                            children: [
                              Icon(
                                post.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(post.isSaved ? 'Đã lưu' : 'Lưu bài viết'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'follow',
                          child: Row(
                            children: [
                              Icon(Icons.person_add, size: 20),
                              SizedBox(width: 8),
                              Text('Theo dõi'),
                            ],
                          ),
                        ),
                      ];
                    }
                  },
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(post.content),
          ),

          // Image if exists
          if (post.imageUrl != null)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),

          // Like, Comment, Share counts and buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : null,
                  ),
                  onPressed: onLike,
                ),
                Text('${post.likeCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: onComment,
                ),
                Text('${post.commentCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // TODO: Implement share
                  },
                ),
                Text('${post.shareCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ CREATE POST DIALOG ============

class _CreatePostDialog extends StatefulWidget {
  final VoidCallback onPostCreated;

  const _CreatePostDialog({required this.onPostCreated});

  @override
  State<_CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<_CreatePostDialog> {
  final _contentController = TextEditingController();
  bool _isLoading = false;
  String _visibility = 'public';

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      await apiService.createPost(
        content: _contentController.text.trim(),
        visibility: _visibility,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã tạo bài đăng')));
        widget.onPostCreated();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo bài đăng mới'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Bạn đang nghĩ gì?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _visibility,
              decoration: const InputDecoration(
                labelText: 'Quyền riêng tư',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'public', child: Text('Công khai')),
                DropdownMenuItem(value: 'friends', child: Text('Bạn bè')),
                DropdownMenuItem(value: 'private', child: Text('Riêng tư')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _visibility = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createPost,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Đăng'),
        ),
      ],
    );
  }
}

// ============ EDIT POST DIALOG ============

class _EditPostDialog extends StatefulWidget {
  final PostData post;
  final VoidCallback onPostUpdated;

  const _EditPostDialog({required this.post, required this.onPostUpdated});

  @override
  State<_EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<_EditPostDialog> {
  late TextEditingController _contentController;
  bool _isLoading = false;
  late String _visibility;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    _visibility = widget.post.visibility;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      await apiService.updatePost(
        postId: widget.post.id,
        content: _contentController.text.trim(),
        visibility: _visibility,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã cập nhật bài đăng')));
        widget.onPostUpdated();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa bài đăng'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Nội dung bài đăng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _visibility,
              decoration: const InputDecoration(
                labelText: 'Quyền riêng tư',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'public', child: Text('Công khai')),
                DropdownMenuItem(value: 'friends', child: Text('Bạn bè')),
                DropdownMenuItem(value: 'private', child: Text('Riêng tư')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _visibility = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updatePost,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Cập nhật'),
        ),
      ],
    );
  }
}

// ============ COMMENT BOTTOM SHEET ============

class _CommentBottomSheet extends StatefulWidget {
  final PostData post;

  const _CommentBottomSheet({required this.post});

  @override
  State<_CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet> {
  final _commentController = TextEditingController();
  List<CommentData> _comments = [];
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      final post = await apiService.getPost(widget.post.id);
      setState(() {
        _comments = post.comments ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      final comment = await apiService.addComment(
        postId: widget.post.id,
        content: _commentController.text.trim(),
      );

      setState(() {
        _comments.add(comment);
        _commentController.clear();
        _isSending = false;
      });
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bình luận',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Comments list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                  ? const Center(child: Text('Chưa có bình luận nào'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: comment.user.avatarUrl != null
                                ? NetworkImage(comment.user.avatarUrl!)
                                : null,
                            child: comment.user.avatarUrl == null
                                ? Text(comment.user.username[0].toUpperCase())
                                : null,
                          ),
                          title: Text(
                            comment.user.username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(comment.content),
                        );
                      },
                    ),
            ),

            // Comment input
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Viết bình luận...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: _isSending ? null : _sendComment,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
