import 'package:flutter/material.dart';
import 'package:mood_diary/services/scheduled_messages.dart';

class ScheduleMessageDialog extends StatefulWidget {
  final String chatId;
  final List<String>? mediaUrls;

  const ScheduleMessageDialog({
    super.key,
    required this.chatId,
    this.mediaUrls,
  });

  @override
  State<ScheduleMessageDialog> createState() => _ScheduleMessageDialogState();
}

class _ScheduleMessageDialogState extends State<ScheduleMessageDialog> {
  final _messageController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _scheduledMessageService = ScheduledMessageService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Message'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_formatDate(_selectedDate)),
                  onPressed: _selectDate,
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(_selectedTime.format(context)),
                  onPressed: _selectTime,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _scheduleMessage,
          child: const Text('Schedule'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _scheduleMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final scheduledTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (scheduledTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future time'),
        ),
      );
      return;
    }

    await _scheduledMessageService.scheduleMessage(
      chatId: widget.chatId,
      message: _messageController.text,
      scheduledTime: scheduledTime,
      mediaUrls: widget.mediaUrls,
    );

    if (mounted) Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
