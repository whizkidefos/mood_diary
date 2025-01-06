import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood_diary/models/achievement_models.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Achievement>> getUserAchievements() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Achievement.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> checkAndUpdateAchievements() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Get user stats
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();
    if (userData == null) return;

    // Check for achievements
    final achievements = await _getAchievementDefinitions();
    for (var achievement in achievements) {
      if (await _checkAchievementRequirements(achievement, userData)) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<List<Achievement>> _getAchievementDefinitions() async {
    final snapshot =
        await _firestore.collection('achievementDefinitions').get();
    return snapshot.docs.map((doc) => Achievement.fromMap(doc.data())).toList();
  }

  Future<bool> _checkAchievementRequirements(
    Achievement achievement,
    Map<String, dynamic> userData,
  ) async {
    // Implement achievement-specific logic here
    switch (achievement.id) {
      case 'mood_streak_7':
        return (userData['moodStreakDays'] ?? 0) >= 7;
      case 'social_butterfly':
        return (userData['postsCount'] ?? 0) >= 10;
      case 'meditation_master':
        return (userData['meditationMinutes'] ?? 0) >= 60;
      default:
        return false;
    }
  }

  Future<void> _unlockAchievement(String achievementId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .set({
      'isUnlocked': true,
      'unlockedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
