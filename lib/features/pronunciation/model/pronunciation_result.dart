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

/// Accuracy score of a single word plus its phoneme breakdown.
class WordScore extends Equatable {
  final String word;
  final double accuracyScore; // 0-100
  final String errorType; // 'None' | 'Mispronunciation' | 'Omission' | ...
  final List<PhonemeScore> phonemes;

  const WordScore({
    required this.word,
    required this.accuracyScore,
    this.errorType = 'None',
    this.phonemes = const [],
  });

  Map<String, dynamic> toMap() => {
        'w': word,
        'a': accuracyScore,
        'e': errorType,
        'ph': phonemes.map((p) => p.toMap()).toList(),
      };

  factory WordScore.fromMap(Map<String, dynamic> map) => WordScore(
        word: map['w'] as String? ?? '',
        accuracyScore: (map['a'] as num?)?.toDouble() ?? 0,
        errorType: map['e'] as String? ?? 'None',
        phonemes: (map['ph'] as List?)
                ?.map((p) => PhonemeScore.fromMap(Map<String, dynamic>.from(p)))
                .toList() ??
            const [],
      );

  @override
  List<Object?> get props => [word, accuracyScore, errorType, phonemes];
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
  /// Returns null when recognition failed or no NBest candidate exists.
  static PronunciationResult? fromAzureJson(Map<String, dynamic> json) {
    final status = json['RecognitionStatus'] as String?;
    final nbest = json['NBest'] as List?;
    if (status != 'Success' || nbest == null || nbest.isEmpty) return null;
    final best = Map<String, dynamic>.from(nbest.first as Map);

    final words = <WordScore>[];
    for (final raw in (best['Words'] as List? ?? const [])) {
      final w = Map<String, dynamic>.from(raw as Map);
      final wpa = Map<String, dynamic>.from(
          (w['PronunciationAssessment'] as Map?) ?? const {});
      final phonemes = <PhonemeScore>[];
      for (final rp in (w['Phonemes'] as List? ?? const [])) {
        final p = Map<String, dynamic>.from(rp as Map);
        final ppa = Map<String, dynamic>.from(
            (p['PronunciationAssessment'] as Map?) ?? const {});
        phonemes.add(PhonemeScore(
          phoneme: p['Phoneme'] as String? ?? '',
          accuracyScore: (ppa['AccuracyScore'] as num?)?.toDouble() ?? 0,
        ));
      }
      words.add(WordScore(
        word: w['Word'] as String? ?? '',
        accuracyScore: (wpa['AccuracyScore'] as num?)?.toDouble() ?? 0,
        errorType: wpa['ErrorType'] as String? ?? 'None',
        phonemes: phonemes,
      ));
    }

    return PronunciationResult(
      recognizedText:
          json['DisplayText'] as String? ?? best['Display'] as String? ?? '',
      pronScore: (best['PronScore'] as num?)?.toDouble() ?? 0,
      accuracyScore: (best['AccuracyScore'] as num?)?.toDouble() ?? 0,
      fluencyScore: (best['FluencyScore'] as num?)?.toDouble() ?? 0,
      completenessScore: (best['CompletenessScore'] as num?)?.toDouble() ?? 0,
      prosodyScore: (best['ProsodyScore'] as num?)?.toDouble(),
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
