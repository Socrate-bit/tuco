import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/model/models.dart';
import '../../../core/service/data_repository.dart';

/// Aggregated stats: call history, call time, streaks.
class StatsState extends Equatable {
  final List<CallRecord> calls;
  final List<PracticeDay> practiceDays;

  const StatsState({this.calls = const [], this.practiceDays = const []});

  Map<String, PracticeDay> get _byDate =>
      {for (final d in practiceDays) d.date: d};

  bool practicedOn(DateTime day) =>
      (_byDate[DataRepository.dayKey(day)]?.lessonsCompleted ?? 0) > 0 ||
      (_byDate[DataRepository.dayKey(day)]?.callSeconds ?? 0) > 0;

  /// Days with at least one completed lesson count for the streak.
  bool _streakDay(DateTime day) =>
      (_byDate[DataRepository.dayKey(day)]?.lessonsCompleted ?? 0) > 0;

  /// Current streak: consecutive lesson-days ending today (or yesterday).
  int get currentStreak {
    var day = DateTime.now();
    if (!_streakDay(day)) day = day.subtract(const Duration(days: 1));
    var streak = 0;
    while (_streakDay(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Longest streak across all recorded days.
  int get longestStreak {
    final days = practiceDays
        .where((d) => d.lessonsCompleted > 0)
        .map((d) => DateTime.parse(d.date))
        .toList()
      ..sort();
    var longest = 0, run = 0;
    DateTime? prev;
    for (final d in days) {
      run = (prev != null && d.difference(prev).inDays == 1) ? run + 1 : 1;
      if (run > longest) longest = run;
      prev = d;
    }
    return longest;
  }

  /// Lessons completed during [month].
  int trainingsInMonth(DateTime month) => practiceDays
      .where((d) {
        final date = DateTime.parse(d.date);
        return date.year == month.year && date.month == month.month;
      })
      .fold(0, (sum, d) => sum + d.lessonsCompleted);

  int get totalCallSeconds =>
      practiceDays.fold(0, (sum, d) => sum + d.callSeconds);

  int get averageCallSeconds =>
      calls.isEmpty ? 0 : totalCallSeconds ~/ calls.length;

  /// Call seconds for each of the last 7 days (oldest first, today last).
  List<MapEntry<DateTime, int>> get last7Days {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return MapEntry(day, _byDate[DataRepository.dayKey(day)]?.callSeconds ?? 0);
    });
  }

  @override
  List<Object?> get props => [calls, practiceDays];
}

/// Streams calls + practice days into aggregated stats.
class StatsCubit extends Cubit<StatsState> {
  final DataRepository _repo;
  StreamSubscription? _callsSub;
  StreamSubscription? _daysSub;

  StatsCubit(this._repo) : super(const StatsState()) {
    _callsSub = _repo.callsStream().listen(
      (calls) => emit(StatsState(calls: calls, practiceDays: state.practiceDays)),
      onError: (e) => debugPrint('[StatsCubit] calls stream error: $e'),
    );
    _daysSub = _repo.practiceDaysStream().listen(
      (days) => emit(StatsState(calls: state.calls, practiceDays: days)),
      onError: (e) => debugPrint('[StatsCubit] days stream error: $e'),
    );
  }

  @override
  Future<void> close() {
    _callsSub?.cancel();
    _daysSub?.cancel();
    return super.close();
  }
}
