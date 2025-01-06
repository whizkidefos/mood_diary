import 'package:cloud_firestore/cloud_firestore.dart';

class MessageAnalytics {
  final _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getChatAnalytics(String chatId) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    final analytics = {
      'totalMessages': messages.size,
      'messageTypes': <String, int>{},
      'averageResponseTime': 0.0,
      'activeHours': <int, int>{},
      'mediaCount': 0,
    };

    DateTime? lastMessageTime;
    Duration totalResponseTime = Duration.zero;
    int responseCount = 0;

    for (final doc in messages.docs) {
      final data = doc.data();
      final type = data['type'] as String;
      (analytics['messageTypes'] as Map<String, int>)[type] =
          ((analytics['messageTypes'] as Map<String, int>)[type] ?? 0) + 1;

      if (type == 'media') {
        analytics['mediaCount'] = (analytics['mediaCount'] as int) + 1;
      }

      final timestamp = (data['timestamp'] as Timestamp).toDate();
      (analytics['activeHours'] as Map<int, int>)[timestamp.hour] =
          ((analytics['activeHours'] as Map<int, int>)[timestamp.hour] ?? 0) +
              1;

      if (lastMessageTime != null &&
          data['senderId'] !=
              messages.docs[messages.size - 1].data()['senderId']) {
        totalResponseTime += timestamp.difference(lastMessageTime);
        responseCount++;
      }
      lastMessageTime = timestamp;
    }

    if (responseCount > 0) {
      analytics['averageResponseTime'] =
          totalResponseTime.inMilliseconds / responseCount;
    }

    return analytics;
  }
}
