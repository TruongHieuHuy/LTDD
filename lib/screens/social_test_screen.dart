import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/friend_provider.dart';
import '../providers/group_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/demo_data_initializer.dart';

/// Screen test tính năng Friend & Group system
class SocialTestScreen extends StatefulWidget {
  const SocialTestScreen({Key? key}) : super(key: key);

  @override
  State<SocialTestScreen> createState() => _SocialTestScreenState();
}

class _SocialTestScreenState extends State<SocialTestScreen> {
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    final authProvider = context.read<AuthProvider>();
    final friendProvider = context.read<FriendProvider>();
    final groupProvider = context.read<GroupProvider>();

    if (authProvider.currentAuth != null && authProvider.userEmail != null) {
      final currentMssv = authProvider.userEmail!; // Use email as MSSV for now
      await friendProvider.initialize(currentMssv);
      await groupProvider.initialize(currentMssv);
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _initializeDemoData() async {
    setState(() => _isLoading = true);
    try {
      final friendProvider = context.read<FriendProvider>();
      final groupProvider = context.read<GroupProvider>();
      final authProvider = context.read<AuthProvider>();

      // Note: PeerChatProvider needs to be passed too, but for now we skip it
      await DemoDataInitializer.initializeDemoData(
        friendProvider: friendProvider,
        groupProvider: groupProvider,
        peerChatProvider: context
            .read(), // Will get PeerChatProvider from context
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Demo data initialized! 5 accounts, 10 friendships, 3 groups',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Re-initialize to reload data
        await _initializeProviders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final friendProvider = context.watch<FriendProvider>();
    final groupProvider = context.watch<GroupProvider>();

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('🌐 Social Features')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final friends = friendProvider.getFriends();
    final groups = groupProvider.getUserGroups();
    final pendingRequests = friendProvider.getPendingRequests();

    return Scaffold(
      appBar: AppBar(
        title: Text('🌐 Social Features Test'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _initializeProviders,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Current User Info
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        authProvider.userEmail?.substring(0, 1).toUpperCase() ??
                            '?',
                      ),
                    ),
                    title: Text(authProvider.userEmail ?? 'Unknown'),
                    subtitle: Text('Email: ${authProvider.userEmail ?? 'N/A'}'),
                  ),
                ),

                SizedBox(height: 16),

                // Initialize Demo Data Button
                ElevatedButton.icon(
                  icon: Icon(Icons.data_object),
                  label: Text('Initialize Demo Data (5 Accounts)'),
                  onPressed: _initializeDemoData,
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
                ),

                SizedBox(height: 24),

                // Friends Section
                Text(
                  '👥 Friends (${friends.length})',
                  style: theme.textTheme.titleLarge,
                ),
                SizedBox(height: 8),
                if (friends.isEmpty)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No friends yet. Initialize demo data or send friend requests.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...friends.map((friendship) {
                    final friendId = friendship.getOtherUserId(
                      authProvider.userEmail!,
                    );
                    final friendProfile = DemoDataInitializer.getUserProfile(
                      friendId,
                    );
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(friendProfile?.name[0] ?? '?'),
                        ),
                        title: Text(friendProfile?.name ?? friendId),
                        subtitle: Text('MSSV: $friendId'),
                        trailing: Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  }).toList(),

                SizedBox(height: 24),

                // Pending Requests Section
                Text(
                  '📬 Friend Requests (${pendingRequests.length})',
                  style: theme.textTheme.titleLarge,
                ),
                SizedBox(height: 8),
                if (pendingRequests.isEmpty)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No pending friend requests',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...pendingRequests.map((request) {
                    final senderProfile = DemoDataInitializer.getUserProfile(
                      request.senderId,
                    );
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(senderProfile?.name[0] ?? '?'),
                        ),
                        title: Text(senderProfile?.name ?? request.senderId),
                        subtitle: Text(
                          request.message ?? 'Wants to be friends',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () async {
                                await friendProvider.acceptFriendRequest(
                                  request.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('✅ Friend request accepted'),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                await friendProvider.rejectFriendRequest(
                                  request.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('❌ Friend request rejected'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                SizedBox(height: 24),

                // Groups Section
                Text(
                  '📦 Groups (${groups.length})',
                  style: theme.textTheme.titleLarge,
                ),
                SizedBox(height: 8),
                if (groups.isEmpty)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No groups yet. Initialize demo data or create a group.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...groups.map((group) {
                    final members = groupProvider.getGroupMembers(group.id);
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(group.name[0])),
                        title: Text(group.name),
                        subtitle: Text(
                          '${members.length} members • ${group.description ?? "No description"}',
                        ),
                        trailing: Icon(
                          group.isPublic ? Icons.public : Icons.lock,
                        ),
                      ),
                    );
                  }).toList(),

                SizedBox(height: 24),

                // Debug Info
                ExpansionTile(
                  title: Text('🔍 Debug Info'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Friend Provider Initialized: ${friendProvider.isInitialized}',
                          ),
                          Text(
                            'Group Provider Initialized: ${groupProvider.isInitialized}',
                          ),
                          Text(
                            'Current User ID: ${friendProvider.currentUserId ?? "N/A"}',
                          ),
                          Text('Friend Count: ${friendProvider.friendCount}'),
                          Text(
                            'Pending Requests: ${friendProvider.pendingRequestCount}',
                          ),
                          Text('Group Count: ${groupProvider.groupCount}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
