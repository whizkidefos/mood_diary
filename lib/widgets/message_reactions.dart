import 'package:flutter/material.dart';

class MessageReactions extends StatefulWidget {
  final Map<String, List<String>> reactions;
  final Function(String emoji) onReactionSelected;
  final bool showAddButton;

  const MessageReactions({
    super.key,
    required this.reactions,
    required this.onReactionSelected,
    this.showAddButton = true,
  });

  @override
  State<MessageReactions> createState() => _MessageReactionsState();
}

class _MessageReactionsState extends State<MessageReactions> {
  static const _availableReactions = [
    '❤️',
    '👍',
    '👏',
    '😊',
    '😢',
    '😮',
    '🎉',
    '🙏',
    '💪',
    '✨',
  ];

  void _showReactionPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Reaction',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableReactions.map((emoji) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onReactionSelected(emoji);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...widget.reactions.entries.map((entry) {
          return InkWell(
            onTap: () => widget.onReactionSelected(entry.key),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.key),
                  const SizedBox(width: 4),
                  Text(
                    entry.value.length.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }),
        if (widget.showAddButton)
          IconButton(
            icon: const Icon(Icons.add_reaction_outlined),
            onPressed: _showReactionPicker,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}

// Add ReactionAnimation widget for reaction effects
class ReactionAnimation extends StatelessWidget {
  final String emoji;
  final Animation<double> animation;

  const ReactionAnimation({
    super.key,
    required this.emoji,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            -50 * animation.value,
          ),
          child: Opacity(
            opacity: 1 - animation.value,
            child: Transform.scale(
              scale: 1 + animation.value,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}
