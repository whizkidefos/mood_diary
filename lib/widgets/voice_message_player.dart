import 'package:flutter/material.dart';

class VoiceMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final String? transcription;
  final bool showTranscription;

  const VoiceMessagePlayer({
    super.key,
    required this.audioUrl,
    this.transcription,
    this.showTranscription = false,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    await _player.setUrl(widget.audioUrl);
    _player.durationStream
        .listen((d) => setState(() => _duration = d ?? Duration.zero));
    _player.positionStream.listen((p) => setState(() => _position = p));
    _player.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                _isPlaying ? _player.pause() : _player.play();
              },
            ),
            Expanded(
              child: Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  _player.seek(Duration(seconds: value.toInt()));
                },
              ),
            ),
            Text(_formatDuration(_position)),
          ],
        ),
        if (widget.showTranscription && widget.transcription != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              widget.transcription!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
      ],
    );
  }
}
