import 'package:flutter/foundation.dart';
import '../providers/friend_provider.dart';
import '../providers/group_provider.dart';
import '../providers/peer_chat_provider.dart';

/// Utility class for initializing demo data for testing social features
class DemoDataInitializer {
  /// Demo accounts with MSSV mapping
  static const Map<String, UserProfile> demoAccounts = {
    'user1@test.com': UserProfile(
      email: 'user1@test.com',
      mssv: '2280601273',
      name: 'Trương Hiếu Huy',
      role: 'Team Leader',
      phone: '0948677191',
      classRoom: '22DTHA2',
    ),
    'user2@test.com': UserProfile(
      email: 'user2@test.com',
      mssv: '2280601101',
      name: 'ShadowBlade',
      role: 'Assassin Master',
      phone: '0901234567',
      classRoom: '22DTHA2',
    ),
    'user3@test.com': UserProfile(
      email: 'user3@test.com',
      mssv: '2280601102',
      name: 'DragonKnight',
      role: 'Tank Specialist',
      phone: '0902345678',
      classRoom: '22DTHA2',
    ),
    'user4@test.com': UserProfile(
      email: 'user4@test.com',
      mssv: '2280601103',
      name: 'MysticMage',
      role: 'Mage Pro',
      phone: '0903456789',
      classRoom: '22DTHA2',
    ),
    'user5@test.com': UserProfile(
      email: 'user5@test.com',
      mssv: '2280601104',
      name: 'PhantomArcher',
      role: 'Marksman Elite',
      phone: '0904567890',
      classRoom: '22DTHA2',
    ),
  };

  /// Initialize all demo data
  static Future<void> initializeDemoData({
    required FriendProvider friendProvider,
    required GroupProvider groupProvider,
    required PeerChatProvider peerChatProvider,
  }) async {
    debugPrint('🚀 Starting demo data initialization...');

    try {
      // Step 1: Create friendships between all 5 accounts
      await _createDemoFriendships(friendProvider);

      // Step 2: Create demo groups
      await _createDemoGroups(groupProvider);

      // Step 3: Seed demo messages
      await _seedDemoMessages(peerChatProvider);

      debugPrint('✅ Demo data initialization completed!');
    } catch (e) {
      debugPrint('❌ Error initializing demo data: $e');
    }
  }

  /// Create friendships between all 5 accounts (10 total friendships)
  static Future<void> _createDemoFriendships(
    FriendProvider friendProvider,
  ) async {
    debugPrint('👥 Creating demo friendships...');

    final mssvList = demoAccounts.values.map((p) => p.mssv).toList();

    // Create friendship for every pair
    for (int i = 0; i < mssvList.length; i++) {
      for (int j = i + 1; j < mssvList.length; j++) {
        final user1 = mssvList[i];
        final user2 = mssvList[j];

        // Initialize friend provider with user1
        await friendProvider.initialize(user1);

        // Send friend request from user1 to user2
        await friendProvider.sendFriendRequest(receiverId: user2);

        // Switch to user2 and accept
        await friendProvider.initialize(user2);
        final requests = friendProvider.getPendingRequests();
        if (requests.isNotEmpty) {
          final request = requests.first;
          await friendProvider.acceptFriendRequest(request.id);
        }

        debugPrint('✓ Created friendship: $user1 ↔ $user2');
      }
    }

    debugPrint('✅ Created 10 demo friendships');
  }

