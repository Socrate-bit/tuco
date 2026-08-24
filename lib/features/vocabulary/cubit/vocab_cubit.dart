import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/model/models.dart';
import '../../../core/service/data_repository.dart';
import '../../curriculum/data/curriculum_data.dart';
import '../../curriculum/model/curriculum_models.dart';

/// Learned words + upcoming curriculum words, scoped to the target language.
class VocabState extends Equatable {
  final List<LearnedWord> allLearned;
  final String targetLanguage;

  const VocabState({
    this.allLearned = const [],
    this.targetLanguage = 'es',
  });

  VocabState copyWith({
    List<LearnedWord>? allLearned,
    String? targetLanguage,
  }) =>
      VocabState(
        allLearned: allLearned ?? this.allLearned,
        targetLanguage: targetLanguage ?? this.targetLanguage,
      );

  /// Curriculum words per language (lessons + extra bank), deduplicated by
  /// word and cached on first use.
  static final Map<String, List<VocabWord>> _wordsByLanguage = {};

  static List<VocabWord> _wordsOf(String language) =>
      _wordsByLanguage.putIfAbsent(language, () {
        final curriculum = CurriculumData.of(language);
        final seen = <String>{};
        final all = <VocabWord>[];
        for (final lesson in curriculum.lessons) {
          for (final w in lesson.vocab) {
            if (seen.add(w.word)) all.add(w);
          }
        }
        for (final w in curriculum.extraVocabulary) {
          if (seen.add(w.word)) all.add(w);
        }
        return all;
      });

  /// Words learned in the language currently being studied.
  List<LearnedWord> get learned =>
      allLearned.where((w) => w.language == targetLanguage).toList();

  /// Curriculum words not learned yet.
  List<VocabWord> get upcoming {
    final learnedSet = learned.map((w) => w.word).toSet();
    return _wordsOf(targetLanguage)
        .where((w) => !learnedSet.contains(w.word))
        .toList();
  }

  int get learnedCount => learned.length;
  int get upcomingCount => upcoming.length;
  int get totalCount => _wordsOf(targetLanguage).length;

  @override
  List<Object?> get props => [allLearned, targetLanguage];
}

/// Streams the learned vocabulary and the target language.
class VocabCubit extends Cubit<VocabState> {
  final DataRepository _repo;
  StreamSubscription? _sub;
  StreamSubscription? _profileSub;

  VocabCubit(this._repo) : super(const VocabState()) {
    _sub = _repo.learnedWordsStream().listen(
      (words) => emit(state.copyWith(allLearned: words)),
      onError: (e) => debugPrint('[VocabCubit] stream error: $e'),
    );
    _profileSub = _repo.profileStream().listen(
      (profile) => emit(state.copyWith(targetLanguage: profile.targetLanguage)),
      onError: (e) => debugPrint('[VocabCubit] profile stream error: $e'),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _profileSub?.cancel();
    return super.close();
  }
}
