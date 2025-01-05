import 'package:flutter/material.dart';
import 'dart:async';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  List<String> _items = [];
  List<bool> _flipped = [];
  List<int> _matched = [];
  int? _firstFlip;
  bool _canFlip = true;
  int _moves = 0;
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    final emojis = ['😊', '🌟', '💖', '🌈', '🎨', '🎵', '🌺', '🦋'];
    _items = [...emojis, ...emojis]..shuffle();
    _flipped = List.filled(_items.length, false);
    _matched = [];
    _firstFlip = null;
    _moves = 0;
    _secondsElapsed = 0;
    _canFlip = true;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  void _onCardTap(int index) {
    if (!_canFlip || _flipped[index] || _matched.contains(index)) return;

    setState(() {
      _flipped[index] = true;

      if (_firstFlip == null) {
        _firstFlip = index;
      } else {
        _moves++;
        _canFlip = false;

        if (_items[_firstFlip!] == _items[index]) {
          _matched.addAll([_firstFlip!, index]);
          _firstFlip = null;
          _canFlip = true;

          if (_matched.length == _items.length) {
            _timer?.cancel();
            _showWinDialog();
          }
        } else {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() {
                _flipped[_firstFlip!] = false;
                _flipped[index] = false;
                _firstFlip = null;
                _canFlip = true;
              });
            }
          });
        }
      }
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations! 🎉'),
        content: Text(
          'You completed the game in $_moves moves and $_secondsElapsed seconds!',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _initializeGame());
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
        title: const Text('Memory Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _initializeGame()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Moves: $_moves'),
                Text('Time: ${_secondsElapsed}s'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onCardTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateY(_flipped[index] ? 3.14 : 0),
                    transformAlignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _matched.contains(index)
                          ? Colors.green.withOpacity(0.3)
                          : Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Center(
                      child: Text(
                        _flipped[index] ? _items[index] : '?',
                        style: const TextStyle(fontSize: 32),
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
  }
}
