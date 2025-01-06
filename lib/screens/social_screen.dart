import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mood_diary/screens/story/create_story_screen.dart';
import '../coordinators/social_coordinator.dart';
import '../widgets/social/animated_gradient_box.dart';
import '../widgets/social/story_avatar.dart';
import '../widgets/social/social_card.dart';
import '../widgets/social/loading_overlay.dart';
import 'story/story_screen.dart'; // Add this line

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarBackground = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToCreateStory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateStoryScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _navigateToStory(String userId, String userName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => StoryScreen(
          userId: userId,
          userName: userName,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _onScroll() {
    final showBackground = _scrollController.offset > 50;
    if (showBackground != _showAppBarBackground) {
      setState(() => _showAppBarBackground = showBackground);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            // Banner and tabs section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Social',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: IconButton(
                              icon:
                                  const Icon(Icons.person, color: Colors.white),
                              onPressed: _navigateToProfile,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          StoryAvatar(
                            name: 'Add Story',
                            isAdd: true,
                            size: 60,
                            onTap: _navigateToCreateStory, // Update this
                          ),
                          ...List.generate(
                            5,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: StoryAvatar(
                                name: 'User ${index + 1}',
                                hasStory: index % 2 == 0,
                                size: 60,
                                onTap: () => _navigateToStory(
                                  // Update this
                                  'user$index',
                                  'User ${index + 1}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ...List.generate(
                            5,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: StoryAvatar(
                                name: 'User ${index + 1}',
                                hasStory: index % 2 == 0,
                                size: 60,
                                onTap: () {
                                  // TODO: View story
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        tabs: const [
                          Tab(text: 'Feed'),
                          Tab(text: 'Events'),
                          Tab(text: 'Chats'),
                          Tab(text: 'Groups'),
                        ],
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        splashBorderRadius: BorderRadius.circular(12),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tab content
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFeedTab(),
                    _buildEventsTab(),
                    _buildChatsTab(),
                    _buildGroupsTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
    ];

    return AnimatedGradientBox(
      colors: colors,
      child: FloatingActionButton(
        onPressed: () => SocialCoordinator.showCreateOptions(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      systemOverlayStyle: _showAppBarBackground
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      backgroundColor: _showAppBarBackground
          ? Theme.of(context).colorScheme.surface
          : Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Social',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: IconButton(
                          icon: const Icon(Icons.person, color: Colors.white),
                          onPressed: () {
                            // TODO: Navigate to profile
                          },
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          StoryAvatar(
                            name: 'Add Story',
                            isAdd: true,
                            size: 60,
                            onTap: () {
                              // TODO: Create story
                            },
                          ),
                          const SizedBox(width: 16),
                          ...List.generate(
                            5,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: StoryAvatar(
                                name: 'User ${index + 1}',
                                hasStory: index % 2 == 0,
                                size: 60,
                                onTap: () {
                                  // TODO: View story
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            tabs: const [
              Tab(text: 'Feed'),
              Tab(text: 'Events'),
              Tab(text: 'Chats'),
              Tab(text: 'Groups'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashBorderRadius: BorderRadius.circular(12),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    if (_isLoading) return _buildLoadingShimmer();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) => _buildPostCard(index),
    );
  }

  Widget _buildPostCard(int index) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SocialCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text('U${index + 1}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User ${index + 1}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '2 hours ago',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      // TODO: Show post options
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'This is a sample post content with some thoughts and feelings...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (index % 3 == 0) ...[
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInteractionButton(
                    icon: Icons.favorite_border,
                    label: '24',
                    onPressed: () {},
                  ),
                  _buildInteractionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '8',
                    onPressed: () {},
                  ),
                  _buildInteractionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildEventsTab() {
    if (_isLoading) return _buildLoadingShimmer();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildEventCard(index),
    );
  }

  Widget _buildEventCard(int index) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SocialCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.event,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Community Event ${index + 1}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _buildEventDetail(
                icon: Icons.calendar_today,
                text: 'Tomorrow at 2:00 PM',
              ),
              const SizedBox(height: 4),
              _buildEventDetail(
                icon: Icons.location_on,
                text: 'Community Center',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check),
                      label: const Text('Join'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildEventDetail({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildChatsTab() {
    if (_isLoading) return _buildLoadingShimmer();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) => _buildChatCard(index),
    );
  }

  Widget _buildChatCard(int index) {
    final isOnline = index % 3 == 0;

    return SocialCard(
      padding: const EdgeInsets.only(bottom: 8),
      onTap: () {
        // TODO: Navigate to chat
      },
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text('U${index + 1}'),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Last message preview...',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '2:30 PM',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    if (_isLoading) return _buildLoadingShimmer();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildGroupCard(index),
    );
  }

  Widget _buildGroupCard(int index) {
    return SocialCard(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  index % 2 == 0 ? Icons.groups : Icons.psychology,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Group ${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${(index + 1) * 123} members',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {},
                child: const Text('Join'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Latest activity: Someone posted a new message',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '2h ago',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => SocialCard(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPostActions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Save Post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement save post
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share post
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement report post
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await _loadInitialData();
  }

  void _navigateToProfile() {
    // TODO: Implement profile navigation
  }

  void _navigateToNotifications() {
    // TODO: Implement notifications navigation
  }

  void _navigateToSettings() {
    // TODO: Implement settings navigation
  }
}
