import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class VoiceMessageRecorder extends StatefulWidget {
  final Function(Duration duration) onRecordingComplete;

  const VoiceMessageRecorder({
    super.key,
    required this.onRecordingComplete,
  });

  @override
  State<VoiceMessageRecorder> createState() => _VoiceMessageRecorderState();
}

class _VoiceMessageRecorderState extends State<VoiceMessageRecorder>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  DateTime? _startTime;
  Timer? _timer;
  Duration _duration = Duration.zero;
  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveformController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _startTime = DateTime.now();
      _duration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = DateTime.now().difference(_startTime!);
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    widget.onRecordingComplete(_duration);
    setState(() {
      _isRecording = false;
      _duration = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isRecording
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
            ),
            if (_isRecording) ...[
              const SizedBox(width: 8),
              Text(
                '${_duration.inSeconds}s',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                height: 20,
                child: AnimatedBuilder(
                  animation: _waveformController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _WaveformPainter(
                        animation: _waveformController.value,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double animation;

  _WaveformPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    var x = 0.0;
    final points = List.generate(
      10,
      (i) => math.sin((i / 10) * 2 * math.pi + animation * 2 * math.pi),
    );

    path.moveTo(0, size.height / 2);
    for (var i = 0; i < points.length; i++) {
      x = (i / (points.length - 1)) * size.width;
      path.lineTo(
        x,
        size.height / 2 + points[i] * 8,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// Add VoiceMessagePlayer widget for playing recorded messages
class VoiceMessagePlayer extends StatefulWidget {
  final Duration duration;
  final String url;

  const VoiceMessagePlayer({
    super.key,
    required this.duration,
    required this.url,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  bool _isPlaying = false;
  double _progress = 0.0;
  Timer? _progressTimer;

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startPlayback();
      } else {
        _stopPlayback();
      }
    });
  }

  void _startPlayback() {
    // TODO: Implement actual audio playback
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.1 / widget.duration.inSeconds;
        if (_progress >= 1.0) {
          _progress = 0.0;
          _isPlaying = false;
          timer.cancel();
        }
      });
    });
  }

  void _stopPlayback() {
    _progressTimer?.cancel();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlay,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.duration.inSeconds}s',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
