import 'package:flutter/material.dart';

class FileAttachment extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final IconData fileIcon;
  final VoidCallback onDownload;

  const FileAttachment({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.fileIcon,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(fileIcon),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fileSize,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}
