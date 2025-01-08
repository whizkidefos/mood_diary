import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime timestamp;
  final List<String>? mediaUrls;
  final String? replyToMessage;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
    this.mediaUrls,
    this.replyToMessage,
    this.onReply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const radius = Radius.circular(12);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (replyToMessage != null)
            Container(
              margin: EdgeInsets.only(
                left: isMe ? 0 : 12,
                right: isMe ? 12 : 0,
                bottom: 4,
              ),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: Text(
                replyToMessage!,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: radius,
                      topRight: radius,
                      bottomLeft: isMe ? radius : Radius.zero,
                      bottomRight: isMe ? Radius.zero : radius,
                    ),
                    border: !isMe
                        ? Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mediaUrls != null && mediaUrls!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            mediaUrls!.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 200,
                                color: theme.colorScheme.error.withOpacity(0.1),
                                child: Icon(
                                  Icons.error_outline,
                                  color: theme.colorScheme.error,
                                ),
                              );
                            },
                          ),
                        ),
                        if (mediaUrls!.length > 1)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '+${mediaUrls!.length - 1} more',
                              style: TextStyle(
                                color: isMe
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                      ],
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: isMe
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: isMe ? 0 : 40,
              right: isMe ? 12 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.jm().format(timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (onReply != null || onDelete != null) ...[
                  const SizedBox(width: 8),
                  if (onReply != null)
                    InkWell(
                      onTap: onReply,
                      child: Icon(
                        Icons.reply,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  if (onDelete != null && isMe) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onDelete,
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
