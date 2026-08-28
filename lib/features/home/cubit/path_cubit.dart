import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/service/data_repository.dart';
import '../../curriculum/data/curriculum_data.dart';
import '../../curriculum/model/curriculum_models.dart';

/// Status of a lesson node on the path.
/// [unlocked] = below the learner's declared level: playable for review but
/// not done yet.
enum LessonStatus { completed, current, unlocked, locked }

class PathState extends Equatable {
  final Set<String> completedLessons;
  final String targetLanguage;
  final String level; // beginner | intermediate | advanced (onboarding answer)

  const PathState({
    this.completedLessons = const {},
    this.targetLanguage = 'es',
    this.level = 'beginner',
  });

  PathState copyWith({
    Set<String>? completedLessons,
    String? targetLanguage,
    String? level,
  }) =>
      PathState(
        completedLessons: completedLessons ?? this.completedLessons,
        targetLanguage: targetLanguage ?? this.targetLanguage,
        level: level ?? this.level,
      );

  /// Levels of the curriculum currently being learned.
  List<Level> get levels => CurriculumData.levelsOf(targetLanguage);

  /// Flat ordered list of all lessons across levels.
  List<Lesson> get allLessons => CurriculumData.of(targetLanguage).lessons;

  /// Index of the learner's level in the curriculum (0 when unknown).
  int get _levelIndex {
    final i = levels.indexWhere((l) => l.id == level);
    return i < 0 ? 0 : i;
  }

  /// Position in [allLessons] of the first lesson of the learner's level.
  /// Everything before it belongs to a lower level: unlocked from the start.
  int get startIndex =>
      levels.take(_levelIndex).fold(0, (n, l) => n + l.lessons.length);

  /// The next lesson to take: first not completed at or after the level the
  /// learner declared during onboarding.
  Lesson get currentLesson {
    final all = allLessons;
    for (var i = startIndex; i < all.length; i++) {
      if (!completedLessons.contains(all[i].id)) return all[i];
    }
    return all.last;
  }

  LessonStatus statusOf(Lesson lesson) {
    if (completedLessons.contains(lesson.id)) return LessonStatus.completed;
    if (lesson.id == currentLesson.id) return LessonStatus.current;
    // Lessons of the levels below the learner's own stay open for review.
    final i = allLessons.indexWhere((l) => l.id == lesson.id);
    if (i >= 0 && i < startIndex) return LessonStatus.unlocked;
    return LessonStatus.locked;
  }

  /// Lesson coming right after [lesson] on the path (or null at the end).
  Lesson? lessonAfter(Lesson lesson) {
    final all = allLessons;
    final i = all.indexWhere((l) => l.id == lesson.id);
    return (i >= 0 && i + 1 < all.length) ? all[i + 1] : null;
  }

  @override
  List<Object?> get props => [completedLessons, targetLanguage, level];
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
      (profile) {
        emit(state.copyWith(
          targetLanguage: profile.targetLanguage,
          level: profile.level,
        ));
        debugPrint('[PathCubit] ${profile.targetLanguage} path at level '
            '${profile.level}: ${state.startIndex} lessons unlocked upfront');
      },
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
