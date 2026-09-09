/// A language the app knows about: display metadata plus the locales used by
/// the speech services.
///
/// Names are endonyms, written the way each language names itself, so they
/// need no translation — the app interface itself ships in French and English.
class AppLanguage {
  final String code; // 'es', 'fr', 'zh', 'en', …
  final String flag; // emoji shown in pickers and settings rows
  final String label; // endonym shown in pickers ("Español", "中文")
  final String englishName; // name given to the AI tutor in its prompt
  final String ttsLocale; // flutter_tts locale tag
  final String sttLocale; // speech_to_text locale id

  const AppLanguage({
    required this.code,
    required this.flag,
    required this.label,
    required this.englishName,
    required this.ttsLocale,
    required this.sttLocale,
  });
}

/// Catalogue of supported languages.
abstract class AppLanguages {
  static const _catalogue = <String, AppLanguage>{
    'es': AppLanguage(
      code: 'es',
      label: 'Español',
      flag: '🇪🇸',
      englishName: 'Spanish',
      ttsLocale: 'es-ES',
      sttLocale: 'es_ES',
    ),
    'fr': AppLanguage(
      code: 'fr',
      label: 'Français',
      flag: '🇫🇷',
      englishName: 'French',
      ttsLocale: 'fr-FR',
      sttLocale: 'fr_FR',
    ),
    'zh': AppLanguage(
      code: 'zh',
      label: '中文',
      flag: '🇨🇳',
      englishName: 'Mandarin Chinese',
      ttsLocale: 'zh-CN',
      sttLocale: 'zh_CN',
    ),
    'en': AppLanguage(
      code: 'en',
      label: 'English',
      flag: '🇬🇧',
      englishName: 'English',
      ttsLocale: 'en-US',
      sttLocale: 'en_US',
    ),
    // Brazilian Portuguese: the curriculum, the voice and the speech locales
    // all follow pt-BR rather than European Portuguese.
    'pt': AppLanguage(
      code: 'pt',
      label: 'Português',
      flag: '🇧🇷',
      englishName: 'Brazilian Portuguese',
      ttsLocale: 'pt-BR',
      sttLocale: 'pt_BR',
    ),
    'ar': AppLanguage(
      code: 'ar',
      label: 'العربية',
      flag: '🇸🇦',
      englishName: 'Arabic',
      ttsLocale: 'ar-SA',
      sttLocale: 'ar_SA',
    ),
    'tr': AppLanguage(
      code: 'tr',
      label: 'Türkçe',
      flag: '🇹🇷',
      englishName: 'Turkish',
      ttsLocale: 'tr-TR',
      sttLocale: 'tr_TR',
    ),
  };

  /// Languages the learner can study — one bundled curriculum each.
  static const learnable = ['es', 'fr', 'pt', 'zh', 'en'];

  /// Languages selectable as the learner's native language.
  static const native = ['fr', 'en', 'es', 'zh', 'ar', 'tr'];

  static AppLanguage of(String code) => _catalogue[code] ?? _catalogue['en']!;

  /// Endonym of [code] ("Español", "中文").
  static String labelOf(String code) => of(code).label;
}
