import 'package:flutter/material.dart';
import 'package:mood_diary/widgets/chat/media_preview.dart';

class MediaViewer extends StatefulWidget {
  final List<MediaItem> items;
  final int initialIndex;

  const MediaViewer({
    super.key,
    required this.items,
    this.initialIndex = 0,
  });

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1}/${widget.items.length}'),
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            return InteractiveViewer(
              child: Center(
                child: widget.items[index].buildPreview(),
              ),
            );
          },
        ),
      ),
    );
  }
}
