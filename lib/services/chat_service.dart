import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<bool> getTypingStatus(String chatId, String userId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return false;
      final typingUsers = List<String>.from(snapshot.get('typingUsers') ?? []);
      return typingUsers.contains(userId);
    });
  }

  Stream<bool> getOnlineStatus(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return false;
      final lastSeen = snapshot.get('lastSeen') as Timestamp?;
      if (lastSeen == null) return false;
      
      // Consider user online if last seen within last 2 minutes
      return DateTime.now()
          .difference(lastSeen.toDate())
          .inMinutes < 2;
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    List<String>? mediaUrls,
    String? replyToId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final message = {
        'senderId': currentUser.uid,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'type': mediaUrls != null ? 'media' : 'text',
        if (mediaUrls != null) 'mediaUrls': mediaUrls,
        if (replyToId != null) 'replyToId': replyToId,
        if (metadata != null) ...metadata,
      };

      final batch = _firestore.batch();

      // Add message
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      batch.set(messageRef, message);

      // Update chat metadata
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': currentUser.uid,
        'unreadCount': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<List<String>> uploadMediaFiles(String chatId, List<String> filePaths) async {
    try {
      final urls = <String>[];
      for (final path in filePaths) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = _storage.ref().child('chats/$chatId/$fileName');
        await ref.putFile(File(path));
        final url = await ref.getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      print('Error uploading media files: $e');
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount': 0,
      });
    } catch (e) {
      print('Error marking messages as read: $e');
      rethrow;
    }
  }

  Future<void> updateTypingStatus(
      String chatId, String userId, bool isTyping) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'typingUsers': isTyping
            ? FieldValue.arrayUnion([userId])
            : FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Error updating typing status: $e');
      rethrow;
    }
  }

  Future<void> updateOnlineStatus(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating online status: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      final batch = _firestore.batch();

      // Delete message
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);
      batch.delete(messageRef);

      // Update chat metadata if it was the last message
      final chat = await _firestore.collection('chats').doc(chatId).get();
      if (chat.exists) {
        final lastMessageId = chat.get('lastMessageId') as String?;
        if (lastMessageId == messageId) {
          // Get the previous message
          final previousMessage = await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          if (previousMessage.docs.isNotEmpty) {
            final prevMsg = previousMessage.docs.first;
            batch.update(_firestore.collection('chats').doc(chatId), {
              'lastMessage': prevMsg.get('text'),
              'lastMessageTime': prevMsg.get('timestamp'),
              'lastMessageSenderId': prevMsg.get('senderId'),
              'lastMessageId': prevMsg.id,
            });
          } else {
            // No messages left
            batch.update(_firestore.collection('chats').doc(chatId), {
              'lastMessage': null,
              'lastMessageTime': null,
              'lastMessageSenderId': null,
              'lastMessageId': null,
            });
          }
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  Future<void> createChat(List<String> participants) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Add current user to participants if not already included
      if (!participants.contains(currentUser.uid)) {
        participants.add(currentUser.uid);
      }

      await _firestore.collection('chats').add({
        'participants': participants,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
        'typingUsers': [],
        'unreadCount': 0,
      });
    } catch (e) {
      print('Error creating chat: $e');
      rethrow;
    }
  }
}
