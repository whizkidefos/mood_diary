import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _messaging = FirebaseMessaging.instance;
  final _notifications = FlutterLocalNotificationsPlugin();

  // Authentication methods
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in: $e');
      }
      rethrow;
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user: $e');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      rethrow;
    }
  }

  // User profile methods
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      if (additionalData != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update(additionalData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      rethrow;
    }
  }

  // Storage methods
  Future<String> uploadFile(String path, List<int> bytes) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      final ref = _storage.ref().child(path);
      await ref.putData(Uint8List.fromList(bytes));
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      rethrow;
    }
  }

  // Firestore methods
  Future<void> setData(
      String collection, String document, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(document).set(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting data: $e');
      }
      rethrow;
    }
  }

  Future<void> updateData(
      String collection, String document, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(document).update(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating data: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteDocument(String collection, String document) async {
    try {
      await _firestore.collection(collection).doc(document).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting document: $e');
      }
      rethrow;
    }
  }

  Stream<DocumentSnapshot> streamDocument(String collection, String document) {
    return _firestore.collection(collection).doc(document).snapshots();
  }

  Stream<QuerySnapshot> streamCollection(String collection,
      {Query Function(Query)? queryBuilder}) {
    Query query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  // Notification methods
  Future<void> initializeNotifications() async {
    try {
      await _messaging.requestPermission();
      final token = await _messaging.getToken();

      if (token != null) {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'fcmToken': token,
          });
        }
      }

      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _notifications.initialize(initializationSettings);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
      rethrow;
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'mood_diary_channel',
        'Mood Diary Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const iOSDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notifications.show(
        DateTime.now().millisecond,
        message.notification?.title ?? 'New Message',
        message.notification?.body,
        details,
        payload: message.data['route'],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing notification: $e');
      }
      rethrow;
    }
  }

  // Analytics methods
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    try {
      await _firestore.collection('analytics').add({
        'event': name,
        'parameters': parameters,
        'userId': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error logging event: $e');
      }
      rethrow;
    }
  }

  // Error reporting
  Future<void> logError(dynamic error, StackTrace stackTrace) async {
    try {
      await _firestore.collection('errors').add({
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
        'userId': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error logging error: $e');
      }
      rethrow;
    }
  }
}
