import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood_diary/widgets/social/story_avatar.dart';
import 'create_story_screen.dart';
import 'story_view_screen.dart';

class StoryScreen extends StatefulWidget {
  final String? userId;
  final String? storyId;
  
  const StoryScreen({
    super.key,
    this.userId,
    this.storyId,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateStoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('stories')
            .where('userId', isEqualTo: widget.userId ?? _auth.currentUser?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final stories = snapshot.data?.docs ?? [];
          if (stories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No stories yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateStoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Story'),
                  ),
                ],
              ),
            );
          }

          // Group stories by user
          final storiesByUser = <String, List<QueryDocumentSnapshot>>{};
          for (final story in stories) {
            final userId = story.get('userId') as String;
            storiesByUser.putIfAbsent(userId, () => []).add(story);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: storiesByUser.length,
            itemBuilder: (context, index) {
              final userId = storiesByUser.keys.elementAt(index);
              final userStories = storiesByUser[userId]!;
              final latestStory = userStories.first;

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                  final username = userData?['username'] as String? ?? 'Unknown';
                  final photoUrl = userData?['photoUrl'] as String?;
                  final hasUnseenStory = userStories.any((story) {
                    final storyData = story.data() as Map<String, dynamic>?;
                    final views = List<String>.from(storyData?['views'] as List? ?? []);
                    return !views.contains(_auth.currentUser?.uid);
                  });

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: StoryAvatar(
                      imageUrl: photoUrl,
                      name: username,
                      hasStory: hasUnseenStory,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryViewScreen(
                              storyId: latestStory.id,
                              userId: userId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
