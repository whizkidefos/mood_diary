import 'package:flutter/material.dart';

class StoryAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final bool hasStory;
  final bool isAdd;
  final VoidCallback onTap;
  final double size;

  const StoryAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.hasStory = false,
    this.isAdd = false,
    required this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(hasStory ? 3 : 0),
            decoration: hasStory
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                        Theme.of(context).colorScheme.primary,
                      ],
                    ),
                  )
                : null,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: size / 2,
                backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl!) : null,
                backgroundColor: isAdd
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.primary,
                child: isAdd
                    ? Icon(
                        Icons.add,
                        size: size / 2,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : imageUrl == null
                        ? Text(name[0].toUpperCase())
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAdd ? 'Add Story' : name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
