import 'package:equatable/equatable.dart';

/// Accuracy score of a single phoneme within a word.
class PhonemeScore extends Equatable {
  final String phoneme; // IPA symbol, e.g. "ɪ"
  final double accuracyScore; // 0-100

  const PhonemeScore({required this.phoneme, required this.accuracyScore});

  Map<String, dynamic> toMap() => {'p': phoneme, 'a': accuracyScore};

  factory PhonemeScore.fromMap(Map<String, dynamic> map) => PhonemeScore(
        phoneme: map['p'] as String? ?? '',
        accuracyScore: (map['a'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [phoneme, accuracyScore];
}

/// Accuracy score of a single syllable, labelled by its grapheme (letters).
/// Graphemes are returned for all locales, unlike phoneme symbols.
class SyllableScore extends Equatable {
  final String grapheme; // e.g. "gra", "cias"
  final double accuracyScore; // 0-100

  const SyllableScore({required this.grapheme, required this.accuracyScore});

  Map<String, dynamic> toMap() => {'g': grapheme, 'a': accuracyScore};

  factory SyllableScore.fromMap(Map<String, dynamic> map) => SyllableScore(
        grapheme: map['g'] as String? ?? '',
        accuracyScore: (map['a'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [grapheme, accuracyScore];
}

/// Accuracy score of a single word plus its syllable/phoneme breakdown.
class WordScore extends Equatable {
  final String word;
  final double accuracyScore; // 0-100
  final String errorType; // 'None' | 'Mispronunciation' | 'Omission' | ...
  final List<SyllableScore> syllables;
  final List<PhonemeScore> phonemes;

  const WordScore({
    required this.word,
    required this.accuracyScore,
    this.errorType = 'None',
    this.syllables = const [],
    this.phonemes = const [],
  });

  Map<String, dynamic> toMap() => {
        'w': word,
        'a': accuracyScore,
        'e': errorType,
        'sy': syllables.map((s) => s.toMap()).toList(),
        'ph': phonemes.map((p) => p.toMap()).toList(),
      };

  factory WordScore.fromMap(Map<String, dynamic> map) => WordScore(
        word: map['w'] as String? ?? '',
        accuracyScore: (map['a'] as num?)?.toDouble() ?? 0,
        errorType: map['e'] as String? ?? 'None',
        syllables: (map['sy'] as List?)
                ?.map(
                    (s) => SyllableScore.fromMap(Map<String, dynamic>.from(s)))
                .toList() ??
            const [],
        phonemes: (map['ph'] as List?)
                ?.map((p) => PhonemeScore.fromMap(Map<String, dynamic>.from(p)))
                .toList() ??
            const [],
      );

  @override
  List<Object?> get props =>
      [word, accuracyScore, errorType, syllables, phonemes];
}

/// Result of an Azure Speech pronunciation assessment for one utterance.
class PronunciationResult extends Equatable {
  final String recognizedText;
  final double pronScore; // overall 0-100 (drives the ring)
  final double accuracyScore;
  final double fluencyScore;
  final double completenessScore;
  final double? prosodyScore; // en-US only; null elsewhere
  final List<WordScore> words;

  const PronunciationResult({
    required this.recognizedText,
    required this.pronScore,
    this.accuracyScore = 0,
    this.fluencyScore = 0,
    this.completenessScore = 0,
    this.prosodyScore,
    this.words = const [],
  });

  /// Parse an Azure short-audio pronunciation-assessment JSON response.
  ///
  /// Azure serializes scores in two shapes depending on the surface: the REST
  /// short-audio endpoint puts them flat on each object (e.g. `AccuracyScore`),
  /// while the SDK's detailed result nests them under `PronunciationAssessment`.
  /// We read flat first and fall back to the nested object so both work.
  ///
  /// Returns null when recognition failed or no NBest candidate exists.
  static PronunciationResult? fromAzureJson(Map<String, dynamic> json) {
    // RecognitionStatus is a string ("Success") on the REST endpoint but an
    // int (0) in the SDK JSON — accept both.
    final status = json['RecognitionStatus'];
    final ok = status == 'Success' || status == 0;
    final nbest = json['NBest'] as List?;
    if (!ok || nbest == null || nbest.isEmpty) return null;
    final best = Map<String, dynamic>.from(nbest.first as Map);

    // Reads [key] flat on [m], else from a nested "PronunciationAssessment".
    double scoreOf(Map<String, dynamic> m, String key) {
      final flat = (m[key] as num?)?.toDouble();
      if (flat != null) return flat;
      final nested = m['PronunciationAssessment'] as Map?;
      return (nested?[key] as num?)?.toDouble() ?? 0;
    }

    final words = <WordScore>[];
    for (final raw in (best['Words'] as List? ?? const [])) {
      final w = Map<String, dynamic>.from(raw as Map);
      final nested = w['PronunciationAssessment'] as Map?;
      final syllables = <SyllableScore>[];
      for (final rs in (w['Syllables'] as List? ?? const [])) {
        final s = Map<String, dynamic>.from(rs as Map);
        syllables.add(SyllableScore(
          // Grapheme (letters) is present for all locales; Syllable (phonetic)
          // is empty except en-US / zh-CN.
          grapheme: s['Grapheme'] as String? ?? s['Syllable'] as String? ?? '',
          accuracyScore: scoreOf(s, 'AccuracyScore'),
        ));
      }
      final phonemes = <PhonemeScore>[];
      for (final rp in (w['Phonemes'] as List? ?? const [])) {
        final p = Map<String, dynamic>.from(rp as Map);
        phonemes.add(PhonemeScore(
          phoneme: p['Phoneme'] as String? ?? '',
          accuracyScore: scoreOf(p, 'AccuracyScore'),
        ));
      }
      words.add(WordScore(
        word: w['Word'] as String? ?? '',
        accuracyScore: scoreOf(w, 'AccuracyScore'),
        errorType: w['ErrorType'] as String? ??
            nested?['ErrorType'] as String? ??
            'None',
        syllables: syllables,
        phonemes: phonemes,
      ));
    }

    return PronunciationResult(
      recognizedText:
          json['DisplayText'] as String? ?? best['Display'] as String? ?? '',
      pronScore: scoreOf(best, 'PronScore'),
      accuracyScore: scoreOf(best, 'AccuracyScore'),
      fluencyScore: scoreOf(best, 'FluencyScore'),
      completenessScore: scoreOf(best, 'CompletenessScore'),
      prosodyScore: (best['ProsodyScore'] as num?)?.toDouble() ??
          ((best['PronunciationAssessment'] as Map?)?['ProsodyScore'] as num?)
              ?.toDouble(),
      words: words,
    );
  }

  Map<String, dynamic> toMap() => {
        'text': recognizedText,
        'pron': pronScore,
        'acc': accuracyScore,
        'flu': fluencyScore,
        'comp': completenessScore,
        'pros': prosodyScore,
        'words': words.map((w) => w.toMap()).toList(),
      };

  factory PronunciationResult.fromMap(Map<String, dynamic> map) =>
      PronunciationResult(
        recognizedText: map['text'] as String? ?? '',
        pronScore: (map['pron'] as num?)?.toDouble() ?? 0,
        accuracyScore: (map['acc'] as num?)?.toDouble() ?? 0,
        fluencyScore: (map['flu'] as num?)?.toDouble() ?? 0,
        completenessScore: (map['comp'] as num?)?.toDouble() ?? 0,
        prosodyScore: (map['pros'] as num?)?.toDouble(),
        words: (map['words'] as List?)
                ?.map((w) => WordScore.fromMap(Map<String, dynamic>.from(w)))
                .toList() ??
            const [],
      );

  @override
  List<Object?> get props => [
        recognizedText,
        pronScore,
        accuracyScore,
        fluencyScore,
        completenessScore,
        prosodyScore,
        words,
      ];
}
