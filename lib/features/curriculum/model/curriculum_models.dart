import 'package:equatable/equatable.dart';

/// A vocabulary entry: target-language word + native translation.
class VocabWord extends Equatable {
  final String word;
  final String translation;

  const VocabWord({required this.word, required this.translation});

  @override
  List<Object?> get props => [word, translation];
}

/// A single lesson on the path.
class Lesson extends Equatable {
  final String id;
  final String title; // target-language title, e.g. "¡Hola Y Adiós!"
  final String description; // short native-language description
  final String icon; // material icon key (see LessonIcons)
  final int color; // ARGB hex for the node/sheet color
  final List<VocabWord> vocab;
  final List<String> grammarPoints; // e.g. ['"Me llamo…", "Soy de…"']

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
