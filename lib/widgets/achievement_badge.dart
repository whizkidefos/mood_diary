import 'package:flutter/material.dart';
import 'package:mood_diary/models/achievement_models.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: achievement.isUnlocked
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (achievement.isUnlocked)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconData(
                int.parse(achievement.iconName),
                fontFamily: 'MaterialIcons',
              ),
              size: 32,
              color: achievement.isUnlocked
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: achievement.isUnlocked
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            if (achievement.isUnlocked) ...[
              const SizedBox(height: 4),
              Text(
                '+${achievement.pointsValue}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
