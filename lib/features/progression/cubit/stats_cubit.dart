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

  StatsState({this.calls = const [], this.practiceDays = const []});

  /// Practice days indexed by 'yyyy-MM-dd', built once per state.
  late final Map<String, PracticeDay> _byDate = {
    for (final d in practiceDays) d.date: d
  };

  /// A day counts as practiced when the user completed a lesson **or** spent
  /// any time on a call. Single definition shared by the streak, the calendar
  /// and the week fire row so they can never disagree.
  static bool _practiced(PracticeDay? day) =>
      (day?.lessonsCompleted ?? 0) > 0 || (day?.callSeconds ?? 0) > 0;

  bool practicedOn(DateTime day) =>
      _practiced(_byDate[DataRepository.dayKey(day)]);

  /// Current streak: consecutive practice days ending today (or yesterday when
  /// today has no practice yet).
  int get currentStreak {
    var day = DataRepository.today();
    if (!practicedOn(day)) day = DataRepository.addDays(day, -1);
    var streak = 0;
    while (practicedOn(day)) {
      streak++;
      day = DataRepository.addDays(day, -1);
    }
    return streak;
  }

  /// Longest streak across all recorded days.
  int get longestStreak {
    final days = practiceDays
        .where(_practiced)
        .map((d) => DataRepository.parseDayKey(d.date))
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
        final date = DataRepository.parseDayKey(d.date);
        return date.year == month.year && date.month == month.month;
      })
      .fold(0, (sum, d) => sum + d.lessonsCompleted);

  int get totalCallSeconds =>
      practiceDays.fold(0, (sum, d) => sum + d.callSeconds);

  int get averageCallSeconds =>
      calls.isEmpty ? 0 : totalCallSeconds ~/ calls.length;

  /// Call seconds for each of the last 7 days (oldest first, today last).
  List<MapEntry<DateTime, int>> get last7Days {
    final today = DataRepository.today();
    return List.generate(7, (i) {
      final day = DataRepository.addDays(today, i - 6);
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

  StatsCubit(this._repo) : super(StatsState()) {
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
