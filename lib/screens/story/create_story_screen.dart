import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
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

  final int _maxFileSize = 10 * 1024 * 1024; // 10MB
  final List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'mp4'];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final File file = File(image.path);
        final int fileSize = await file.length();

        // Check if file size is less than 10MB
        if (fileSize > _maxFileSize) {
          setState(() {
            _isLoading = false;
            _selectedImage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image size must be less than 10MB')),
          );
          return;
        }

        // Validate file extension
        String extension = path.extension(file.path).toLowerCase().replaceAll('.', '');
        if (!_allowedExtensions.contains(extension)) {
          setState(() {
            _isLoading = false;
            _selectedImage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid file type. Allowed types: ${_allowedExtensions.join(', ')}')),
          );
          return;
        }

        setState(() {
          _selectedImage = image;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _selectedImage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _createStory() async {
    if (_textController.text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content or an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      String? mediaUrl;
      if (_selectedImage != null) {
        final File file = File(_selectedImage!.path);
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.uid}.jpg';
        final Reference ref = FirebaseStorage.instance.ref().child('stories').child(fileName);

        await ref.putFile(file);
        mediaUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('stories').add({
        'userId': user.uid,
        'text': _textController.text,
        'backgroundColor': _backgroundColor.value,
        'textSize': _textSize,
        'textAlign': _textAlign.toString(),
        'mediaUrl': mediaUrl,
        'mediaType': _selectedImage != null
            ? path.extension(_selectedImage!.path).toLowerCase().replaceAll('.', '')
            : null,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(hours: 24)),
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story created successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating story: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            onPressed: _isLoading ? null : _createStory,
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
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Write your story...',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      fontSize: _textSize,
                      color: Colors.white,
                    ),
                    textAlign: _textAlign,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.color_lens),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => _buildColorPicker(),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_size),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => _buildTextSizePicker(),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_align_center),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => _buildTextAlignPicker(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Add Image'),
                    onPressed: _pickImage,
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(
                          File(_selectedImage!.path),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _selectedImage = null),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _colorOptions.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() => _backgroundColor = _colorOptions[index]);
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: _colorOptions[index],
                shape: BoxShape.circle,
                border: Border.all(
                  color: _backgroundColor == _colorOptions[index]
                      ? Colors.white
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextSizePicker() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [16, 24, 32, 48].map((size) {
          return InkWell(
            onTap: () {
              setState(() => _textSize = size.toDouble());
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _textSize == size ? Colors.blue : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Aa',
                style: TextStyle(fontSize: size.toDouble()),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextAlignPicker() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.format_align_left),
            onPressed: () {
              setState(() => _textAlign = TextAlign.left);
              Navigator.pop(context);
            },
            color: _textAlign == TextAlign.left ? Colors.blue : null,
          ),
          IconButton(
            icon: const Icon(Icons.format_align_center),
            onPressed: () {
              setState(() => _textAlign = TextAlign.center);
              Navigator.pop(context);
            },
            color: _textAlign == TextAlign.center ? Colors.blue : null,
          ),
          IconButton(
            icon: const Icon(Icons.format_align_right),
            onPressed: () {
              setState(() => _textAlign = TextAlign.right);
              Navigator.pop(context);
            },
            color: _textAlign == TextAlign.right ? Colors.blue : null,
          ),
        ],
      ),
    );
  }
}
