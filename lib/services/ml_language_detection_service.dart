import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class MLLanguageDetectionService {
  final LanguageIdentifier _identifier =
      LanguageIdentifier(confidenceThreshold: 0.5);

  Future<({String langCode, double confidence})?> identify(String text) async {
    if (text.trim().isEmpty) return null;
    try {
      final langCode = await _identifier.identifyLanguage(text);
      if (langCode == 'und') return null;
      final possibles = await _identifier.identifyPossibleLanguages(text);
      final confidence = possibles
          .firstWhere((l) => l.languageTag == langCode,
              orElse: () =>
                  IdentifiedLanguage(languageTag: langCode, confidence: 0.5))
          .confidence;
      return (langCode: langCode, confidence: confidence);
    } catch (_) {
      return null;
    }
  }

  void dispose() => _identifier.close();
}
