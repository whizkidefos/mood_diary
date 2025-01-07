import 'package:flutter/material.dart';
import 'package:mood_diary/services/translation_service.dart';

class TranslatableMessage extends StatefulWidget {
  final String text;
  final String preferredLanguage;

  const TranslatableMessage({
    super.key,
    required this.text,
    required this.preferredLanguage,
  });

  @override
  State<TranslatableMessage> createState() => _TranslatableMessageState();
}

class _TranslatableMessageState extends State<TranslatableMessage> {
  final _translationService = TranslationService();
  String? _translation;
  bool _isTranslating = false;
  String? _detectedLanguage;

  Future<void> _translate() async {
    if (_isTranslating) return;

    setState(() => _isTranslating = true);

    try {
      _detectedLanguage ??=
          await _translationService.detectLanguage(widget.text);

      if (_detectedLanguage != widget.preferredLanguage) {
        _translation = await _translationService.translateMessage(
          widget.text,
          widget.preferredLanguage,
        );
      }
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.text),
        if (_isTranslating)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_translation != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _translation!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          )
        else if (_detectedLanguage != widget.preferredLanguage)
          TextButton(
            onPressed: _translate,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Translate',
              style: TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
}
