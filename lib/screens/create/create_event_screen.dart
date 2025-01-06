import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 2));
  final List<String> _selectedTags = [];
  bool _isOnline = false;
  int _maxAttendees = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartTime ? _startDate : _endDate,
        ),
      );

      if (time != null) {
        setState(() {
          if (isStartTime) {
            _startDate = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
            // Ensure end date is after start date
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 2));
            }
          } else {
            _endDate = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: [
          TextButton(
            onPressed: _createEvent,
            child: const Text('Create'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter an event title';
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
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildDateTimeSection(),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Online Event'),
              subtitle: Text(
                'Event will be held virtually',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _isOnline,
              onChanged: (value) => setState(() => _isOnline = value),
            ),
            if (!_isOnline) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildAttendeesSection(),
            const SizedBox(height: 16),
            _buildTagsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: IconButton(
            icon: const Icon(Icons.add_photo_alternate, size: 48),
            onPressed: () {
              // TODO: Implement image picker
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeButton(
                label: 'Start',
                dateTime: _startDate,
                onPressed: () => _selectDateTime(true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateTimeButton(
                label: 'End',
                dateTime: _endDate,
                onPressed: () => _selectDateTime(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeButton({
    required String label,
    required DateTime dateTime,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(label),
            const SizedBox(height: 4),
            Text(
              '${dateTime.day}/${dateTime.month}/${dateTime.year}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Attendees',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _maxAttendees > 0
                  ? () => setState(() => _maxAttendees--)
                  : null,
            ),
            Expanded(
              child: Text(
                _maxAttendees == 0 ? 'Unlimited' : _maxAttendees.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => setState(() => _maxAttendees++),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    final availableTags = [
      'Workshop',
      'Meetup',
      'Social',
      'Support',
      'Exercise',
      'Meditation',
      'Discussion',
      'Other'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Tags',
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

  void _createEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement event creation
      Navigator.pop(context);
    }
  }
}
