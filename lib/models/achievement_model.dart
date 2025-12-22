import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 4)
class AchievementModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; // "Thần Troll", "Vua May Mắn"

  @HiveField(2)
  String description;

  @HiveField(3)
  String iconEmoji; // 🎭, 🍀, 🏆

  @HiveField(4)
  bool isUnlocked;

  @HiveField(5)
  DateTime? unlockedAt;

  @HiveField(6)
  String rarity; // 'common', 'rare', 'epic', 'legendary'

  @HiveField(7)
  String condition; // Điều kiện unlock (text description)

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.rarity,
    required this.condition,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconEmoji': iconEmoji,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'rarity': rarity,
    'condition': condition,
  };

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      AchievementModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        iconEmoji: json['iconEmoji'],
        isUnlocked: json['isUnlocked'] ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'])
            : null,
        rarity: json['rarity'],
        condition: json['condition'],
      );
}

/// Achievement data from Backend API
class AchievementData {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category; // general, games, social, milestone
  final int points;
  final Map<String, dynamic> requirement;

  AchievementData({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.points,
    required this.requirement,
  });

  factory AchievementData.fromJson(Map<String, dynamic> json) {
    return AchievementData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      category: json['category'],
      points: json['points'],
      requirement: json['requirement'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'category': category,
    'points': points,
    'requirement': requirement,
  };
}

/// User achievement with progress tracking
class UserAchievementData {
  final String achievementId;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int points;
  final bool unlocked;
  final double progress; // 0-100%
  final DateTime? unlockedAt;

  UserAchievementData({
    required this.achievementId,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.points,
    required this.unlocked,
    required this.progress,
    this.unlockedAt,
  });

  factory UserAchievementData.fromJson(Map<String, dynamic> json) {
    return UserAchievementData(
      achievementId: json['achievementId'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      category: json['category'],
      points: json['points'],
      unlocked: json['unlocked'] ?? false,
      progress: (json['progress'] ?? 0).toDouble(),
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'name': name,
    'description': description,
    'icon': icon,
    'category': category,
    'points': points,
    'unlocked': unlocked,
    'progress': progress,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };
}

/// Predefined Achievements
class Achievements {
  static final List<AchievementModel> all = [
    // === COMMON (Dễ đạt) ===
    AchievementModel(
      id: 'first_win',
      name: 'Tân Binh',
      description: 'Thắng game đầu tiên',
      iconEmoji: '🎓',
      rarity: 'common',
      condition: 'Hoàn thành 1 game bất kỳ',
    ),
    AchievementModel(
      id: 'ten_games',
      name: 'Người Chơi Hệ',
      description: 'Chơi 10 ván',
      iconEmoji: '🎮',
      rarity: 'common',
      condition: 'Tham gia 10 game',
    ),

    // === RARE (Khó hơn) ===
    AchievementModel(
      id: 'lucky_king',
      name: 'Vua May Mắn',
      description: 'Thắng trong 3 lần thử',
      iconEmoji: '🍀',
      rarity: 'rare',
      condition: 'Đoán đúng số trong 3 lượt',
    ),
    AchievementModel(
      id: 'troll_god',
      name: 'Thần Troll',
      description: 'Bị troll 50 lần',
      iconEmoji: '🎭',
      rarity: 'rare',
      condition: 'Gặp 50 feedback meme',
    ),
    AchievementModel(
      id: 'speed_demon',
      name: 'Tốc Độ Ánh Sáng',
      description: 'Thắng trong 30 giây',
      iconEmoji: '⚡',
      rarity: 'rare',
      condition: 'Hoàn thành game < 30s',
    ),

    // === EPIC (Rất khó) ===
    AchievementModel(
      id: 'perfect_game',
      name: 'Hoàn Hảo',
      description: 'Thắng mà không sai lần nào',
      iconEmoji: '💎',
      rarity: 'epic',
      condition: 'Đoán đúng lần đầu tiên',
    ),
    AchievementModel(
      id: 'hard_mode_master',
      name: 'Cao Thủ Khó',
      description: 'Thắng mode Hard 5 lần',
      iconEmoji: '🔥',
      rarity: 'epic',
      condition: 'Chiến thắng 5 game độ khó cao',
    ),
    AchievementModel(
      id: 'bulls_12_digit',
      name: 'Siêu Não Bò',
      description: 'Thắng Bò Bê 12 số',
      iconEmoji: '🐂',
      rarity: 'epic',
      condition: 'Hoàn thành level 12 số',
    ),

    // === LEGENDARY (Gần như không thể) ===
    AchievementModel(
      id: 'ultimate_hacker',
      name: 'Hacker Tối Thượng',
      description: 'Thắng 10 game liên tiếp',
      iconEmoji: '👑',
      rarity: 'legendary',
      condition: 'Win streak x10',
    ),
    AchievementModel(
      id: 'never_give_up',
      name: 'Kiên Trì Đến Cùng',
      description: 'Không bao giờ đầu hàng trong 50 game',
      iconEmoji: '🛡️',
      rarity: 'legendary',
      condition: 'Chơi 50 game không surrender',
    ),
  ];
}
