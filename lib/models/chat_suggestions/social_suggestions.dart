import 'base_model.dart';

/// Social Network features (NEW)
class SocialSuggestions {
  static ChatSuggestion getMainCategory() {
    return ChatSuggestion(
      id: 'social',
      title: '🌐 Social Network',
      icon: '👥',
      description: 'Mạng xã hội nội bộ',
      subItems: getAll(),
    );
  }

  static List<ChatSuggestion> getAll() {
    return [
      _posts(),
      _friends(),
      _groups(),
      _chat(),
    ];
  }

  static ChatSuggestion _posts() {
    return ChatSuggestion(
      id: 'social_posts',
      title: '📝 Posts & Feed',
      icon: '📱',
      fullResponse: '''📝 **POSTS & FEED**

🎯 **Tính năng:**

**1. Tạo bài viết**
• Text content
• Upload ảnh
• Visibility: Public/Friends/Private
• Tag category

**2. Tương tác**
• ❤️ Like/Unlike
• 💬 Comment
• 🔄 Share
• 🔖 Save (bookmark)

**3. News Feed**
• All users' posts
• Filter by category
• Search posts
• Infinite scroll

**4. My Posts**
• Your posts only
• Edit/Delete
• View stats

**5. Saved Posts**
• Bookmarked posts
• Quick access

🎨 **UI:**
• Rich text
• Image preview/zoom
• User avatars
• Relative timestamp

🔔 **Notifications:**
• Someone liked
• New comment
• Post shared''',
    );
  }

  static ChatSuggestion _friends() {
    return ChatSuggestion(
      id: 'social_friends',
      title: '👥 Friends System',
      icon: '🤝',
      fullResponse: '''👥 **FRIENDS SYSTEM**

📝 **Features:**

**1. Search Users**
• By username/email
• View profiles
• Mutual friends
• Online status

**2. Friend Request**
• Send request
• Optional message
• Pending state
• Can cancel

**3. Requests Inbox**
• Received requests
• Accept/Reject
• Badge counter

**4. Friends List**
• All friends
• Quick chat
• View profiles
• Unfriend option

**5. Actions**
• 💬 Send message
• ⚔️ Challenge
• 👀 View profile
• 🚫 Unfriend

🔔 **Notifications:**
• New request
• Request accepted
• Friend online''',
    );
  }

  static ChatSuggestion _groups() {
    return ChatSuggestion(
      id: 'social_groups',
      title: '👥 Groups',
      icon: '👨‍👩‍👧‍👦',
      fullResponse: '''👥 **GROUPS**

📦 **Features:**

**1. Create Group**
• Group name
• Description
• Privacy setting
• Creator = admin

**2. Manage Members**
• Invite friends
• Accept/Reject joins
• Remove members
• Promote admin

**3. Activities**
• Group posts (soon)
• Group challenges (soon)
• Member stats
• Leaderboard

**4. My Groups**
• Admin role
• Member role
• Leave group
• Details

🎯 **Use Cases:**
• Class groups
• Friend circles
• Game teams
• Study groups''',
    );
  }

  static ChatSuggestion _chat() {
    return ChatSuggestion(
      id: 'social_chat',
      title: '💬 P2P Chat',
      icon: '🗨️',
      fullResponse: '''💬 **P2P CHAT**

🎯 **Features:**

**1. Chat 1-1**
• Private messaging
• Real-time
• Auto-scroll
• Message history

**2. Message Management**
• Long press → Select
• Delete multiple
• Selection mode
• Confirmation

**3. UI/UX**
• Bubble style
• Sender/receiver colors
• Timestamps
• Empty state

**4. Notifications**
• Unread badge
• Mark as read
• Visual indicators

💾 **Storage:**
• Hive local DB
• Persistent history
• Fast queries
• No data loss

🔒 **Privacy:**
• Local-only
• No server upload
• Privacy-first

💡 **Tips:**
• Long press to delete many
• Auto-scroll to new
• Check unread badges''',
    );
  }
}
