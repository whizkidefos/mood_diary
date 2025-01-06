import 'package:flutter/material.dart';
import 'package:mood_diary/widgets/social/story_avatar.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                StoryAvatar(
                  imageUrl: 'https://picsum.photos/200',
                  name: 'John Doe',
                  hasStory: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryViewScreen(
                          imageUrl: 'https://picsum.photos/200',
                          name: 'John Doe',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                StoryAvatar(
                  imageUrl: 'https://picsum.photos/201',
                  name: 'Jane Doe',
                  hasStory: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryViewScreen(
                          imageUrl: 'https://picsum.photos/201',
                          name: 'Jane Doe',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                StoryAvatar(
                  imageUrl: 'https://picsum.photos/202',
                  name: 'Alice',
                  hasStory: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryViewScreen(
                          imageUrl: 'https://picsum.photos/202',
                          name: 'Alice',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                StoryAvatar(
                  imageUrl: 'https://picsum.photos/203',
                  name: 'Bob',
                  hasStory: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryViewScreen(
                          imageUrl: 'https://picsum.photos/203',
                          name: 'Bob',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
