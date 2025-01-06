import 'package:flutter/material.dart';
import '../models/social_event_models.dart';

class EventCard extends StatelessWidget {
  final GroupEvent event;
  final Function(AttendanceStatus) onAttendanceChanged;

  const EventCard({
    super.key,
    required this.event,
    required this.onAttendanceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.imageUrl != null)
            Image.network(
              event.imageUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(event.startTime),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.location,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(event.description),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: event.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${event.attendees.length} attending',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    _buildAttendanceButtons(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButtons(BuildContext context) {
    return SegmentedButton<AttendanceStatus>(
      segments: const [
        ButtonSegment(
          value: AttendanceStatus.attending,
          icon: Icon(Icons.check),
          label: Text('Going'),
        ),
        ButtonSegment(
          value: AttendanceStatus.maybe,
          icon: Icon(Icons.help_outline),
          label: Text('Maybe'),
        ),
        ButtonSegment(
          value: AttendanceStatus.notAttending,
          icon: Icon(Icons.close),
          label: Text('No'),
        ),
      ],
      selected: {_getCurrentStatus()},
      onSelectionChanged: (Set<AttendanceStatus> selected) {
        onAttendanceChanged(selected.first);
      },
    );
  }

  final String currentUserId = 'currentUserId'; // Replace with actual user ID

  AttendanceStatus _getCurrentStatus() {
    if (event.attendees.contains(currentUserId)) {
      return AttendanceStatus.attending;
    } else if (event.maybeAttending.contains(currentUserId)) {
      return AttendanceStatus.maybe;
    } else if (event.notAttending.contains(currentUserId)) {
      return AttendanceStatus.notAttending;
    }
    return AttendanceStatus.notResponded;
  }

  String _formatDateTime(DateTime dateTime) {
    // Implement your date formatting logic here
    return '${dateTime.day}/${dateTime.month} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

enum AttendanceStatus {
  attending,
  maybe,
  notAttending,
  notResponded,
}

// Calendar widget for displaying events
class EventCalendar extends StatefulWidget {
  final List<GroupEvent> events;
  final Function(DateTime) onDaySelected;

  const EventCalendar({
    super.key,
    required this.events,
    required this.onDaySelected,
  });

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  DateTime _selectedDate = DateTime.now();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _selectedDate.month - 1,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendarHeader(),
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, month) {
              final date = DateTime(
                _selectedDate.year,
                month + 1,
                1,
              );
              return _buildMonth(date);
            },
            itemCount: 12,
          ),
        ),
        const SizedBox(height: 16),
        _buildEventsList(),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        ),
        Text(
          '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMonth(DateTime monthDate) {
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final firstWeekdayOfMonth = firstDayOfMonth.weekday;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        if (index < firstWeekdayOfMonth - 1) {
          return const SizedBox();
        }

        final dayNumber = index - firstWeekdayOfMonth + 2;
        if (dayNumber > daysInMonth) {
          return const SizedBox();
        }

        final date = DateTime(monthDate.year, monthDate.month, dayNumber);
        final eventsOnDay = widget.events
            .where((event) =>
                event.startTime.year == date.year &&
                event.startTime.month == date.month &&
                event.startTime.day == date.day)
            .toList();

        final isSelected = _selectedDate.year == date.year &&
            _selectedDate.month == date.month &&
            _selectedDate.day == date.day;

        return InkWell(
          onTap: () {
            setState(() => _selectedDate = date);
            widget.onDaySelected(date);
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              borderRadius: BorderRadius.circular(8),
              border: eventsOnDay.isNotEmpty
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    dayNumber.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : null,
                      fontWeight:
                          eventsOnDay.isNotEmpty ? FontWeight.bold : null,
                    ),
                  ),
                ),
                if (eventsOnDay.isNotEmpty)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsList() {
    final eventsOnSelectedDay = widget.events
        .where((event) =>
            event.startTime.year == _selectedDate.year &&
            event.startTime.month == _selectedDate.month &&
            event.startTime.day == _selectedDate.day)
        .toList();

    if (eventsOnSelectedDay.isEmpty) {
      return Center(
        child: Text(
          'No events on this day',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Events on ${_formatDate(_selectedDate)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: eventsOnSelectedDay.length,
          itemBuilder: (context, index) {
            final event = eventsOnSelectedDay[index];
            return ListTile(
              leading: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(event.title),
              subtitle: Text(
                '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              onTap: () {
                // TODO: Navigate to event details
              },
            );
          },
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Event creation widget
class CreateEventForm extends StatefulWidget {
  final Function(GroupEvent) onEventCreated;

  const CreateEventForm({
    super.key,
    required this.onEventCreated,
  });

  @override
  State<CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  final List<String> _selectedTags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(bool isStartDate) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartDate ? _startDate : _endDate,
        ),
      );

      if (time != null) {
        setState(() {
          if (isStartDate) {
            _startDate = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
            if (_startDate.isAfter(_endDate)) {
              _endDate = _startDate.add(const Duration(hours: 1));
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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final event = GroupEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: _startDate,
        endTime: _endDate,
        location: _locationController.text,
        createdBy: 'currentUserId', // TODO: Get from auth
        attendees: ['currentUserId'],
        maybeAttending: [],
        notAttending: [],
        tags: _selectedTags,
      );

      widget.onEventCreated(event);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Event Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter a title';
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
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter a location';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(_formatDateTime(_startDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDateTime(true),
          ),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(_formatDateTime(_endDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDateTime(false),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitForm,
            child: const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
