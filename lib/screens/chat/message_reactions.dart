import 'package:flutter/material.dart';

class MessageReactions extends StatelessWidget {
  final Map<String, List<String>> reactions;
  final Function(String) onReactionSelected;
  final bool showAddButton;

  const MessageReactions({
    super.key,
    required this.reactions,
    required this.onReactionSelected,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...reactions.entries.map((entry) {
          return InkWell(
            onTap: () => onReactionSelected(entry.key),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
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
        if (showAddButton)
          IconButton(
            icon: const Icon(Icons.add_reaction_outlined),
            onPressed: () => _showReactionPicker(context),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ReactionPicker(),
    );
  }
}

class ReactionPicker extends StatelessWidget {
  const ReactionPicker({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  Navigator.pop(context, emoji);
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
    );
  }
}
