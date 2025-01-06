import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _guidelinesController = TextEditingController();
  bool _isPrivate = false;
  final List<String> _selectedTags = [];
  bool _requiresApproval = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _guidelinesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [
          TextButton(
            onPressed: _createGroup,
            child: const Text('Create'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildGroupAvatar(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a group name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'What is this group about?',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildPrivacySection(),
            const SizedBox(height: 16),
            _buildTagsSection(),
            const SizedBox(height: 16),
            _buildGuidelinesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupAvatar() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group,
              size: 48,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
                onPressed: () {
                  // TODO: Implement image picker
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Private Group'),
              subtitle: Text(
                'Only members can see the content',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _isPrivate,
              onChanged: (value) => setState(() => _isPrivate = value),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Requires Approval'),
              subtitle: Text(
                'Admins must approve join requests',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _requiresApproval,
              onChanged: (value) => setState(() => _requiresApproval = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    final availableTags = [
      'Support',
      'Social',
      'Health',
      'Fitness',
      'Meditation',
      'Discussion',
      'Learning',
      'Hobbies'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group Tags',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGuidelinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Guidelines',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _guidelinesController,
          decoration: const InputDecoration(
            hintText: 'Add group rules and guidelines...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
      ],
    );
  }

  void _createGroup() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement group creation
      Navigator.pop(context);
    }
  }
}
