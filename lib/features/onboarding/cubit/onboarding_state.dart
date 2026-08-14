import 'package:equatable/equatable.dart';

/// All answers collected during the onboarding funnel.
/// Flat immutable model — the screen owns page navigation, not this state.
class OnboardingState extends Equatable {
  final String targetLanguage; // 'es', ...
  final String? level; // beginner | someWords | basic | various | detailed
  final List<String> challenges; // multi-select challenge ids
  final List<String> interests; // multi-select topic ids
  final int fluencyMonths; // fluency goal in months (1-24)
  final int dailyMinutes; // practice goal per day (5-60)
  final String? practiceTime; // 'HH:mm' preferred practice time
  final bool notificationsAsked;
  final bool isComplete;

  const OnboardingState({
    this.targetLanguage = 'es',
    this.level,
    this.challenges = const [],
    this.interests = const [],
    this.fluencyMonths = 12,
    this.dailyMinutes = 15,
    this.practiceTime,
    this.notificationsAsked = false,
    this.isComplete = false,
  });

  OnboardingState copyWith({
    String? targetLanguage,
    String? level,
    List<String>? challenges,
    List<String>? interests,
    int? fluencyMonths,
    int? dailyMinutes,
    String? practiceTime,
    bool? notificationsAsked,
    bool? isComplete,
  }) =>
      OnboardingState(
        targetLanguage: targetLanguage ?? this.targetLanguage,
        level: level ?? this.level,
        challenges: challenges ?? this.challenges,
        interests: interests ?? this.interests,
        fluencyMonths: fluencyMonths ?? this.fluencyMonths,
        dailyMinutes: dailyMinutes ?? this.dailyMinutes,
        practiceTime: practiceTime ?? this.practiceTime,
        notificationsAsked: notificationsAsked ?? this.notificationsAsked,
        isComplete: isComplete ?? this.isComplete,
      );

  @override
  List<Object?> get props => [
        targetLanguage,
        level,
        challenges,
        interests,
        fluencyMonths,
        dailyMinutes,
        practiceTime,
        notificationsAsked,
        isComplete,
      ];
}
