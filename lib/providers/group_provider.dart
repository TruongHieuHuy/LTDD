import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/group_model.dart';

/// Provider quản lý nhóm xã hội (Zalo-style groups)
class GroupProvider extends ChangeNotifier {
  static const String _groupsBoxName = 'groups';
  static const String _membersBoxName = 'group_members';

  Box? _groupsBox;
  Box? _membersBox;

  String? _currentUserId; // Current user's MSSV

  // Getters
  String? get currentUserId => _currentUserId;
  bool get isInitialized => _groupsBox != null && _membersBox != null;

  /// Initialize provider with current user
  Future<void> initialize(String userId) async {
    _currentUserId = userId;

    // Open Hive boxes
    if (!Hive.isBoxOpen(_groupsBoxName)) {
      _groupsBox = await Hive.openBox(_groupsBoxName);
    } else {
      _groupsBox = Hive.box(_groupsBoxName);
    }

    if (!Hive.isBoxOpen(_membersBoxName)) {
      _membersBox = await Hive.openBox(_membersBoxName);
    } else {
      _membersBox = Hive.box(_membersBoxName);
    }

    notifyListeners();
  }

  /// Create a new group
  Future<Group?> createGroup({
    required String name,
    String? description,
    bool isPublic = false,
    List<String>? initialMemberIds,
  }) async {
    if (_groupsBox == null || _membersBox == null || _currentUserId == null) {
      return null;
    }

    final now = DateTime.now();
    final groupId = 'group_${now.millisecondsSinceEpoch}';

    // Create group
    final group = Group(
      id: groupId,
      name: name,
      description: description,
      creatorId: _currentUserId!,
      createdAt: now,
      isPublic: isPublic,
      adminIds: [_currentUserId!],
    );

    await _groupsBox!.put(groupId, group.toJson());

    // Add creator as first member
    final creatorMember = GroupMember(
      id: GroupMember.getMemberId(groupId, _currentUserId!),
      groupId: groupId,
      userId: _currentUserId!,
      joinedAt: now,
      role: 'creator',
    );
    await _membersBox!.put(creatorMember.id, creatorMember.toJson());

    // Add initial members if provided
    if (initialMemberIds != null && initialMemberIds.isNotEmpty) {
      for (final memberId in initialMemberIds) {
        if (memberId != _currentUserId) {
          await addMember(
            groupId: groupId,
            userId: memberId,
            addedBy: _currentUserId!,
          );
        }
      }
    }

    notifyListeners();
    debugPrint('Created group: $groupId with name: $name');
    return group;
  }

  /// Add member to group
  Future<bool> addMember({
    required String groupId,
    required String userId,
    String? addedBy,
  }) async {
    if (_groupsBox == null || _membersBox == null) return false;

    // Check if group exists
    final groupJson = _groupsBox!.get(groupId);
    if (groupJson == null) {
      debugPrint('Group not found: $groupId');
      return false;
    }

    // Check if user is already a member
    final memberId = GroupMember.getMemberId(groupId, userId);
    if (_membersBox!.containsKey(memberId)) {
      debugPrint('User $userId is already a member of $groupId');
      return false;
    }

    // Create member entry
    final member = GroupMember(
      id: memberId,
      groupId: groupId,
      userId: userId,
      joinedAt: DateTime.now(),
      addedBy: addedBy ?? _currentUserId,
    );

    await _membersBox!.put(memberId, member.toJson());
    notifyListeners();

    debugPrint('Added user $userId to group $groupId');
    return true;
  }

  /// Remove member from group
  Future<bool> removeMember({
    required String groupId,
    required String userId,
  }) async {
    if (_groupsBox == null || _membersBox == null) return false;

    final groupJson = _groupsBox!.get(groupId);
    if (groupJson == null) return false;

    final group = Group.fromJson(Map<String, dynamic>.from(groupJson));

    // Cannot remove creator
    if (group.isCreator(userId)) {
      debugPrint('Cannot remove group creator');
      return false;
    }

    final memberId = GroupMember.getMemberId(groupId, userId);
    await _membersBox!.delete(memberId);

    notifyListeners();
    debugPrint('Removed user $userId from group $groupId');
    return true;
  }

