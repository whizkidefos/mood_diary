import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workmanager/workmanager.dart';

class ScheduledMessageService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> scheduleMessage({
    required String chatId,
    required String message,
    required DateTime scheduledTime,
    List<String>? mediaUrls,
  }) async {
    final docRef = await _firestore.collection('scheduled_messages').add({
      'chatId': chatId,
      'message': message,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'mediaUrls': mediaUrls,
      'status': 'pending',
    });

    await Workmanager().registerOneOffTask(
      docRef.id,
      'scheduled_message',
      inputData: {
        'messageId': docRef.id,
        'chatId': chatId,
      },
      initialDelay: scheduledTime.difference(DateTime.now()),
    );
  }

  Stream<QuerySnapshot> getScheduledMessages(String chatId) {
    return _firestore
        .collection('scheduled_messages')
        .where('chatId', isEqualTo: chatId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> cancelScheduledMessage(String messageId) async {
    await _firestore
        .collection('scheduled_messages')
        .doc(messageId)
        .update({'status': 'cancelled'});
  }
}
