import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class ColorPatterns extends StatefulWidget {
  const ColorPatterns({super.key});

  @override
  State<ColorPatterns> createState() => _ColorPatternsState();
}

class _ColorPatternsState extends State<ColorPatterns> {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  List<int> _sequence = [];
  List<int> _playerSequence = [];
  int _score = 0;
  bool _isShowingSequence = false;
  bool _canPlay = false;

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    setState(() {
      _isShowingSequence = true;
      _canPlay = false;
      _playerSequence = [];
      _sequence.add(Random().nextInt(_colors.length));
    });
    _showSequence();
  }

  Future<void> _showSequence() async {
    for (int color in _sequence) {
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _playerSequence = [color]);

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _playerSequence = []);
    }

    if (mounted) {
      setState(() {
        _isShowingSequence = false;
        _canPlay = true;
        _playerSequence = [];
      });
    }
  }

  void _onColorTap(int colorIndex) {
    if (!_canPlay) return;

    setState(() {
      _playerSequence.add(colorIndex);
    });

    if (_playerSequence[_playerSequence.length - 1] !=
        _sequence[_playerSequence.length - 1]) {
      _showGameOver();
      return;
    }

    if (_playerSequence.length == _sequence.length) {
      _score++;
      _startNewRound();
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score: $_score'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _score = 0;
                _sequence = [];
                _startNewRound();
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Patterns'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Score: $_score',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isShowingSequence
                ? 'Watch the sequence...'
                : 'Repeat the sequence!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _colors.length,
            itemBuilder: (context, index) {
              final isActive =
                  _playerSequence.isNotEmpty && _playerSequence.last == index;

              return GestureDetector(
                onTap: () => _onColorTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _colors[index].withOpacity(isActive ? 1 : 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _colors[index],
                      width: 4,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
