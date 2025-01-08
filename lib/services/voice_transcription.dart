import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:record/record.dart';

class VoiceTranscriptionService {
  static final VoiceTranscriptionService _instance = VoiceTranscriptionService._internal();
  factory VoiceTranscriptionService() => _instance;
  VoiceTranscriptionService._internal();

  final _speechToText = stt.SpeechToText();
  final _audioRecorder = Record();
  
  bool _isInitialized = false;
  bool _isRecording = false;
  String? _currentRecordingPath;
  StreamController<String>? _transcriptionController;
  Timer? _levelTimer;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => print('Speech to text error: $error'),
        onStatus: (status) => print('Speech to text status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      print('Error initializing voice transcription: $e');
      return false;
    }
  }

  Future<void> startRecording() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) throw Exception('Failed to initialize voice transcription');
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        // Get the temporary directory
        final tempDir = await getTemporaryDirectory();
        _currentRecordingPath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // Start recording
        await _audioRecorder.start(
          path: _currentRecordingPath,
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          samplingRate: 44100,
        );

        _isRecording = true;

        // Monitor audio levels
        _levelTimer?.cancel();
        _levelTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
          final amplitude = await _audioRecorder.getAmplitude();
          print('Recording amplitude: ${amplitude.current}');
        });
      } else {
        throw Exception('Microphone permission denied');
      }
    } catch (e) {
      print('Error starting recording: $e');
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    try {
      _levelTimer?.cancel();
      _levelTimer = null;

      if (!_isRecording) return null;

      // Stop recording
      final path = await _audioRecorder.stop();
      _isRecording = false;

      if (path == null) return null;

      // Start transcription
      return await transcribeAudio(path);
    } catch (e) {
      print('Error stopping recording: $e');
      rethrow;
    }
  }

  Future<String> transcribeAudio(String audioPath) async {
    try {
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) throw Exception('Failed to initialize voice transcription');
      }

      _transcriptionController = StreamController<String>();

      await _speechToText.listen(
        onResult: (result) {
          if (!result.finalResult) {
            _transcriptionController?.add(result.recognizedWords);
          } else {
            _transcriptionController?.close();
          }
        },
        listenMode: stt.ListenMode.deviceDefault,
        cancelOnError: true,
        partialResults: true,
      );

      // Wait for the transcription to complete
      final transcription = await _transcriptionController!.stream.last;
      return transcription;
    } catch (e) {
      print('Error transcribing audio: $e');
      rethrow;
    } finally {
      await _transcriptionController?.close();
      _transcriptionController = null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      _levelTimer?.cancel();
      _levelTimer = null;

      if (_isRecording) {
        await _audioRecorder.stop();
        _isRecording = false;

        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Error canceling recording: $e');
      rethrow;
    }
  }

  Stream<double> get audioLevel {
    return Stream.periodic(const Duration(milliseconds: 100)).asyncMap((_) async {
      if (!_isRecording) return 0.0;
      final amplitude = await _audioRecorder.getAmplitude();
      return amplitude.current ?? 0.0;
    });
  }

  bool get isRecording => _isRecording;

  void dispose() {
    _levelTimer?.cancel();
    _transcriptionController?.close();
    _audioRecorder.dispose();
  }
}
