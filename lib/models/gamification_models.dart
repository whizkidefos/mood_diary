class UserLevel {
  final int level;
  final int currentXP;
  final int requiredXP;
  final String title;
  final List<String> perks;

  UserLevel({
    required this.level,
    required this.currentXP,
    required this.requiredXP,
    required this.title,
    required this.perks,
  });

  double get progress => currentXP / requiredXP;

  factory UserLevel.fromMap(Map<String, dynamic> map) {
    return UserLevel(
      level: map['level'] ?? 1,
      currentXP: map['currentXP'] ?? 0,
      requiredXP: map['requiredXP'] ?? 100,
      title: map['title'] ?? 'Beginner',
      perks: List<String>.from(map['perks'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'currentXP': currentXP,
      'requiredXP': requiredXP,
      'title': title,
      'perks': perks,
    };
  }
}

class UserBadge {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final BadgeRarity rarity;
  final DateTime? unlockedAt;
  final List<String> requirements;
  final Map<String, dynamic> progress;

  UserBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.rarity,
    this.unlockedAt,
    required this.requirements,
    required this.progress,
  });

  bool get isUnlocked => unlockedAt != null;

  factory UserBadge.fromMap(Map<String, dynamic> map) {
    return UserBadge(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      iconPath: map['iconPath'],
      rarity: BadgeRarity.values.firstWhere(
        (r) => r.toString() == map['rarity'],
        orElse: () => BadgeRarity.common,
      ),
      unlockedAt:
          map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
      requirements: List<String>.from(map['requirements']),
      progress: Map<String, dynamic>.from(map['progress']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'rarity': rarity.toString(),
      'unlockedAt': unlockedAt?.toIso8601String(),
      'requirements': requirements,
      'progress': progress,
    };
  }
}

enum BadgeRarity {
  common,
  rare,
  epic,
  legendary,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final int xpReward;
  final List<String> requirements;
  final Map<String, dynamic> progress;
  final DateTime? completedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.xpReward,
    required this.requirements,
    required this.progress,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;
  double get progressPercentage {
    if (progress.isEmpty) return 0.0;
    final values = progress.values.whereType<num>();
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / progress.length;
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: AchievementCategory.values.firstWhere(
        (c) => c.toString() == map['category'],
        orElse: () => AchievementCategory.general,
      ),
      xpReward: map['xpReward'],
      requirements: List<String>.from(map['requirements']),
      progress: Map<String, dynamic>.from(map['progress']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString(),
      'xpReward': xpReward,
      'requirements': requirements,
      'progress': progress,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

enum AchievementCategory {
  general,
  social,
  activity,
  mood,
  support,
  challenge,
}

// Example Rewards
class Reward {
  final String id;
  final String title;
  final String description;
  final RewardType type;
  final int cost;
  final bool isLimited;
  final int? remainingQuantity;
  final DateTime? expiresAt;
  final String? imageUrl;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.cost,
    this.isLimited = false,
    this.remainingQuantity,
    this.expiresAt,
    this.imageUrl,
  });

  bool get isAvailable {
    if (isLimited && (remainingQuantity ?? 0) <= 0) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: RewardType.values.firstWhere(
        (t) => t.toString() == map['type'],
        orElse: () => RewardType.virtual,
      ),
      cost: map['cost'],
      isLimited: map['isLimited'] ?? false,
      remainingQuantity: map['remainingQuantity'],
      expiresAt:
          map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'cost': cost,
      'isLimited': isLimited,
      'remainingQuantity': remainingQuantity,
      'expiresAt': expiresAt?.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}

enum RewardType {
  virtual,
  physical,
  discount,
  feature,
}
