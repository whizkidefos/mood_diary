import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String chatId, Map<String, dynamic> message) async {
    final batch = _firestore.batch();

    // Add message
    final messageRef =
        _firestore.collection('chats').doc(chatId).collection('messages').doc();

    batch.set(messageRef, {
      ...message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update chat metadata
    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': message['text'],
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<List<String>> uploadFiles(
      String chatId, List<String> filePaths) async {
    final urls = <String>[];

    for (final path in filePaths) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('chats/$chatId/$fileName');

      await ref.putFile(File(path));
      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  Future<void> markMessagesAsRead(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount': 0,
    });
  }

  Future<void> updateTypingStatus(
      String chatId, String userId, bool isTyping) async {
    await _firestore.collection('chats').doc(chatId).update({
      'typingUsers': isTyping
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
    });
  }

  Stream<DocumentSnapshot> getTypingStatus(String chatId) {
    return _firestore.collection('chats').doc(chatId).snapshots();
  }
}
