import '../model/curriculum_models.dart';
import 'curriculum_en.dart';
import 'curriculum_es.dart';
import 'curriculum_fr.dart';
import 'curriculum_pt.dart';
import 'curriculum_zh.dart';

/// Registry of the bundled curricula — one per learnable target language.
/// Lesson ids are language-prefixed ('es-saludos', 'fr-salutations', ...) so
/// progress never collides when the learner switches language.
abstract class CurriculumData {
  static const Map<String, Curriculum> byLanguage = {
    'es': spanishCurriculum,
    'fr': frenchCurriculum,
    'pt': portugueseCurriculum,
    'zh': mandarinCurriculum,
    'en': englishCurriculum,
  };

  /// Curriculum of [languageCode], falling back to Spanish when unknown.
  static Curriculum of(String languageCode) =>
      byLanguage[languageCode] ?? spanishCurriculum;

  /// Levels of [languageCode]'s curriculum.
  static List<Level> levelsOf(String languageCode) => of(languageCode).levels;

  /// Lesson matching [lessonId] in any curriculum — call history and feedback
  /// can reference lessons of a language the learner has since switched away
  /// from.
  static Lesson? lessonById(String? lessonId) {
    if (lessonId == null) return null;
    for (final curriculum in byLanguage.values) {
      for (final lesson in curriculum.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }
}
