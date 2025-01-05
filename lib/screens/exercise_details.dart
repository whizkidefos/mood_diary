import 'package:flutter/material.dart';
import 'dart:async';

class ExerciseDetails extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetails({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseDetails> createState() => _ExerciseDetailsState();
}

class _ExerciseDetailsState extends State<ExerciseDetails> {
  bool _isCompleted = false;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _parseSeconds(widget.exercise['duration']);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _parseSeconds(String duration) {
    final parts = duration.split(' ');
    return int.parse(parts[0]) * 60; // Convert minutes to seconds
  }

  void _startTimer() {
    setState(() => _isTimerRunning = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _isCompleted = true;
          _isTimerRunning = false;
          _showCompletionDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Great job! 🎉'),
        content: const Text('You\'ve completed the exercise!'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
    final steps = [
      'Find a comfortable space',
      'Take deep breaths',
      'Start with light movements',
      widget.exercise['instructions'] ?? 'Follow the exercise pattern',
      'Stay hydrated',
      'Listen to your body',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise['title']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.exercise['icon'],
                  size: 64,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(widget.exercise['description']),
            const SizedBox(height: 24),
            Text(
              'Steps to follow',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(steps[index])),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _formatTime(_secondsRemaining),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isCompleted) ...[
                          FilledButton.icon(
                            onPressed:
                                _isTimerRunning ? _pauseTimer : _startTimer,
                            icon: Icon(_isTimerRunning
                                ? Icons.pause
                                : Icons.play_arrow),
                            label: Text(_isTimerRunning ? 'Pause' : 'Start'),
                          ),
                          if (_isTimerRunning) ...[
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                _timer?.cancel();
                                setState(() {
                                  _secondsRemaining = _parseSeconds(
                                      widget.exercise['duration']);
                                  _isTimerRunning = false;
                                });
                              },
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('Reset'),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
