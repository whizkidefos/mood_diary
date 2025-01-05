import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MusicPlayer extends StatefulWidget {
  final Map<String, dynamic> track;

  const MusicPlayer({
    super.key,
    required this.track,
  });

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  Timer? _timer;
  int _currentSeconds = 0;
  late final AnimationController _waveController;
  late final List<AnimationController> _barControllers;
  final int _barCount = 30;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _barControllers = List.generate(
      _barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200 + Random().nextInt(1000)),
        lowerBound: 0.3,
        upperBound: 1.0,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    for (var controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _togglePlaying() {
    setState(() => _isPlaying = !_isPlaying);

    if (_isPlaying) {
      _startTimer();
      _startBarAnimations();
    } else {
      _timer?.cancel();
      _stopBarAnimations();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentSeconds < _parseSeconds(widget.track['duration'])) {
          _currentSeconds++;
        } else {
          _isPlaying = false;
          timer.cancel();
          _stopBarAnimations();
        }
      });
    });
  }

  void _startBarAnimations() {
    for (var controller in _barControllers) {
      controller.repeat(reverse: true);
    }
  }

  void _stopBarAnimations() {
    for (var controller in _barControllers) {
      controller.stop();
    }
  }

  void _seekTo(double value) {
    setState(() => _currentSeconds = value.toInt());
  }

  int _parseSeconds(String duration) {
    final parts = duration.split(' ');
    return int.parse(parts[0]) * 60;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = _parseSeconds(widget.track['duration']);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text(widget.track['title']),
            centerTitle: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: Icon(
                    widget.track['icon'],
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
                children: [
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(_barCount, (index) {
                        return AnimatedBuilder(
                          animation: _barControllers[index],
                          builder: (context, child) {
                            return Container(
                              width: MediaQuery.of(context).size.width /
                                  (_barCount * 2),
                              height: 100 * _barControllers[index].value,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(_isPlaying ? 0.8 : 0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Slider(
                    value: _currentSeconds.toDouble(),
                    min: 0,
                    max: totalDuration.toDouble(),
                    onChanged: _seekTo,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatTime(_currentSeconds)),
                        Text(_formatTime(totalDuration)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: () {
                          // TODO: Implement previous track
                        },
                        iconSize: 32,
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton.large(
                        onPressed: _togglePlaying,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: () {
                          // TODO: Implement next track
                        },
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(widget.track['description']),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
