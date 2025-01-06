import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../widgets/chat/online_status.dart';
import '../../widgets/chat/media_preview.dart';
import '../../widgets/chat/file_attachment.dart';

class EnhancedChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const EnhancedChatScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<EnhancedChatScreen> createState() => _EnhancedChatScreenState();
}

class _EnhancedChatScreenState extends State<EnhancedChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = ChatService();
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  
  List<MediaItem> _selectedMedia = [];
  ChatMessage? _replyTo;
  bool _isAttachmentVisible = false;
  final bool _isRecording = false;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _onlineStatusSubscription;
  bool _isOtherUserTyping = false;
  bool _isOtherUserOnline = false;

  @override
  void initState() {
    super.initState();
    _setupSubscriptions();
    _loadMessages();
  }

  void _setupSubscriptions() {
    _typingSubscription = _chatService
        .getTypingStatus(widget.userId, 'currentUser')
        .listen((isTyping) {
      setState(() => _isOtherUserTyping = isTyping);
    });

    _onlineStatusSubscription = _chatService
        .getOnlineStatus(widget.userId)
        .listen((isOnline) {
      setState(() => _isOtherUserOnline = isOnline);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingSubscription?.cancel();
    _onlineStatusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(widget.userId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      // Process messages
    } catch (e) {
      _showError('Error loading messages');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedMedia.isEmpty) return;

    try {
      final message = {
        'text': _messageController.text,
        'senderId': 'currentUser',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
        'replyTo': _replyTo?.id,
      };

      if (_selectedMedia.isNotEmpty) {
        final mediaUrls = await _uploadMedia();
        message['mediaUrls'] = mediaUrls;
        message['type'] = 'media';
      }

      await _firestore
          .collection('chats')
          .doc(widget.userId)
          .collection('messages')
          .add(message);

      _messageController.clear();
      setState(() {
        _selectedMedia = [];
        _replyTo = null;
      });

      _scrollToBottom();
    } catch (e) {
      _showError('Error sending message');
    }
  }

  Future<List<String>> _uploadMedia() async {
    final urls = <String>[];
    for (final media in _selectedMedia) {
      final ref = _storage.ref().child(
        'chats/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}_${media.path.split('/').last}',
      );
      final uploadTask = await ref.putFile(File(media.path));
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  void _handleMediaPicked(List<MediaItem> media) {
    setState(() {
      _selectedMedia.addAll(media);
      _isAttachmentVisible = false;
    });
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(child: Text(widget.userName[0])),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: OnlineStatus(
                    isOnline: _isOtherUserOnline,
                    size: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName),
                if (_isOtherUserTyping)
                  const TypingIndicator()
                else
                  Text(
                    _isOtherUserOnline ? 'online' : 'offline',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCallScreen(
                    userId: widget.userId,
                    userName: widget.userName,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoiceCallScreen(
                    userId: widget.userId,
                    userName: widget.userName,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatOptionsScreen(
                    userId: widget.userId,
                    userName: widget.userName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_replyTo != null)
            ReplyMessage(
              senderName: _replyTo!.senderId == 'currentUser'
                  ? 'You'
                  : widget.userName,
              content: _replyTo!.content,
              onDismiss: () => setState(() => _replyTo = null),
            ),
          if (_selectedMedia.isNotEmpty)
            MediaPreview(
              items: _selectedMedia,
              onRemove: _removeMedia,
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.userId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading messages'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == 'currentUser';

                    return SwipeableMessage(
                      onReply: () {
                        setState(() {
                          _replyTo = ChatMessage(
                            id: messages[index].id,
                            senderId: message['senderId'],
                            content: message['text'],
                            timestamp: (message['timestamp'] as Timestamp).toDate(),
                          );
                        });
                      },
                      child: MessageBubble(
                        message: message,
                        isMe: isMe,
                        userName: widget.userName,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isAttachmentVisible) _buildAttachmentOptions(),
          _buildMessageInput(),
        ],
      ),
    );
  }