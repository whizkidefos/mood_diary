import 'package:flutter/material.dart';
import 'dart:async';

class MeditationDetails extends StatefulWidget {
  final Map<String, dynamic> meditation;

  const MeditationDetails({
    super.key,
    required this.meditation,
  });

  @override
  State<MeditationDetails> createState() => _MeditationDetailsState();
}

class _MeditationDetailsState extends State<MeditationDetails>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  Timer? _timer;
  int _remainingSeconds = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _parseSeconds(widget.meditation['duration']);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  int _parseSeconds(String duration) {
    final parts = duration.split(' ');
    return int.parse(parts[0]) * 60;
  }

  void _togglePlaying() {
    setState(() => _isPlaying = !_isPlaying);

    if (_isPlaying) {
      _startTimer();
      _animationController.repeat(reverse: true);
    } else {
      _timer?.cancel();
      _animationController.stop();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isPlaying = false;
          timer.cancel();
          _animationController.stop();
          _showCompletionDialog();
        }
      });
    });
  }

  void _resetTimer() {
    setState(() {
      _remainingSeconds = _parseSeconds(widget.meditation['duration']);
      _isPlaying = false;
    });
    _timer?.cancel();
    _animationController.stop();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete'),
        content: const Text('Great job completing your meditation session!'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final List<String> instructions = [
      'Find a quiet, comfortable space',
      'Sit or lie down in a relaxed position',
      'Close your eyes or maintain a soft gaze',
      'Focus on your breath',
      'Let thoughts come and go without judgment',
      'Gently return focus when mind wanders',
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text(widget.meditation['title']),
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: Icon(
                    widget.meditation['icon'],
                    size: 64,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.meditation['description']),
                  const SizedBox(height: 24),
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: instructions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(instructions[index])),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _animation,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Center(
                              child: Text(
                                _formatTime(_remainingSeconds),
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton.large(
                              onPressed: _togglePlaying,
                              child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                              ),
                            ),
                            if (_isPlaying ||
                                _remainingSeconds <
                                    _parseSeconds(
                                        widget.meditation['duration'])) ...[
                              const SizedBox(width: 16),
                              FloatingActionButton(
                                onPressed: _resetTimer,
                                child: const Icon(Icons.restart_alt),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
