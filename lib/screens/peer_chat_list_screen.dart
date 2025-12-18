import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/peer_chat_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/user_data_service.dart';
import '../services/api_service.dart';
import 'peer_chat_screen.dart';

/// Screen showing list of P2P chat conversations
class PeerChatListScreen extends StatefulWidget {
  const PeerChatListScreen({super.key});

  @override
  State<PeerChatListScreen> createState() => _PeerChatListScreenState();
}

class _PeerChatListScreenState extends State<PeerChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Delay initialization để tránh setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    final authProvider = context.read<AuthProvider>();
    final userDataService = UserDataService();

    // Find user by email from auth
    final userEmail = authProvider.userEmail;
    final user = userDataService.members.firstWhere(
      (m) => m['email'] == userEmail,
      orElse: () => userDataService.currentUser,
    );

    if (mounted) {
      await context.read<PeerChatProvider>().initialize(user['mssv']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userDataService = UserDataService();

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
        title: Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chat với bạn bè',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Nhắn tin với thành viên',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/friend-requests');
            },
            tooltip: 'Lời mời kết bạn',
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.of(context).pushNamed('/search-friends');
            },
            tooltip: 'Tìm bạn bè',
          ),
        ],
      ),
      body: Consumer<PeerChatProvider>(
        builder: (context, chatProvider, child) {
          if (!chatProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = chatProvider.getConversations();
          final allMembers = userDataService.members;

          if (conversations.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherUserId = conversation.getOtherUserId(
                chatProvider.currentUserId!,
              );
              final member = chatProvider.getMemberInfo(
                otherUserId,
                allMembers,
              );

              return _buildConversationTile(
                context,
                conversation,
                member,
                chatProvider,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewChatDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Chat mới'),
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    conversation,
    Map<String, dynamic>? member,
    PeerChatProvider chatProvider,
  ) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(conversation.chatRoomId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xóa đoạn chat?'),
            content: Text(
              'Bạn có chắc muốn xóa đoạn chat với ${member?['name'] ?? "người này"}?',
            ),
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
      },
      onDismissed: (direction) {
        chatProvider.deleteConversation(conversation.chatRoomId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã xóa đoạn chat với ${member?['name'] ?? "người này"}',
            ),
          ),
        );
      },
      child: ListTile(
        leading: Hero(
          tag: 'avatar_${conversation.chatRoomId}',
          child: CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            child: Text(
              member?['name'].substring(0, 1).toUpperCase() ?? '?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member?['name'] ?? 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${conversation.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          conversation.lastMessage ?? 'Bắt đầu trò chuyện',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: conversation.unreadCount > 0
                ? theme.textTheme.bodyLarge?.color
                : theme.textTheme.bodySmall?.color,
            fontWeight: conversation.unreadCount > 0
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(conversation.lastMessageTime),
              style: TextStyle(
                fontSize: 11,
                color: conversation.unreadCount > 0
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color,
                fontWeight: conversation.unreadCount > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ),
        onTap: () {
          if (member != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PeerChatScreen(member: member),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                    theme.colorScheme.secondary.withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có đoạn chat nào',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bắt đầu trò chuyện với thành viên trong nhóm của bạn',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showNewChatDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Bắt đầu chat mới'),
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
    );
  }

  Future<void> _showNewChatDialog(BuildContext context) async {
    final chatProvider = context.read<PeerChatProvider>();
    final currentMssv = chatProvider.currentUserId;

    if (currentMssv == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa khởi tạo chat')));
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Load friends from API
    final response = await ApiService().getFriends();
    
    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    if (!response.success || response.data == null || response.data!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Bạn chưa có bạn bè nào. Hãy kết bạn trước!'),
          action: SnackBarAction(
            label: 'Tìm bạn',
            onPressed: () => Navigator.pushNamed(context, '/search-friends'),
          ),
        ),
      );
      return;
    }

    final friends = response.data!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Chọn bạn bè để chat',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    '${friends.length} bạn bè',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                          child: friend.avatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    friend.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Text(
                                      friend.username[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  friend.username[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        title: Text(
                          friend.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(friend.email),
                        trailing: const Icon(Icons.chat_bubble_outline),
                        onTap: () {
                          Navigator.pop(context);
                          // Convert FriendData to member format for PeerChatScreen
                          final memberData = {
                            'mssv': friend.id.toString(),
                            'name': friend.username,
                            'email': friend.email,
                            'avatar': friend.avatarUrl,
                          };
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PeerChatScreen(member: memberData),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}p';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
