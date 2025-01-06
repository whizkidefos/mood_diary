import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageSyncService {
  final _firestore = FirebaseFirestore.instance;
  final _prefs = SharedPreferences.getInstance();

  Future<void> syncMessages(String chatId) async {
    final prefs = await _prefs;
    final lastSync = prefs.getString('last_sync_$chatId');

    Query query = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    if (lastSync != null) {
      query = query.where('timestamp', isGreaterThan: lastSync);
    }

    final messages = await query.get();

    // Process new messages
    for (final doc in messages.docs) {
      final message = doc.data();
      // Handle message locally
    }

    // Update last sync time
    await prefs.setString(
      'last_sync_$chatId',
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> handleOfflineMessages() async {
    final prefs = await _prefs;
    final pendingMessages = prefs.getStringList('pending_messages') ?? [];

    for (final messageJson in pendingMessages) {
      final message = jsonDecode(messageJson);
      await _firestore
          .collection('chats')
          .doc(message['chatId'])
          .collection('messages')
          .add(message);
    }

    await prefs.remove('pending_messages');
  }

  Future<void> savePendingMessage(Map<String, dynamic> message) async {
    final prefs = await _prefs;
    final pendingMessages = prefs.getStringList('pending_messages') ?? [];

    pendingMessages.add(jsonEncode(message));
    await prefs.setStringList('pending_messages', pendingMessages);
  }
}
