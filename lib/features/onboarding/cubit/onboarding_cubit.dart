import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/model/models.dart';
import '../../../core/service/analytics_service.dart';
import '../../../core/service/data_repository.dart';
import '../../profile/service/reminder_service.dart';
import 'onboarding_state.dart';

/// Holds the onboarding answers and persists them on completion.
/// Page navigation lives in the screen; the cubit only owns data.
class OnboardingCubit extends Cubit<OnboardingState> {
  static const _prefsKey = 'onboarding_complete';

  final DataRepository _repository;
  final AnalyticsService _analytics;
  bool _isCompleting = false;

  OnboardingCubit(this._repository, this._analytics,
      {bool alreadyComplete = false})
      : super(OnboardingState(isComplete: alreadyComplete));

  /// Reads the local "onboarding done" flag before the app builds.
  static Future<bool> readCompletedFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefsKey) ?? false;
    } catch (e) {
      debugPrint('[OnboardingCubit] readCompletedFlag error: $e');
      return false;
    }
  }

  /// Clears the completion flag and answers (account deletion / reset).
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (e) {
      debugPrint('[OnboardingCubit] reset error: $e');
    }
    emit(const OnboardingState());
    debugPrint('[OnboardingCubit] Onboarding reset');
  }

  void _step(String step, Map<String, dynamic> props) =>
      _analytics.track('onboarding_step', {'step': step, ...props});

  void setTargetLanguage(String code) {
    emit(state.copyWith(targetLanguage: code));
    _step('language', {'language': code});
  }

  void setLevel(String level) {
    emit(state.copyWith(level: level));
    _step('level', {'level': level});
  }

  void toggleChallenge(String id) {
    final list = List<String>.from(state.challenges);
    list.contains(id) ? list.remove(id) : list.add(id);
    emit(state.copyWith(challenges: list));
  }

  void toggleInterest(String id) {
    final list = List<String>.from(state.interests);
    list.contains(id) ? list.remove(id) : list.add(id);
    emit(state.copyWith(interests: list));
  }

  void setFluencyMonths(int months) =>
      emit(state.copyWith(fluencyMonths: months));

  void setDailyMinutes(int minutes) =>
      emit(state.copyWith(dailyMinutes: minutes));

  void setPracticeTime(String hhmm) {
    emit(state.copyWith(practiceTime: hhmm));
    _step('practice_time', {'time': hhmm});
  }

  /// Fires the iOS notification prompt; called by the notification step.
  Future<void> requestNotifications() async {
    final granted = await ReminderService.requestPermission();
    emit(state.copyWith(notificationsAsked: true));
    _step('notifications', {'granted': granted});
  }

  /// Maps the 5-option survey level onto the profile's 3 levels.
  String get _profileLevel => switch (state.level) {
        'new' || 'someWords' => 'beginner',
        'basic' || 'various' => 'intermediate',
        _ => 'advanced',
      };

  /// Persists all answers into the user profile and marks onboarding done.
  Future<void> completeOnboarding() async {
    if (_isCompleting) return;
    _isCompleting = true;
    try {
      final profile = UserProfile(
        targetLanguage: state.targetLanguage,
        level: _profileLevel,
        interests:
            state.interests.isEmpty ? const ['technology'] : state.interests,
        dailyGoalMinutes: state.dailyMinutes,
        reminderTime: state.practiceTime,
      );
      await _repository.saveProfile(profile);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);
      emit(state.copyWith(isComplete: true));
      _step('complete', {
        'challenges': state.challenges,
        'fluency_months': state.fluencyMonths,
        'daily_minutes': state.dailyMinutes,
      });
      debugPrint('[OnboardingCubit] Onboarding completed and saved');
    } catch (e) {
      debugPrint('[OnboardingCubit] completeOnboarding error: $e');
      emit(state.copyWith(isComplete: true)); // never trap the user
    } finally {
      _isCompleting = false;
    }
  }
}
