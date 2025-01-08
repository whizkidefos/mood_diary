import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoryViewScreen extends StatefulWidget {
  final String storyId;
  final String userId;

  const StoryViewScreen({
    super.key,
    required this.storyId,
    required this.userId,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen>
    with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late AnimationController _progressController;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pop(context);
        }
      });

    _progressController.forward();
    _markStoryAsViewed();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _markStoryAsViewed() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('stories').doc(widget.storyId).update({
        'views': FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      print('Error marking story as viewed: $e');
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _progressController.stop();
      } else {
        _progressController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _togglePause(),
        onTapUp: (_) => _togglePause(),
        onVerticalDragEnd: (_) => Navigator.pop(context),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('stories').doc(widget.storyId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Error loading story',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final story = snapshot.data!.data() as Map<String, dynamic>?;
            if (story == null) {
              return const Center(
                child: Text(
                  'Story not found',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                // Progress bar
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 12,
                  right: 12,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: Colors.grey[800],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      );
                    },
                  ),
                ),

                // Story content
                Positioned.fill(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                      left: 20,
                      right: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(story['backgroundColor'] as int),
                          Color(story['backgroundColor'] as int)
                              .withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        story['text'] as String? ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: story['fontSize'] as double? ?? 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                // Header with user info
                Positioned(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 12,
                  right: 12,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection('users')
                        .doc(widget.userId)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final userData =
                          userSnapshot.data?.data() as Map<String, dynamic>?;
                      final username =
                          userData?['username'] as String? ?? 'Unknown';
                      final photoUrl = userData?['photoUrl'] as String?;

                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: photoUrl != null
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl == null
                                ? Text(username[0].toUpperCase())
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTimestamp(
                                story['timestamp'] as Timestamp),
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Close button
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}
