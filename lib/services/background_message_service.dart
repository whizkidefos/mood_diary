import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mood_diary/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _handleBackgroundMessage(message);
}

Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  final prefs = await SharedPreferences.getInstance();
  final messagesJson = prefs.getStringList('background_messages') ?? [];

  messagesJson.add(jsonEncode({
    'messageId': message.messageId,
    'data': message.data,
    'timestamp': DateTime.now().toIso8601String(),
  }));

  await prefs.setStringList('background_messages', messagesJson);
}

class BackgroundMessageService {
  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _processBackgroundMessages();
  }

  static Future<void> _processBackgroundMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('background_messages') ?? [];

    if (messagesJson.isEmpty) return;

    for (final messageJson in messagesJson) {
      final message = jsonDecode(messageJson);
      await _processMessage(message);
    }

    await prefs.remove('background_messages');
  }

  static Future<void> _processMessage(Map<String, dynamic> message) async {
    // Handle message based on type
    switch (message['type']) {
      case 'message':
        await NotificationService.showNotification(
          title: message['sender_name'],
          body: message['text'],
          payload: jsonEncode({
            'type': 'chat',
            'chatId': message['chat_id'],
          }),
        );
        break;
      case 'call':
        await NotificationService.showNotification(
          title: 'Missed Call',
          body: '${message['caller_name']} tried to call you',
          payload: jsonEncode({
            'type': 'call_log',
            'callId': message['call_id'],
          }),
        );
        break;
    }
  }
}
