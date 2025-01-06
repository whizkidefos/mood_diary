import 'package:flutter/material.dart';

class ReplyMessage extends StatelessWidget {
  final String senderName;
  final String content;
  final VoidCallback onDismiss;

  const ReplyMessage({
    super.key,
    required this.senderName,
    required this.content,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  senderName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// Add Swipeable message functionality to MessageBubble
class SwipeableMessage extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;

  const SwipeableMessage({
    super.key,
    required this.child,
    required this.onReply,
  });

  @override
  State<SwipeableMessage> createState() => _SwipeableMessageState();
}

class _SwipeableMessageState extends State<SwipeableMessage> {
  double _dragExtent = 0;
  static const _dragThreshold = 50.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent += details.primaryDelta!;
          if (_dragExtent < 0) _dragExtent = 0;
          if (_dragExtent > _dragThreshold) _dragExtent = _dragThreshold;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragExtent >= _dragThreshold) {
          widget.onReply();
        }
        setState(() => _dragExtent = 0);
      },
      child: Stack(
        children: [
          if (_dragExtent > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.reply,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20 * (_dragExtent / _dragThreshold),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
