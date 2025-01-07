import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mood_diary/services/forward_service.dart';

class ForwardDialog extends StatefulWidget {
  final String messageId;
  final String sourceChatId;

  const ForwardDialog({
    super.key,
    required this.messageId,
    required this.sourceChatId,
  });

  @override
  State<ForwardDialog> createState() => _ForwardDialogState();
}

class _ForwardDialogState extends State<ForwardDialog> {
  final _forwardService = ForwardService();
  final Set<String> _selectedChats = {};
  bool _isLoading = true;
  List<DocumentSnapshot>? _chats;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        _chats = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading chats')),
        );
      }
    }
  }

  Future<void> _forwardMessage() async {
    if (_selectedChats.isEmpty) return;

    try {
      await _forwardService.forwardMessage(
        messageId: widget.messageId,
        sourceChatId: widget.sourceChatId,
        targetChatIds: _selectedChats.toList(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message forwarded')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error forwarding message')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forward to...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_chats == null || _chats!.isEmpty)
              const Center(child: Text('No chats found'))
            else
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _chats!.length,
                  itemBuilder: (context, index) {
                    final chat = _chats![index];
                    return CheckboxListTile(
                      title: Text(chat['name'] ?? 'Chat ${index + 1}'),
                      value: _selectedChats.contains(chat.id),
                      onChanged: (selected) {
                        setState(() {
                          if (selected ?? false) {
                            _selectedChats.add(chat.id);
                          } else {
                            _selectedChats.remove(chat.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _selectedChats.isEmpty ? null : _forwardMessage,
                  child: const Text('Forward'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
