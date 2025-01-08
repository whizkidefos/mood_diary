import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatAnalyticsService {
  static final ChatAnalyticsService _instance = ChatAnalyticsService._internal();
  factory ChatAnalyticsService() => _instance;
  ChatAnalyticsService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Track message sent
  Future<void> trackMessageSent(String chatId, String messageType) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _firestore.batch();
      final timestamp = FieldValue.serverTimestamp();

      // Update user stats
      final userStatsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('chat');
      
      batch.set(
        userStatsRef,
        {
          'totalMessagesSent': FieldValue.increment(1),
          'messageTypes': {
            messageType: FieldValue.increment(1),
          },
          'lastMessageTime': timestamp,
        },
        SetOptions(merge: true),
      );

      // Update chat stats
      final chatStatsRef =
          _firestore.collection('chats').doc(chatId).collection('stats').doc('messages');
      
      batch.set(
        chatStatsRef,
        {
          'totalMessages': FieldValue.increment(1),
          'messageTypes': {
            messageType: FieldValue.increment(1),
          },
          'participantStats': {
            userId: {
              'messagesSent': FieldValue.increment(1),
              'lastMessageTime': timestamp,
            },
          },
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      print('Error tracking message sent: $e');
      rethrow;
    }
  }

  // Track message read
  Future<void> trackMessageRead(String chatId, String messageId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'readBy': FieldValue.arrayUnion([userId]),
        'readTimestamp': {
          userId: FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      print('Error tracking message read: $e');
      rethrow;
    }
  }

  // Track chat session
  Future<void> trackChatSession(String chatId, int duration) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _firestore.batch();
      final timestamp = FieldValue.serverTimestamp();

      // Update user session stats
      final userSessionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('sessions');
      
      batch.set(
        userSessionRef,
        {
          'totalSessions': FieldValue.increment(1),
          'totalDuration': FieldValue.increment(duration),
          'lastSessionTime': timestamp,
        },
        SetOptions(merge: true),
      );

      // Update chat session stats
      final chatSessionRef =
          _firestore.collection('chats').doc(chatId).collection('stats').doc('sessions');
      
      batch.set(
        chatSessionRef,
        {
          'totalSessions': FieldValue.increment(1),
          'totalDuration': FieldValue.increment(duration),
          'participantStats': {
            userId: {
              'sessionCount': FieldValue.increment(1),
              'totalDuration': FieldValue.increment(duration),
              'lastSessionTime': timestamp,
            },
          },
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      print('Error tracking chat session: $e');
      rethrow;
    }
  }

  // Get user chat statistics
  Future<Map<String, dynamic>> getUserChatStats(String userId) async {
    try {
      final statsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('chat')
          .get();

      return statsDoc.data() ?? {};
    } catch (e) {
      print('Error getting user chat stats: $e');
      rethrow;
    }
  }

  // Get chat statistics
  Future<Map<String, dynamic>> getChatStats(String chatId) async {
    try {
      final statsDoc = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('stats')
          .doc('messages')
          .get();

      return statsDoc.data() ?? {};
    } catch (e) {
      print('Error getting chat stats: $e');
      rethrow;
    }
  }

  // Get user engagement metrics
  Future<Map<String, dynamic>> getUserEngagementMetrics(String userId) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      // Get messages sent in last 30 days
      final messageQuery = await _firestore
          .collectionGroup('messages')
          .where('senderId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: thirtyDaysAgo)
          .count()
          .get();

      // Get total sessions in last 30 days
      final sessionDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('sessions')
          .get();

      final sessionData = sessionDoc.data() ?? {};
      
      return {
        'thirtyDayMessageCount': messageQuery.count,
        'totalSessions': sessionData['totalSessions'] ?? 0,
        'totalSessionDuration': sessionData['totalDuration'] ?? 0,
        'averageSessionDuration': sessionData['totalSessions'] == null
            ? 0
            : (sessionData['totalDuration'] ?? 0) / sessionData['totalSessions'],
      };
    } catch (e) {
      print('Error getting user engagement metrics: $e');
      rethrow;
    }
  }

  // Track reaction added
  Future<void> trackReactionAdded(
      String chatId, String messageId, String reactionType) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _firestore.batch();

      // Update message reactions
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);
      
      batch.update(messageRef, {
        'reactions': {
          userId: reactionType,
        },
      });

      // Update reaction stats
      final statsRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('stats')
          .doc('reactions');
      
      batch.set(
        statsRef,
        {
          'totalReactions': FieldValue.increment(1),
          'reactionTypes': {
            reactionType: FieldValue.increment(1),
          },
          'participantStats': {
            userId: {
              'reactionsGiven': FieldValue.increment(1),
              'lastReactionTime': FieldValue.serverTimestamp(),
            },
          },
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      print('Error tracking reaction: $e');
      rethrow;
    }
  }
}
