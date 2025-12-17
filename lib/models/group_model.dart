import 'package:hive/hive.dart';

part 'group_model.g.dart';

/// Model for social groups (Zalo-style)
@HiveType(typeId: 9)
class Group extends HiveObject {
  @HiveField(0)
  String id; // Unique group ID

  @HiveField(1)
  String name; // Group name

  @HiveField(2)
  String? description; // Optional description

  @HiveField(3)
  String creatorId; // MSSV of creator

  @HiveField(4)
  DateTime createdAt; // When group was created

  @HiveField(5)
  String? avatarUrl; // Optional group avatar

  @HiveField(6)
  List<String> adminIds; // List of admin MSSVs (creator is always admin)

  @HiveField(7)
  bool isPublic; // Public or private group

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.creatorId,
    required this.createdAt,
    this.avatarUrl,
    List<String>? adminIds,
    this.isPublic = false,
  }) : adminIds = adminIds ?? [creatorId];

  /// Check if user is admin
  bool isAdmin(String userId) => adminIds.contains(userId);

  /// Check if user is creator
  bool isCreator(String userId) => creatorId == userId;

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'creatorId': creatorId,
    'createdAt': createdAt.toIso8601String(),
    'avatarUrl': avatarUrl,
    'adminIds': adminIds,
    'isPublic': isPublic,
  };

  /// Create from JSON
  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    creatorId: json['creatorId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    avatarUrl: json['avatarUrl'] as String?,
    adminIds: (json['adminIds'] as List?)?.cast<String>(),
    isPublic: json['isPublic'] as bool? ?? false,
  );
}

/// Model for group members
@HiveType(typeId: 10)
class GroupMember extends HiveObject {
  @HiveField(0)
  String id; // Unique member ID (format: groupId_userId)

  @HiveField(1)
  String groupId; // Group ID

  @HiveField(2)
  String userId; // User's MSSV

  @HiveField(3)
  DateTime joinedAt; // When user joined

  @HiveField(4)
  String role; // 'creator', 'admin', 'member'

  @HiveField(5)
  String? addedBy; // MSSV of user who added this member

  @HiveField(6)
  bool canViewAchievements; // Permission to view achievements

  @HiveField(7)
  bool canViewProfile; // Permission to view full profile

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.joinedAt,
    this.role = 'member',
    this.addedBy,
    this.canViewAchievements = true,
    this.canViewProfile = true,
  });

  /// Get member ID from group and user
  static String getMemberId(String groupId, String userId) {
    return '${groupId}_$userId';
  }

  bool get isCreator => role == 'creator';
  bool get isAdmin => role == 'admin' || role == 'creator';
  bool get isMember => role == 'member';

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'groupId': groupId,
    'userId': userId,
    'joinedAt': joinedAt.toIso8601String(),
    'role': role,
    'addedBy': addedBy,
    'canViewAchievements': canViewAchievements,
    'canViewProfile': canViewProfile,
  };

  /// Create from JSON
  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
    id: json['id'] as String,
    groupId: json['groupId'] as String,
    userId: json['userId'] as String,
    joinedAt: DateTime.parse(json['joinedAt'] as String),
    role: json['role'] as String? ?? 'member',
    addedBy: json['addedBy'] as String?,
    canViewAchievements: json['canViewAchievements'] as bool? ?? true,
    canViewProfile: json['canViewProfile'] as bool? ?? true,
  );
}
