import 'package:flutter/material.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _textController = TextEditingController();
  Color _backgroundColor = Colors.blue;
  double _textSize = 24;
  TextAlign _textAlign = TextAlign.center;

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.teal,
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Story'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Share story
              Navigator.pop(context);
            },
            child: const Text('Share'),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundColor,
                  _backgroundColor.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Focus text field
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: TextField(
                          controller: _textController,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _textSize,
                          ),
                          textAlign: _textAlign,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Type your story...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Controls
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Color options
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _colorOptions.map((color) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _backgroundColor = color),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: _backgroundColor == color
                                        ? Border.all(
                                            color: Colors.white, width: 2)
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Text controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.format_size),
                            onPressed: () => setState(() {
                              _textSize = _textSize == 24 ? 32 : 24;
                            }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_align_left),
                            onPressed: () => setState(() {
                              _textAlign = TextAlign.left;
                            }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_align_center),
                            onPressed: () => setState(() {
                              _textAlign = TextAlign.center;
                            }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_align_right),
                            onPressed: () => setState(() {
                              _textAlign = TextAlign.right;
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
