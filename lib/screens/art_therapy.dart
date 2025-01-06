import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ArtTherapy extends StatefulWidget {
  final Map<String, dynamic> activity;

  const ArtTherapy({
    super.key,
    required this.activity,
  });

  @override
  State<ArtTherapy> createState() => _ArtTherapyState();
}

class _ArtTherapyState extends State<ArtTherapy> {
  List<DrawingPoint?> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 5;
  List<Color> colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.brown,
  ];

  void _onDragStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = DrawingPoint(
      id: DateTime.now().millisecondsSinceEpoch,
      offsets: [box.globalToLocal(details.globalPosition)],
      color: selectedColor,
      strokeWidth: strokeWidth,
    );

    setState(() => points.add(point));
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = points.last;

    if (point != null) {
      final newPoint = DrawingPoint(
        id: point.id,
        offsets: [...point.offsets, box.globalToLocal(details.globalPosition)],
        color: point.color,
        strokeWidth: point.strokeWidth,
      );

      setState(() => points[points.length - 1] = newPoint);
    }
  }

  void _clearCanvas() {
    setState(() => points.clear());
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Color',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedColor = colors[index]);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == colors[index]
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBrushSizeSlider() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 150,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Brush Size',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.brush, size: 16),
                      Expanded(
                        child: Slider(
                          value: strokeWidth,
                          min: 1,
                          max: 20,
                          onChanged: (value) {
                            setModalState(() => strokeWidth = value);
                            setState(() {});
                          },
                        ),
                      ),
                      const Icon(Icons.brush, size: 32),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSaveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Great Work! 🎨'),
        content: const Text(
            'Remember, art therapy is about the process, not the final product. '
            'How do you feel after creating this piece?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCanvas();
            },
            child: const Text('Start New'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity['title']),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _showSaveConfirmation,
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: _onDragStart,
            onPanUpdate: _onDragUpdate,
            child: CustomPaint(
              painter: DrawingPainter(points: points),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.color_lens),
                      onPressed: _showColorPicker,
                      tooltip: 'Color',
                    ),
                    IconButton(
                      icon: const Icon(Icons.brush),
                      onPressed: _showBrushSizeSlider,
                      tooltip: 'Brush Size',
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearCanvas,
                      tooltip: 'Clear Canvas',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawingPoint {
  final int id;
  final List<Offset> offsets;
  final Color color;
  final double strokeWidth;

  DrawingPoint({
    required this.id,
    required this.offsets,
    required this.color,
    required this.strokeWidth,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (final point in points) {
      if (point == null) continue;

      final paint = Paint()
        ..color = point.color
        ..strokeWidth = point.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < point.offsets.length - 1; i++) {
        final p1 = point.offsets[i];
        final p2 = point.offsets[i + 1];
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}
