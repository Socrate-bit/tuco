import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/model/models.dart';
import '../../../core/service/data_repository.dart';
import '../../curriculum/data/curriculum_data.dart';
import '../../curriculum/model/curriculum_models.dart';

/// Learned words + upcoming curriculum words.
class VocabState extends Equatable {
  final List<LearnedWord> learned;

  const VocabState({this.learned = const []});

  /// All curriculum words (lessons + extra bank), deduplicated by word.
  static final List<VocabWord> _allWords = () {
    final seen = <String>{};
    final all = <VocabWord>[];
    for (final level in CurriculumData.levels) {
      for (final lesson in level.lessons) {
        for (final w in lesson.vocab) {
          if (seen.add(w.word)) all.add(w);
        }
      }
    }
    for (final w in CurriculumData.extraVocabulary) {
      if (seen.add(w.word)) all.add(w);
    }
    return all;
  }();

  /// Curriculum words not learned yet.
  List<VocabWord> get upcoming {
    final learnedSet = learned.map((w) => w.word).toSet();
    return _allWords.where((w) => !learnedSet.contains(w.word)).toList();
  }

  int get learnedCount => learned.length;
  int get upcomingCount => upcoming.length;
  int get totalCount => _allWords.length;

  @override
  List<Object?> get props => [learned];
}

/// Streams the learned-vocabulary collection.
class VocabCubit extends Cubit<VocabState> {
  final DataRepository _repo;
  StreamSubscription? _sub;

  VocabCubit(this._repo) : super(const VocabState()) {
    _sub = _repo.learnedWordsStream().listen(
      (words) => emit(VocabState(learned: words)),
      onError: (e) => debugPrint('[VocabCubit] stream error: $e'),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
