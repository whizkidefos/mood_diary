import 'package:flutter/material.dart';

class MediaPreview extends StatelessWidget {
  final List<MediaItem> items;
  final Function(int) onRemove;

  const MediaPreview({
    super.key,
    required this.items,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Stack(
            children: [
              Container(
                width: 100,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.buildPreview(),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => onRemove(index),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MediaItem {
  final String path;
  final MediaType type;

  MediaItem({required this.path, required this.type});

  Widget buildPreview() {
    switch (type) {
      case MediaType.image:
        return Image.asset(path, fit: BoxFit.cover);
      case MediaType.video:
        return Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(path, fit: BoxFit.cover),
            const Icon(Icons.play_circle, color: Colors.white),
          ],
        );
      case MediaType.file:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insert_drive_file),
            Text(path.split('/').last, maxLines: 1),
          ],
        );
    }
  }
}

enum MediaType { image, video, file }
