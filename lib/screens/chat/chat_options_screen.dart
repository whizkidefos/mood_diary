import 'package:flutter/material.dart';

class ChatOptionsScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatOptionsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ChatOptionsScreen> createState() => _ChatOptionsScreenState();
}

class _ChatOptionsScreenState extends State<ChatOptionsScreen> {
  bool _notifications = true;
  bool _mediaVisibility = true;
  String _wallpaper = 'Default';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Settings'),
      ),
      body: ListView(
        children: [
          _buildUserInfo(),
          const Divider(),
          _buildSettingsSection(),
          const Divider(),
          _buildMediaSection(),
          const Divider(),
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Hero(
            tag: 'profile-${widget.userId}',
            child: CircleAvatar(
              radius: 30,
              child: Text(widget.userName[0]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'online',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SwitchListTile(
          title: const Text('Notifications'),
          subtitle: const Text('Show notifications for new messages'),
          value: _notifications,
          onChanged: (value) => setState(() => _notifications = value),
        ),
        ListTile(
          title: const Text('Chat Wallpaper'),
          subtitle: Text(_wallpaper),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showWallpaperOptions,
        ),
        SwitchListTile(
          title: const Text('Media Visibility'),
          subtitle: const Text('Show media in device gallery'),
          value: _mediaVisibility,
          onChanged: (value) => setState(() => _mediaVisibility = value),
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    final mediaTypes = [
      {'icon': Icons.image, 'label': 'Photos & Videos', 'count': '23'},
      {'icon': Icons.link, 'label': 'Links', 'count': '7'},
      {'icon': Icons.file_copy, 'label': 'Documents', 'count': '4'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Shared Media',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...mediaTypes.map((type) => ListTile(
              leading: Icon(type['icon'] as IconData),
              title: Text(type['label'] as String),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(type['count'] as String),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                // TODO: Navigate to media gallery
              },
            )),
      ],
    );
  }

  Widget _buildActionsSection() {
    final actions = [
      {
        'icon': Icons.block,
        'label': 'Block User',
        'color': Colors.red,
        'onTap': _blockUser,
      },
      {
        'icon': Icons.report,
        'label': 'Report User',
        'color': Colors.orange,
        'onTap': _reportUser,
      },
      {
        'icon': Icons.delete_forever,
        'label': 'Clear Chat',
        'color': Colors.grey,
        'onTap': _clearChat,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Actions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...actions.map((action) => ListTile(
              leading: Icon(
                action['icon'] as IconData,
                color: action['color'] as Color,
              ),
              title: Text(
                action['label'] as String,
                style: TextStyle(
                  color: action['color'] as Color,
                ),
              ),
              onTap: action['onTap'] as VoidCallback,
            )),
      ],
    );
  }

  void _showWallpaperOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wallpaper),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement wallpaper picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_color_fill),
              title: const Text('Solid Color'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement color picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset to Default'),
              onTap: () {
                setState(() => _wallpaper = 'Default');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _blockUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${widget.userName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement block user
              Navigator.pop(context);
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _reportUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you reporting ${widget.userName}?'),
            const SizedBox(height: 16),
            ...['Spam', 'Inappropriate content', 'Harassment', 'Other']
                .map((reason) => ListTile(
                      title: Text(reason),
                      onTap: () {
                        // TODO: Implement report user
                        Navigator.pop(context);
                      },
                    )),
          ],
        ),
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to delete all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement clear chat
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
