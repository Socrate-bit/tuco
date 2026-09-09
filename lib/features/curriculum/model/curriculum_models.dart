import 'package:equatable/equatable.dart';

/// A vocabulary entry: target-language word + native translation.
class VocabWord extends Equatable {
  final String word;
  final String translation;

  const VocabWord({required this.word, required this.translation});

  @override
  List<Object?> get props => [word, translation];
}

/// A single lesson on the path: one everyday situation the learner walks out
/// able to handle (greeting someone, ordering a drink…).
class Lesson extends Equatable {
  final String id;
  final String title; // target-language title, e.g. "¡Hola Y Adiós!"
  final String description; // the situation, in the native language
  final String icon; // material icon key (see LessonIcons)
  final int color; // ARGB hex for the node/sheet color
  // The 4-6 words and phrases the situation needs, nothing else.
  final List<VocabWord> vocab;
  // How to use them in that situation, e.g. 'Order with "quiero" + the drink'.
  final List<String> grammarPoints;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.vocab,
    required this.grammarPoints,
  });

  @override
  List<Object?> get props => [id];
}

/// A level grouping lessons ("Débutant", "Intermédiaire", "Avancé").
class Level extends Equatable {
  final String id; // beginner | intermediate | advanced
  final List<Lesson> lessons;

  const Level({required this.id, required this.lessons});

  @override
  List<Object?> get props => [id, lessons];
}

/// A full course for one target language: the lesson path plus the extra
/// vocabulary bank feeding the "upcoming words" queue.
class Curriculum extends Equatable {
  final String language; // target language code: 'es', 'fr', 'pt', 'zh', 'en'
  final List<Level> levels;
  final List<VocabWord> extraVocabulary;

  const Curriculum({
    required this.language,
    required this.levels,
    required this.extraVocabulary,
  });

  /// Flat ordered list of every lesson across levels.
  List<Lesson> get lessons => levels.expand((l) => l.lessons).toList();

  @override
  List<Object?> get props => [language];
}
