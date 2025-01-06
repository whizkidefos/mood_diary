import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/social_models.dart';

class SocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Profile Methods
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      return UserProfile.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .update(profile.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Community Posts Methods
  Stream<List<CommunityPost>> getCommunityPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityPost.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<void> createPost(CommunityPost post) async {
    try {
      await _firestore.collection('posts').add(post.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([comment.toMap()])
      });
    } catch (e) {
      rethrow;
    }
  }

  // Community Methods
  Stream<List<Map<String, dynamic>>> getCommunities() {
    return _firestore.collection('communities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {...doc.data(), 'id': doc.id};
      }).toList();
    });
  }

  Future<void> joinCommunity(String communityId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('communities').doc(communityId).update({
        'members': FieldValue.arrayUnion([userId])
      });

      await _firestore.collection('users').doc(userId).update({
        'communities': FieldValue.arrayUnion([communityId])
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('communities').doc(communityId).update({
        'members': FieldValue.arrayRemove([userId])
      });

      await _firestore.collection('users').doc(userId).update({
        'communities': FieldValue.arrayRemove([communityId])
      });
    } catch (e) {
      rethrow;
    }
  }

  // Chat Methods
  Stream<List<Map<String, dynamic>>> getChats() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {...doc.data(), 'id': doc.id};
      }).toList();
    });
  }

  Future<void> sendMessage(String chatId, Map<String, dynamic> message) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'messages': FieldValue.arrayUnion([message])
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createChat(String otherUserId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final chatDoc = await _firestore.collection('chats').add({
        'participants': [userId, otherUserId],
        'messages': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      return chatDoc.id;
    } catch (e) {
      rethrow;
    }
  }
}
