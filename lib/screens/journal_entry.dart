import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry extends StatefulWidget {
  final String prompt;

  const JournalEntry({
    super.key,
    required this.prompt,
  });

  @override
  State<JournalEntry> createState() => _JournalEntryState();
}

class _JournalEntryState extends State<JournalEntry> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveEntry() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before saving')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('journal_entries').add({
        'prompt': widget.prompt,
        'content': _controller.text,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveEntry,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                const Icon(Icons.lightbulb),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.prompt,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _isSaving ? null : _saveEntry,
          child: _isSaving
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Saving...'),
                  ],
                )
              : const Text('Save Entry'),
        ),
      ),
    );
  }
}
