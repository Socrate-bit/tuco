import 'package:equatable/equatable.dart';

/// Client-side validation state of the promo code entered in the funnel.
enum PromoStatus { none, checking, valid, invalid, exhausted }

/// All answers collected during the onboarding funnel.
/// Flat immutable model — the screen owns page navigation, not this state.
class OnboardingState extends Equatable {
  final String nativeLanguage; // app language picked on the start page
  final String targetLanguage; // 'es', ...
  final String? level; // beginner | someWords | basic | various | detailed
  final List<String> challenges; // multi-select challenge ids
  final List<String> interests; // multi-select topic ids
  final int fluencyMonths; // fluency goal in months (1-24)
  final int dailyMinutes; // practice goal per day (5-60)
  final String? practiceTime; // 'HH:mm' preferred practice time
  final bool notificationsAsked;
  final String promoCode;
  final PromoStatus promoStatus;
  final bool isComplete;

  const OnboardingState({
    this.nativeLanguage = 'en',
    this.targetLanguage = 'es',
    this.level,
    this.challenges = const [],
    this.interests = const [],
    this.fluencyMonths = 12,
    this.dailyMinutes = 15,
    this.practiceTime,
    this.notificationsAsked = false,
    this.promoCode = '',
    this.promoStatus = PromoStatus.none,
    this.isComplete = false,
  });

  OnboardingState copyWith({
    String? nativeLanguage,
    String? targetLanguage,
    String? level,
    List<String>? challenges,
    List<String>? interests,
    int? fluencyMonths,
    int? dailyMinutes,
    String? practiceTime,
    bool? notificationsAsked,
    String? promoCode,
    PromoStatus? promoStatus,
    bool? isComplete,
  }) =>
      OnboardingState(
        nativeLanguage: nativeLanguage ?? this.nativeLanguage,
        targetLanguage: targetLanguage ?? this.targetLanguage,
        level: level ?? this.level,
        challenges: challenges ?? this.challenges,
        interests: interests ?? this.interests,
        fluencyMonths: fluencyMonths ?? this.fluencyMonths,
        dailyMinutes: dailyMinutes ?? this.dailyMinutes,
        practiceTime: practiceTime ?? this.practiceTime,
        notificationsAsked: notificationsAsked ?? this.notificationsAsked,
        promoCode: promoCode ?? this.promoCode,
        promoStatus: promoStatus ?? this.promoStatus,
        isComplete: isComplete ?? this.isComplete,
      );

  @override
  List<Object?> get props => [
        nativeLanguage,
        targetLanguage,
        level,
        challenges,
        interests,
        fluencyMonths,
        dailyMinutes,
        practiceTime,
        notificationsAsked,
        promoCode,
        promoStatus,
        isComplete,
      ];
}
