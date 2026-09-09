import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/model/models.dart';
import '../../../core/service/analytics_service.dart';
import '../../../core/service/data_repository.dart';
import '../../profile/service/reminder_service.dart';
import '../../subscription/cubit/subscription_cubit.dart';
import '../../subscription/service/promo_service.dart';
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

  /// Marks onboarding done without writing a profile — used when an
  /// existing user signs in directly from the start page.
  Future<void> markComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);
    } catch (e) {
      debugPrint('[OnboardingCubit] markComplete error: $e');
    }
    emit(state.copyWith(isComplete: true));
    _step('direct_sign_in', {});
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

  /// App language chosen from the start-page flag picker.
  void setNativeLanguage(String code) {
    emit(state.copyWith(nativeLanguage: code));
    _step('native_language', {'language': code});
  }

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

  void setPromoCode(String code) =>
      emit(state.copyWith(promoCode: code, promoStatus: PromoStatus.none));

  /// Client-side validation only — the code is redeemed in
  /// [completeOnboarding], once the user's final uid is known.
  Future<void> submitPromoCode() async {
    final code = state.promoCode.trim();
    if (code.isEmpty) return;
    emit(state.copyWith(promoStatus: PromoStatus.checking));
    final result = await PromoService.validateCode(code);
    emit(state.copyWith(
      promoStatus: switch (result) {
        null => PromoStatus.invalid,
        PromoService.exhausted => PromoStatus.exhausted,
        _ => PromoStatus.valid,
      },
    ));
    _step('promo_code', {'status': state.promoStatus.name});
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

  /// Redeems the validated promo code onto the now-final uid. Failures are
  /// logged only — a bad code must never trap the user in the funnel.
  Future<void> _redeemPromoCode(SubscriptionCubit subscription) async {
    if (state.promoStatus != PromoStatus.valid) return;
    try {
      final userType = await PromoService.redeemCode(state.promoCode.trim());
      _analytics.track('promo_redeem_success', {'user_type': userType});
    } catch (e) {
      debugPrint('[OnboardingCubit] promo redeem error: $e');
      _analytics.track('promo_redeem_failed', {'reason': 'error'});
    }
    await subscription.refreshUserType();
  }

  /// Persists all answers into the user profile, redeems any validated promo
  /// code and marks onboarding done.
  Future<void> completeOnboarding(SubscriptionCubit subscription) async {
    if (_isCompleting) return;
    _isCompleting = true;
    try {
      final profile = UserProfile(
        nativeLanguage: state.nativeLanguage,
        targetLanguage: state.targetLanguage,
        level: _profileLevel,
        interests:
            state.interests.isEmpty ? const ['technology'] : state.interests,
        dailyGoalMinutes: state.dailyMinutes,
        reminderTime: state.practiceTime,
      );
      await _repository.saveProfile(profile);
      await _redeemPromoCode(subscription);
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
