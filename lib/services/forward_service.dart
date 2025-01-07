import 'package:cloud_firestore/cloud_firestore.dart';

class ForwardService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> forwardMessage({
    required String messageId,
    required String sourceChatId,
    required List<String> targetChatIds,
  }) async {
    final messageDoc = await _firestore
        .collection('chats')
        .doc(sourceChatId)
        .collection('messages')
        .doc(messageId)
        .get();

    if (!messageDoc.exists) return;

    final message = messageDoc.data()!;
    final batch = _firestore.batch();

    for (final targetChatId in targetChatIds) {
      final newMessageRef = _firestore
          .collection('chats')
          .doc(targetChatId)
          .collection('messages')
          .doc();

      batch.set(newMessageRef, {
        ...message,
        'timestamp': FieldValue.serverTimestamp(),
        'forwardedFrom': sourceChatId,
        'originalMessageId': messageId,
      });
    }

    await batch.commit();
  }
}
