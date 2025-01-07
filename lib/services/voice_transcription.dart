import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_speech/google_speech.dart';

class VoiceTranscriptionService {
  final _speechToText = SpeechToText();
  final _storage = FirebaseStorage.instance;

  Future<String> transcribeAudioFile(String filePath) async {
    final recognitionConfig = RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'en-US',
    );

    final audio = await _loadAudioFile(filePath);
    final response = await _recognizeAudio(audio, recognitionConfig);
    return response.results
        .map((result) => result.alternatives.first.transcript)
        .join('\n');
  }

  Future<void> uploadTranscription(
      String chatId, String messageId, String transcription) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'transcription': transcription});
  }
}
