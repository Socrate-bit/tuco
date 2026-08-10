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

  const PathState({this.completedLessons = const {}});

  /// Flat ordered list of all lessons across levels.
  List<Lesson> get allLessons =>
      CurriculumData.levels.expand((l) => l.lessons).toList();

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
  List<Object?> get props => [completedLessons];
}

/// Tracks lesson completion to drive the home path.
class PathCubit extends Cubit<PathState> {
  final DataRepository _repo;
  StreamSubscription? _sub;

  PathCubit(this._repo) : super(const PathState()) {
    _sub = _repo.completedLessonsStream().listen(
      (completed) => emit(PathState(completedLessons: completed)),
      onError: (e) => debugPrint('[PathCubit] stream error: $e'),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
