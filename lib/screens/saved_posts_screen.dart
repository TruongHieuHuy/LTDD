import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/post_data.dart';
import '../models/comment_data.dart';

/// Màn hình hiển thị danh sách bài đăng đã lưu
class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  List<PostData> _savedPosts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();

      final posts = await apiService.getSavedPosts();

      setState(() {
        _savedPosts = posts;
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

  Future<void> _handleUnsave(PostData post) async {
    try {
      final apiService = ApiService();

      await apiService.toggleSavePost(post.id);

      setState(() {
        _savedPosts.removeWhere((p) => p.id == post.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã bỏ lưu bài viết')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _handleLike(PostData post) async {
    try {
      final apiService = ApiService();

      // Optimistic update
      setState(() {
        final index = _savedPosts.indexWhere((p) => p.id == post.id);
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
          _savedPosts[index] = updatedPost;
        }
      });

      await apiService.toggleLike(post.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
      _loadSavedPosts();
    }
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
      appBar: AppBar(title: const Text('Bài đăng đã lưu')),
      body: RefreshIndicator(
        onRefresh: _loadSavedPosts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _savedPosts.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có bài đăng đã lưu',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _savedPosts.length,
                itemBuilder: (context, index) {
                  return _SavedPostCard(
                    post: _savedPosts[index],
                    currentUserId: authProvider.userId ?? '',
                    onLike: () => _handleLike(_savedPosts[index]),
                    onComment: () => _showCommentSheet(_savedPosts[index]),
                    onUnsave: () => _handleUnsave(_savedPosts[index]),
                    onAvatarTap: () {
                      Navigator.pushNamed(
                        context,
                        '/user-profile',
                        arguments: _savedPosts[index].userId,
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

// ============ SAVED POST CARD WIDGET ============

class _SavedPostCard extends StatelessWidget {
  final PostData post;
  final String currentUserId;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onUnsave;
  final VoidCallback onAvatarTap;

  const _SavedPostCard({
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onUnsave,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar, username, time
          ListTile(
            leading: GestureDetector(
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
            title: Text(
              post.user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(formattedDate),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark, color: Colors.blue),
              onPressed: onUnsave,
              tooltip: 'Bỏ lưu',
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
