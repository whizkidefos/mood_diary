import 'package:cloud_firestore/cloud_firestore.dart';

class MessageSearch {
  final _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> searchMessages({
    required String chatId,
    required String query,
    DateTime? startDate,
    DateTime? endDate,
    String? messageType,
  }) async {
    Query messagesQuery = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    if (startDate != null) {
      messagesQuery =
          messagesQuery.where('timestamp', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      messagesQuery =
          messagesQuery.where('timestamp', isLessThanOrEqualTo: endDate);
    }

    if (messageType != null) {
      messagesQuery = messagesQuery.where('type', isEqualTo: messageType);
    }

    final messages = await messagesQuery.get();
    return messages.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final text = data['text']?.toString().toLowerCase() ?? '';
      return text.contains(query.toLowerCase());
    }).toList();
  }
}
