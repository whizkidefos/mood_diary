import 'package:flutter/material.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/animated_background.dart';

class CommunityDetails extends StatefulWidget {
  final Map<String, dynamic> community;

  const CommunityDetails({
    super.key,
    required this.community,
  });

  @override
  State<CommunityDetails> createState() => _CommunityDetailsState();
}

class _CommunityDetailsState extends State<CommunityDetails> {
  bool _isJoined = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            color: widget.community['color'],
            opacity: 0.1,
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar.large(
                expandedHeight: 200,
                pinned: true,
                title: Text(widget.community['name']),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: Implement share
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          widget.community['color'],
                          widget.community['color'].withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        widget.community['icon'],
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _isLoading
                    ? _buildLoadingContent()
                    : _buildCommunityContent(),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() => _isJoined = !_isJoined);
        },
        icon: Icon(_isJoined ? Icons.check : Icons.add),
        label: Text(_isJoined ? 'Joined' : 'Join Community'),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          4,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: ShimmerLoading(height: 100),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'About',
            content: widget.community['description'],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Members',
            content: '${widget.community['members']} members',
            trailing: '12 online',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Guidelines',
            content: '• Be respectful and supportive\n'
                '• Share your experiences\n'
                '• Maintain privacy\n'
                '• No harassment or bullying',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Recent Activity',
            content: 'Join the conversation to see recent posts',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    String? trailing,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: widget.community['color'],
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (trailing != null)
                  Text(
                    trailing,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