  /// Get all groups where current user is a member
  List<Group> getUserGroups() {
    if (_groupsBox == null || _membersBox == null || _currentUserId == null) {
      return [];
    }

    // Get all groups where user is a member
    final userMemberships = _membersBox!.values
        .map((json) => GroupMember.fromJson(Map<String, dynamic>.from(json)))
        .where((member) => member.userId == _currentUserId)
        .map((member) => member.groupId)
        .toSet();

    return _groupsBox!.values
        .map((json) => Group.fromJson(Map<String, dynamic>.from(json)))
        .where((group) => userMemberships.contains(group.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get specific group
  Group? getGroup(String groupId) {
    if (_groupsBox == null) return null;

    final groupJson = _groupsBox!.get(groupId);
    return groupJson != null
        ? Group.fromJson(Map<String, dynamic>.from(groupJson))
        : null;
  }

  /// Get members of a group
  List<GroupMember> getGroupMembers(String groupId) {
    if (_membersBox == null) return [];

    return _membersBox!.values
        .map((json) => GroupMember.fromJson(Map<String, dynamic>.from(json)))
        .where((member) => member.groupId == groupId)
        .toList()
      ..sort((a, b) {
        // Sort by role: creator first, then admins, then members
        if (a.isCreator) return -1;
        if (b.isCreator) return 1;
        if (a.isAdmin && !b.isAdmin) return -1;
        if (!a.isAdmin && b.isAdmin) return 1;
        return a.joinedAt.compareTo(b.joinedAt);
      });
  }

  /// Get member IDs in a group
  List<String> getGroupMemberIds(String groupId) {
    return getGroupMembers(groupId).map((member) => member.userId).toList();
  }

  /// Check if user is member of group
  bool isMember(String groupId, String userId) {
    if (_membersBox == null) return false;

    final memberId = GroupMember.getMemberId(groupId, userId);
    return _membersBox!.containsKey(memberId);
  }

  /// Check if user is admin of group
  bool isAdmin(String groupId, String userId) {
    if (_membersBox == null) return false;

    final memberId = GroupMember.getMemberId(groupId, userId);
    final memberJson = _membersBox!.get(memberId);

    if (memberJson == null) return false;

    final member = GroupMember.fromJson(Map<String, dynamic>.from(memberJson));
    return member.isAdmin;
  }

  /// Update group info (name, description, etc.)
  Future<bool> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    if (_groupsBox == null || _currentUserId == null) return false;

    final groupJson = _groupsBox!.get(groupId);
    if (groupJson == null) return false;

    final group = Group.fromJson(Map<String, dynamic>.from(groupJson));

    // Check if user is admin
    if (!group.isAdmin(_currentUserId!)) {
      debugPrint('User is not admin of group $groupId');
      return false;
    }

    // Update group
    final updatedGroup = Group(
      id: group.id,
      name: name ?? group.name,
      description: description ?? group.description,
      creatorId: group.creatorId,
      createdAt: group.createdAt,
      avatarUrl: avatarUrl ?? group.avatarUrl,
      adminIds: group.adminIds,
      isPublic: group.isPublic,
    );

    await _groupsBox!.put(groupId, updatedGroup.toJson());
    notifyListeners();

    debugPrint('Updated group: $groupId');
    return true;
  }

  /// Promote member to admin
  Future<bool> promoteToAdmin({
    required String groupId,
    required String userId,
  }) async {
    if (_groupsBox == null || _membersBox == null || _currentUserId == null) {
      return false;
    }

    final groupJson = _groupsBox!.get(groupId);
    if (groupJson == null) return false;

    final group = Group.fromJson(Map<String, dynamic>.from(groupJson));

    // Check if current user is creator
    if (!group.isCreator(_currentUserId!)) {
      debugPrint('Only creator can promote members');
      return false;
    }

    // Update member role
    final memberId = GroupMember.getMemberId(groupId, userId);
    final memberJson = _membersBox!.get(memberId);
    if (memberJson == null) return false;

    final member = GroupMember.fromJson(Map<String, dynamic>.from(memberJson));
    final updatedMember = GroupMember(
      id: member.id,
      groupId: member.groupId,
      userId: member.userId,
      joinedAt: member.joinedAt,
      role: 'admin',
      addedBy: member.addedBy,
      canViewAchievements: member.canViewAchievements,
      canViewProfile: member.canViewProfile,
    );

    await _membersBox!.put(memberId, updatedMember.toJson());

    // Add to group's admin list
    if (!group.adminIds.contains(userId)) {
      group.adminIds.add(userId);
      await _groupsBox!.put(groupId, group.toJson());
    }

    notifyListeners();
    debugPrint('Promoted user $userId to admin in group $groupId');
    return true;
  }

  /// Delete group (only creator can delete)
  Future<bool> deleteGroup(String groupId) async {
    if (_groupsBox == null || _membersBox == null || _currentUserId == null) {
      return false;
    }

    final groupJson = _groupsBox!.get(groupId);
    if (groupJson == null) return false;

    final group = Group.fromJson(Map<String, dynamic>.from(groupJson));

    // Check if current user is creator
    if (!group.isCreator(_currentUserId!)) {
      debugPrint('Only creator can delete group');
      return false;
    }

    // Delete all members
    final members = getGroupMembers(groupId);
    for (final member in members) {
      await _membersBox!.delete(member.id);
    }

    // Delete group
    await _groupsBox!.delete(groupId);

    notifyListeners();
    debugPrint('Deleted group: $groupId');
    return true;
  }

  /// Get number of groups user is in
  int get groupCount => getUserGroups().length;

  /// Dispose resources
  @override
  void dispose() {
    // Don't close boxes here - they're shared across providers
    super.dispose();
  }
}
