import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../../widgets/chat/chat_input.dart';
import '../../widgets/chat/typing_indicator.dart';

class EnhancedChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const EnhancedChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
  });

  @override
  State<EnhancedChatScreen> createState() => _EnhancedChatScreenState();
}

class _EnhancedChatScreenState extends State<EnhancedChatScreen> {
  final _chatService = ChatService();
  final _auth = FirebaseAuth.instance;
  final _scrollController = ScrollController();
  String? _replyToMessage;
  String? _replyToMessageId;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markMessagesAsRead() async {
    await _chatService.markMessagesAsRead(widget.chatId);
  }

  void _handleSendMessage(String message) {
    _chatService.sendMessage(
      chatId: widget.chatId,
      text: message,
      replyToId: _replyToMessageId,
    );
    _cancelReply();
  }

  void _handleSendMedia(List<String> mediaPaths) async {
    try {
      final urls = await _chatService.uploadMediaFiles(widget.chatId, mediaPaths);
      await _chatService.sendMessage(
        chatId: widget.chatId,
        text: '📎 Media',
        mediaUrls: urls,
        replyToId: _replyToMessageId,
      );
      _cancelReply();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending media: $e')),
      );
    }
  }

  void _handleTypingStatus(bool isTyping) {
    _chatService.updateTypingStatus(
      widget.chatId,
      _auth.currentUser!.uid,
      isTyping,
    );
  }

  void _handleReply(String message, String messageId) {
    setState(() {
      _replyToMessage = message;
      _replyToMessageId = messageId;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyToMessage = null;
      _replyToMessageId = null;
    });
  }

  void _handleDelete(String messageId) async {
    try {
      await _chatService.deleteMessage(widget.chatId, messageId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.otherUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Loading...');
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final username = userData?['username'] as String? ?? 'Unknown';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username),
                StreamBuilder<bool>(
                  stream:
                      _chatService.getOnlineStatus(widget.otherUserId),
                  builder: (context, snapshot) {
                    final isOnline = snapshot.data ?? false;
                    return Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.7),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final messageId = messages[index].id;
                    final isMe =
                        message['senderId'] == _auth.currentUser?.uid;
                    final timestamp =
                        (message['timestamp'] as Timestamp).toDate();

                    return ChatBubble(
                      message: message['text'],
                      isMe: isMe,
                      timestamp: timestamp,
                      mediaUrls: List<String>.from(
                          message['mediaUrls'] ?? []),
                      replyToMessage: message['replyToMessage'],
                      onReply: () => _handleReply(
                        message['text'],
                        messageId,
                      ),
                      onDelete:
                          isMe ? () => _handleDelete(messageId) : null,
                    );
                  },
                );
              },
            ),
          ),
          StreamBuilder<bool>(
            stream: _chatService.getTypingStatus(
              widget.chatId,
              widget.otherUserId,
            ),
            builder: (context, snapshot) {
              return TypingIndicator(
                isTyping: snapshot.data ?? false,
              );
            },
          ),
          ChatInput(
            onSendMessage: _handleSendMessage,
            onSendMedia: _handleSendMedia,
            onTypingStatusChanged: _handleTypingStatus,
            replyToMessage: _replyToMessage,
            onCancelReply: _cancelReply,
          ),
        ],
      ),
    );
  }
}