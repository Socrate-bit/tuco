import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/service/data_repository.dart';
import '../../curriculum/data/curriculum_data.dart';
import '../../curriculum/model/curriculum_models.dart';

/// Status of a lesson node on the path.
enum LessonStatus { completed, current, locked }

class PathState extends Equatable {
  final Set<String> completedLessons;
  final String targetLanguage;

  const PathState({
    this.completedLessons = const {},
    this.targetLanguage = 'es',
  });

  PathState copyWith({
    Set<String>? completedLessons,
    String? targetLanguage,
  }) =>
      PathState(
        completedLessons: completedLessons ?? this.completedLessons,
        targetLanguage: targetLanguage ?? this.targetLanguage,
      );

  /// Levels of the curriculum currently being learned.
  List<Level> get levels => CurriculumData.levelsOf(targetLanguage);

  /// Flat ordered list of all lessons across levels.
  List<Lesson> get allLessons => CurriculumData.of(targetLanguage).lessons;

  /// The next lesson to take (first not completed).
  Lesson get currentLesson => allLessons.firstWhere(
        (l) => !completedLessons.contains(l.id),
        orElse: () => allLessons.last,
      );

  LessonStatus statusOf(Lesson lesson) {
    if (completedLessons.contains(lesson.id)) return LessonStatus.completed;
    if (lesson.id == currentLesson.id) return LessonStatus.current;
    return LessonStatus.locked;
  }

  /// Lesson coming right after [lesson] on the path (or null at the end).
  Lesson? lessonAfter(Lesson lesson) {
    final all = allLessons;
    final i = all.indexWhere((l) => l.id == lesson.id);
    return (i >= 0 && i + 1 < all.length) ? all[i + 1] : null;
  }

  @override
  List<Object?> get props => [completedLessons, targetLanguage];
}

/// Tracks lesson completion and the target language to drive the home path.
class PathCubit extends Cubit<PathState> {
  final DataRepository _repo;
  StreamSubscription? _sub;
  StreamSubscription? _profileSub;

  PathCubit(this._repo) : super(const PathState()) {
    _sub = _repo.completedLessonsStream().listen(
      (completed) => emit(state.copyWith(completedLessons: completed)),
      onError: (e) => debugPrint('[PathCubit] stream error: $e'),
    );
    _profileSub = _repo.profileStream().listen(
      (profile) => emit(state.copyWith(targetLanguage: profile.targetLanguage)),
      onError: (e) => debugPrint('[PathCubit] profile stream error: $e'),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _profileSub?.cancel();
    return super.close();
  }
}
