import 'package:translator/translator.dart';

class TranslationService {
  final _translator = GoogleTranslator();
  final Map<String, String> _cache = {};

  Future<String> translateMessage(String text, String targetLanguage) async {
    final cacheKey = '$text-$targetLanguage';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final translation = await _translator.translate(
      text,
      to: targetLanguage,
    );

    _cache[cacheKey] = translation.text;
    return translation.text;
  }

  Future<String> detectLanguage(String text) async {
    final detection = await _translator.detect(text);
    return detection.languageCode;
  }
}

extension on GoogleTranslator {
  detect(String text) {}
}