  /// Create demo groups with members
  static Future<void> _createDemoGroups(GroupProvider groupProvider) async {
    debugPrint('📦 Creating demo groups...');

    final mssvList = demoAccounts.values.map((p) => p.mssv).toList();
    final leader = mssvList[0]; // Trương Hiếu Huy

    // Initialize with leader
    await groupProvider.initialize(leader);

    // Group 1: "Gaming Squad" - All 5 members
    final group1 = await groupProvider.createGroup(
      name: 'Gaming Squad',
      description: 'Đội hình chiến thuật 5 người - Cùng nhau chinh phục rank',
      isPublic: false,
      initialMemberIds: [mssvList[1], mssvList[2], mssvList[3], mssvList[4]],
    );

    if (group1 != null) {
      debugPrint('✓ Created group: Gaming Squad (5 members)');
    }

    // Group 2: "Elite Team" - 3 selected members
    final group2 = await groupProvider.createGroup(
      name: 'Elite Team',
      description: 'Đội tinh nuy chuyên rank Huyền Thoại',
      isPublic: false,
      initialMemberIds: [mssvList[1], mssvList[2]], // Only 2 + leader = 3
    );

    if (group2 != null) {
      debugPrint('✓ Created group: Elite Team (3 members)');
    }

    // Group 3: "Achievement Hunters" - 4 members
    final group3 = await groupProvider.createGroup(
      name: 'Achievement Hunters',
      description: 'Cùng nhau săn thành tích và phá kỷ lục',
      isPublic: true,
      initialMemberIds: [mssvList[2], mssvList[3], mssvList[4]],
    );

    if (group3 != null) {
      debugPrint('✓ Created group: Achievement Hunters (4 members)');
    }

    debugPrint('✅ Created 3 demo groups');
  }

  /// Seed demo P2P messages between friends
  static Future<void> _seedDemoMessages(
    PeerChatProvider peerChatProvider,
  ) async {
    debugPrint('💬 Seeding demo messages...');

    final mssvList = demoAccounts.values.map((p) => p.mssv).toList();
    final leader = mssvList[0];

    // Initialize with leader
    await peerChatProvider.initialize(leader);

    // Sample conversations
    final conversations = [
      {
        'receiver': mssvList[1],
        'messages': [
          'Chào bro! Tối nay rank không?',
          'Có nè! Mình đang xem replay tối qua, mấy pha đánh của bro ngon lắm',
          'Haha cảm ơn! Tối nay mình thử combo mới nhé',
        ],
      },
      {
        'receiver': mssvList[2],
        'messages': [
          'Ê DragonKnight, tank giỏi vậy học ở đâu vậy?',
          'Chơi nhiều thôi bro, mà chính là phải biết timing vào đánh và thoát',
        ],
      },
      {
        'receiver': mssvList[3],
        'messages': [
          'MysticMage, tối nay thử build mage mới không?',
          'OK! Mình vừa xem guide mới, dame buff lên nhiều lắm',
        ],
      },
    ];

    for (final conv in conversations) {
      final receiverId = conv['receiver'] as String;
      final messages = conv['messages'] as List<String>;

      for (int i = 0; i < messages.length; i++) {
        if (i % 2 == 0) {
          // Leader sends
          await peerChatProvider.sendMessage(
            receiverId: receiverId,
            message: messages[i],
          );
        } else {
          // Simulate reply
          await peerChatProvider.initialize(receiverId);
          await peerChatProvider.sendMessage(
            receiverId: leader,
            message: messages[i],
          );
          await peerChatProvider.initialize(leader);
        }

        // Small delay for realistic timestamps
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint('✓ Seeded conversation with $receiverId');
    }

    debugPrint('✅ Seeded demo messages');
  }

  /// Get user profile by MSSV
  static UserProfile? getUserProfile(String mssv) {
    return demoAccounts.values.firstWhere(
      (profile) => profile.mssv == mssv,
      orElse: () => throw Exception('User not found'),
    );
  }

  /// Get user profile by email
  static UserProfile? getUserProfileByEmail(String email) {
    return demoAccounts[email];
  }

  /// Check if email is a demo account
  static bool isDemoAccount(String email) {
    return demoAccounts.containsKey(email);
  }
}

/// User profile data class
class UserProfile {
  final String email;
  final String mssv;
  final String name;
  final String role;
  final String phone;
  final String classRoom;

  const UserProfile({
    required this.email,
    required this.mssv,
    required this.name,
    required this.role,
    required this.phone,
    required this.classRoom,
  });

  Map<String, dynamic> toMap() => {
    'email': email,
    'mssv': mssv,
    'name': name,
    'role': role,
    'phone': phone,
    'class': classRoom,
  };
}
