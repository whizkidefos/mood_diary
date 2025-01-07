import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReadReceiptService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> markMessageAsRead(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'readBy': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markChatAsRead(String chatId) async {
    final batch = _firestore.batch();
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('readBy', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get();

    for (final doc in messages.docs) {
      batch.update(doc.reference, {
        'readBy':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Stream<DocumentSnapshot> getMessageReadStatus(
      String chatId, String messageId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .snapshots();
  }
}

// lib/widgets/read_receipt.dart
class ReadReceipt extends StatelessWidget {
  final String chatId;
  final String messageId;
  final bool isSent;
  final bool isDelivered;

  const ReadReceipt({
    super.key,
    required this.chatId,
    required this.messageId,
    required this.isSent,
    required this.isDelivered,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ReadReceiptService().getMessageReadStatus(chatId, messageId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Icon(Icons.done, size: 16);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final readBy = List<String>.from(data['readBy'] ?? []);
        final isRead = readBy.isNotEmpty;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isSent)
              const Icon(Icons.schedule, size: 16)
            else if (!isDelivered)
              const Icon(Icons.done, size: 16)
            else if (!isRead)
              const Icon(Icons.done_all, size: 16)
            else
              Icon(
                Icons.done_all,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        );
      },
    );
  }
}
