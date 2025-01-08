import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BackupService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> createBackup(String chatId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get all messages from the chat
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      // Create backup data
      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'chatId': chatId,
        'messages': messages.docs.map((doc) => doc.data()).toList(),
      };

      // Convert to JSON and encode
      final jsonData = jsonEncode(backupData);
      final bytes = utf8.encode(jsonData);

      // Generate backup filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupPath = 'backups/$userId/$chatId/backup_$timestamp.json';

      // Upload to Firebase Storage
      await _storage.ref(backupPath).putData(
            bytes,
            SettableMetadata(contentType: 'application/json'),
          );

      // Add backup reference to Firestore
      await _firestore.collection('backups').add({
        'userId': userId,
        'chatId': chatId,
        'timestamp': FieldValue.serverTimestamp(),
        'path': backupPath,
        'messageCount': messages.size,
      });
    } catch (e) {
      print('Error creating backup: $e');
      rethrow;
    }
  }

  Future<List<String>> listBackups(String chatId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final backups = await _firestore
          .collection('backups')
          .where('userId', isEqualTo: userId)
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: true)
          .get();

      return backups.docs.map((doc) => doc.get('path') as String).toList();
    } catch (e) {
      print('Error listing backups: $e');
      rethrow;
    }
  }

  Future<void> restoreBackup(String backupPath) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Download backup file
      final data = await _storage.ref(backupPath).getData();
      if (data == null) throw Exception('Backup file not found');

      // Parse backup data
      final jsonString = utf8.decode(data);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      final chatId = backupData['chatId'] as String;
      final messages = List<Map<String, dynamic>>.from(
          backupData['messages'] as List<dynamic>);

      // Start a batch write
      var batch = _firestore.batch();
      var messageCount = 0;

      // Delete existing messages
      final existingMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      
      for (var doc in existingMessages.docs) {
        batch.delete(doc.reference);
        messageCount++;
        
        // Commit batch every 500 operations
        if (messageCount >= 500) {
          await batch.commit();
          batch = _firestore.batch();
          messageCount = 0;
        }
      }

      // Commit any remaining deletes
      if (messageCount > 0) {
        await batch.commit();
        batch = _firestore.batch();
        messageCount = 0;
      }

      // Restore messages from backup
      for (var message in messages) {
        final ref = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc();
        
        batch.set(ref, message);
        messageCount++;

        // Commit batch every 500 operations
        if (messageCount >= 500) {
          await batch.commit();
          batch = _firestore.batch();
          messageCount = 0;
        }
      }

      // Commit any remaining messages
      if (messageCount > 0) {
        await batch.commit();
      }

      // Update chat metadata
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': lastMessage['text'],
          'lastMessageTime': lastMessage['timestamp'],
          'lastMessageSenderId': lastMessage['senderId'],
        });
      }
    } catch (e) {
      print('Error restoring backup: $e');
      rethrow;
    }
  }

  Future<void> deleteBackup(String backupPath) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Delete from Storage
      await _storage.ref(backupPath).delete();

      // Delete from Firestore
      final backup = await _firestore
          .collection('backups')
          .where('path', isEqualTo: backupPath)
          .limit(1)
          .get();

      if (backup.docs.isNotEmpty) {
        await backup.docs.first.reference.delete();
      }
    } catch (e) {
      print('Error deleting backup: $e');
      rethrow;
    }
  }
}
