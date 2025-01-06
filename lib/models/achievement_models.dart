class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int pointsValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final AchievementCategory category;
  final List<String> requirements;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.pointsValue,
    required this.isUnlocked,
    this.unlockedAt,
    required this.category,
    required this.requirements,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'pointsValue': pointsValue,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'category': category.toString(),
      'requirements': requirements,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconName: map['iconName'],
      pointsValue: map['pointsValue'],
      isUnlocked: map['isUnlocked'],
      unlockedAt:
          map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
      category: AchievementCategory.values.firstWhere(
        (c) => c.toString() == map['category'],
      ),
      requirements: List<String>.from(map['requirements']),
    );
  }
}

enum AchievementCategory { mood, social, activity, meditation, streak }
