import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/social/story_avatar.dart';
import '../story/create_story_screen.dart';
import '../story/story_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
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
      body: Column(
        children: [
          // Stories Section
          Container(
            height: 100,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('stories').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stories = snapshot.data?.docs ?? [];

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: stories.length + 1, // +1 for current user's story
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Current user's story/add story button
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: StoryAvatar(
                          name: 'Your Story',
                          isAdd: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateStoryScreen(),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    final story = stories[index - 1].data() as Map<String, dynamic>;
                    final userId = stories[index - 1].get('userId') as String;

                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('users').doc(userId).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                        final username = userData?['username'] as String? ?? 'Unknown';
                        final photoUrl = userData?['photoUrl'] as String?;

                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: StoryAvatar(
                            imageUrl: photoUrl,
                            name: username,
                            hasStory: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoryScreen(
                                    storyId: stories[index - 1].id,
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
          ),

          // Social Feed
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data?.docs ?? [];

                if (posts.isEmpty) {
                  return const Center(
                    child: Text('No posts yet. Be the first to share!'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    final userId = post['userId'] as String;

                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('users').doc(userId).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                        final username = userData?['username'] as String? ?? 'Unknown';
                        final photoUrl = userData?['photoUrl'] as String?;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: photoUrl != null
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: photoUrl == null
                                      ? Text(username[0].toUpperCase())
                                      : null,
                                ),
                                title: Text(username),
                                subtitle: Text(
                                  _formatTimestamp(post['timestamp'] as Timestamp),
                                ),
                              ),
                              if (post['imageUrl'] != null)
                                Image.network(
                                  post['imageUrl'] as String,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(post['text'] as String? ?? ''),
                              ),
                              OverflowBar(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.favorite_border),
                                    onPressed: () {
                                      // TODO: Implement like functionality
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.comment),
                                    onPressed: () {
                                      // TODO: Implement comment functionality
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () {
                                      // TODO: Implement share functionality
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
