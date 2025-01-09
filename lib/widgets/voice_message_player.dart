import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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
  late AudioPlayer _audioPlayer;
  final _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _audioPlayer = AudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _player.setUrl(widget.audioUrl);
      _player.durationStream.listen(
        (d) => setState(() {
          _duration = d ?? Duration.zero;
          _isLoading = false;
        }),
      );
      _player.positionStream.listen((p) => setState(() => _position = p));
      _player.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
          _hasError = state.processingState == ProcessingState.completed;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      if (kDebugMode) {
        print('Error initializing audio player: $e');
      }
    }
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
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_hasError)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Failed to load audio',
              style: TextStyle(color: Colors.red),
            ),
          )
        else if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
        else
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (_isPlaying) {
                      _player.pause();
                    } else {
                      _player.play();
                    }
                  },
                ),
                Expanded(
                  child: Slider(
                    value: _position.inSeconds.toDouble(),
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _player.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                Text(_formatDuration(_position)),
                const Text(' / '),
                Text(_formatDuration(_duration)),
              ],
            ),
          ),
        if (widget.showTranscription && widget.transcription != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.transcription!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}
