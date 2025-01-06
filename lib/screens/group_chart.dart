import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class GroupChat extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChat({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, AnimationController> _typingIndicators = {};
  bool _isTyping = false;
  Timer? _typingTimer;
  StreamSubscription? _typingSubscription;

  @override
  void initState() {
    super.initState();
    _setupTypingListener();
  }

  void _setupTypingListener() {
    _typingSubscription = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('typing')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        final userId = change.doc.id;
        if (change.type == DocumentChangeType.removed) {
          _typingIndicators[userId]?.dispose();
          _typingIndicators.remove(userId);
        } else if (!_typingIndicators.containsKey(userId)) {
          _typingIndicators[userId] = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 500),
          )..repeat(reverse: true);
        }
      }
      setState(() {});
    });
  }

  void _updateTypingStatus(bool isTyping) {
    if (_isTyping != isTyping) {
      _isTyping = isTyping;
      FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('typing')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _typingTimer?.cancel();
      if (isTyping) {
        _typingTimer = Timer(const Duration(seconds: 5), () {
          _updateTypingStatus(false);
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'text': _messageController.text,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    };

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .add(message);

      _messageController.clear();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _typingSubscription?.cancel();
    for (var controller in _typingIndicators.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.groupName),
            if (_typingIndicators.isNotEmpty)
              Text(
                'Someone is typing...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show group info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = message['userId'] ==
                        FirebaseAuth.instance.currentUser?.uid;

                    return _MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      // TODO: Implement file attachment
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (text) {
                        _updateTypingStatus(text.isNotEmpty);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message['text'] as String,
              style: TextStyle(
                color: isMe
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              _formatTime(message['timestamp'] as Timestamp),
              style: TextStyle(
                fontSize: 12,
                color: isMe
                    ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                    : Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
