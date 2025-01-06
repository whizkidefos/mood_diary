import 'package:flutter/material.dart';
import '../screens/create/create_post_screen.dart';
import '../screens/create/create_event_screen.dart';
import '../screens/create/create_group_screen.dart';
import '../screens/create/create_poll_screen.dart';

class SocialCoordinator {
  static void showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateOptionsBottomSheet(),
    );
  }

  static void navigateToCreatePost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  static void navigateToCreateEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEventScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  static void navigateToCreateGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  static void navigateToCreatePoll(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePollScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}

class _CreateOptionsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _CreateOptionTile(
                    title: 'Post',
                    subtitle: 'Share your thoughts',
                    icon: Icons.post_add_rounded,
                    gradient: const [Colors.blue, Colors.lightBlue],
                    onTap: () {
                      Navigator.pop(context);
                      SocialCoordinator.navigateToCreatePost(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  _CreateOptionTile(
                    title: 'Event',
                    subtitle: 'Organize a gathering',
                    icon: Icons.event_rounded,
                    gradient: const [Colors.orange, Colors.amber],
                    onTap: () {
                      Navigator.pop(context);
                      SocialCoordinator.navigateToCreateEvent(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  _CreateOptionTile(
                    title: 'Group',
                    subtitle: 'Build a community',
                    icon: Icons.group_add_rounded,
                    gradient: const [Colors.purple, Colors.deepPurple],
                    onTap: () {
                      Navigator.pop(context);
                      SocialCoordinator.navigateToCreateGroup(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  _CreateOptionTile(
                    title: 'Poll',
                    subtitle: 'Ask the community',
                    icon: Icons.poll_rounded,
                    gradient: const [Colors.green, Colors.teal],
                    onTap: () {
                      Navigator.pop(context);
                      SocialCoordinator.navigateToCreatePoll(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _CreateOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
