import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
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

  Future<void> _saveStory() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text for your story')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to create a story')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('stories').add({
        'userId': user.uid,
        'text': _textController.text,
        'backgroundColor': _backgroundColor.value,
        'textSize': _textSize,
        'textAlign': _textAlign.toString(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating story: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Story'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveStory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      textAlign: _textAlign,
                      style: TextStyle(
                        fontSize: _textSize,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Write your story...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: _colorOptions.map((color) {
                      return InkWell(
                        onTap: () => setState(() => _backgroundColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _backgroundColor == color
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.format_size),
                        onPressed: () => setState(() => _textSize += 2),
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_size),
                        onPressed: () => setState(() => _textSize -= 2),
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_align_left),
                        onPressed: () => setState(() => _textAlign = TextAlign.left),
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_align_center),
                        onPressed: () => setState(() => _textAlign = TextAlign.center),
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_align_right),
                        onPressed: () => setState(() => _textAlign = TextAlign.right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
