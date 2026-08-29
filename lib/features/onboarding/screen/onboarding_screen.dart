import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../subscription/cubit/subscription_cubit.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widget/comparison_bars.dart';
import '../widget/free_trial_step.dart';
import '../widget/info_step.dart';
import '../widget/loading_step.dart';
import '../widget/notification_step.dart';
import '../widget/plan_ready_step.dart';
import '../widget/promo_code_step.dart';
import '../widget/progress_chart.dart';
import '../widget/rating_step.dart';
import '../widget/sign_in_step.dart';
import '../widget/slider_step.dart';
import '../widget/survey_step.dart';
import '../widget/time_picker_step.dart';
import '../widget/welcome_step.dart';

/// One page of the onboarding funnel, declared as data so navigation,
/// progress and the shared Continue button stay generic.
class _OnboardingStep {
  final Widget Function(BuildContext, OnboardingState, OnboardingCubit) build;
  final bool ownNavigation; // page renders its own CTA
  final bool Function(OnboardingState)? canContinue;
  final Future<void> Function(BuildContext)? onContinue; // side effect

  const _OnboardingStep({
    required this.build,
    this.ownNavigation = false,
    this.canContinue,
    this.onContinue,
  });
}

/// Onboarding funnel: single PageView driven by a declarative step list.
/// The cubit only holds answers; the current page index is local state.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------- Step list ----------------

  String _fluentByLabel(BuildContext context, int months) {
    final target = DateTime.now().add(Duration(days: months * 30));
    return DateFormat.yMMMM(Localizations.localeOf(context).toString())
        .format(target);
  }

  List<_OnboardingStep> _steps(AppLocalizations l10n) => [
        // 0: Tuco start page
        _OnboardingStep(
          ownNavigation: true,
          build: (context, state, cubit) => WelcomeStep(
            onStart: _next,
            onSignIn: () => _pushDirectSignIn(cubit),
          ),
        ),
        // 1: Meet Tuco your new companion
        _OnboardingStep(
          build: (context, state, cubit) => MeetTucoStep(
            title: l10n.onboardingMeetTitle,
            subtitle: l10n.onboardingMeetSubtitle,
          ),
        ),
        // 2: What language do you want to learn?
        _OnboardingStep(
          canContinue: (s) => true,
          build: (context, state, cubit) => SurveyStep(
            title: l10n.onboardingLanguageTitle,
            options: [
              SurveyOption(
                  id: 'es',
                  label: l10n.onboardingLanguageEs,
                  icon: Text('🇪🇸', style: TextStyle(fontSize: 24.sp))),
              SurveyOption(
                  id: 'en',
                  label: l10n.onboardingLanguageEn,
                  icon: Text('🇬🇧', style: TextStyle(fontSize: 24.sp))),
              SurveyOption(
                  id: 'fr',
                  label: l10n.onboardingLanguageFr,
                  icon: Text('🇫🇷', style: TextStyle(fontSize: 24.sp))),
            ],
            selected: {state.targetLanguage},
            onTap: cubit.setTargetLanguage,
          ),
        ),
        // 3: What is your Spanish level?
        _OnboardingStep(
          canContinue: (s) => s.level != null,
          build: (context, state, cubit) => SurveyStep(
            title: l10n.onboardingLevelTitle,
            subtitle: l10n.onboardingLevelSubtitle,
            options: [
              for (final (id, label, bars) in [
                ('new', l10n.onboardingLevelNew, 1),
                ('someWords', l10n.onboardingLevelSomeWords, 2),
                ('basic', l10n.onboardingLevelBasic, 3),
                ('various', l10n.onboardingLevelVarious, 4),
                ('detailed', l10n.onboardingLevelDetailed, 5),
              ])
                SurveyOption(id: id, label: label, icon: _LevelBars(bars)),
            ],
            selected: {if (state.level != null) state.level!},
            onTap: cubit.setLevel,
          ),
        ),
        // 4: What are your main challenges?
        _OnboardingStep(
          canContinue: (s) => s.challenges.isNotEmpty,
          build: (context, state, cubit) => SurveyStep(
            title: l10n.onboardingChallengesTitle,
            subtitle: l10n.onboardingMultiSelectHint,
            options: [
              for (final (id, label, emoji) in [
                ('speaking', l10n.onboardingChallengeSpeaking, '🗣️'),
                ('vocabulary', l10n.onboardingChallengeVocabulary, '📚'),
                ('consistency', l10n.onboardingChallengeConsistency, '📅'),
                ('confidence', l10n.onboardingChallengeConfidence, '💪'),
                ('listening', l10n.onboardingChallengeListening, '👂'),
                ('other', l10n.onboardingChallengeOther, '✨'),
              ])
                SurveyOption(
                    id: id,
                    label: label,
                    icon: Text(emoji, style: TextStyle(fontSize: 24.sp))),
            ],
            selected: state.challenges.toSet(),
            onTap: cubit.toggleChallenge,
          ),
        ),
        // 5: EDUCATION — Tuco creates long-term results
        _OnboardingStep(
          build: (context, state, cubit) => InfoStep(
            title: l10n.onboardingEducation1Title,
            subtitle: l10n.onboardingEducation1Subtitle,
            child: const ProgressChart(),
          ),
        ),
        // 6: What are your topics of interest?
        _OnboardingStep(
          canContinue: (s) => s.interests.isNotEmpty,
          build: (context, state, cubit) => SurveyStep(
            title: l10n.onboardingInterestsTitle,
            subtitle: l10n.onboardingMultiSelectHint,
            options: [
              for (final (id, label, emoji) in [
                ('travel', l10n.onboardingInterestTravel, '✈️'),
                ('food', l10n.onboardingInterestFood, '🍽️'),
                ('technology', l10n.onboardingInterestTechnology, '💻'),
                ('sport', l10n.onboardingInterestSport, '⚽'),
                ('culture', l10n.onboardingInterestCulture, '🎭'),
                ('business', l10n.onboardingInterestBusiness, '💼'),
              ])
                SurveyOption(
                    id: id,
                    label: label,
                    icon: Text(emoji, style: TextStyle(fontSize: 24.sp))),
            ],
            selected: state.interests.toSet(),
            onTap: cubit.toggleInterest,
          ),
        ),
        // 7: When do you want to be fluent?
        _OnboardingStep(
          build: (context, state, cubit) => SliderStep(
            title: l10n.onboardingFluencyTitle,
            subtitle: l10n.onboardingFluencySubtitle,
            factChip: l10n
                .onboardingFluencyChip(_fluentByLabel(context, state.fluencyMonths)),
            valueLabel: '${state.fluencyMonths}',
            valueUnit: l10n.onboardingFluencyUnit,
            circular: true,
            accent: AppColors.green,
            value: state.fluencyMonths.toDouble(),
            min: 1,
            max: 24,
            divisions: 23,
            onChanged: (v) => cubit.setFluencyMonths(v.round()),
          ),
        ),
        // 8: How much do you want to practice a day?
        _OnboardingStep(
          build: (context, state, cubit) => SliderStep(
            title: l10n.onboardingMinutesTitle,
            subtitle: l10n.onboardingMinutesSubtitle,
            factChip:
                l10n.onboardingMinutesChip(state.dailyMinutes * 20),
            valueLabel: l10n.onboardingMinutesValue(state.dailyMinutes),
            badge: state.dailyMinutes == 15 ? l10n.onboardingRecommended : null,
            value: state.dailyMinutes.toDouble(),
            min: 5,
            max: 60,
            divisions: 11,
            onChanged: (v) => cubit.setDailyMinutes((v / 5).round() * 5),
          ),
        ),
        // 9: EDUCATION — Make twice as much progress with Tuco
        _OnboardingStep(
          build: (context, state, cubit) => InfoStep(
            title: l10n.onboardingEducation2Title,
            subtitle: l10n.onboardingEducation2Subtitle,
            child: const ComparisonBars(),
          ),
        ),
        // 10: When do you want to practice? (time selector)
        _OnboardingStep(
          onContinue: (context) async {
            final cubit = context.read<OnboardingCubit>();
            cubit.setPracticeTime(cubit.state.practiceTime ?? '18:00');
          },
          build: (context, state, cubit) => TimePickerStep(
            title: l10n.onboardingTimeTitle,
            subtitle: l10n.onboardingTimeSubtitle,
            initialTime: state.practiceTime ?? '18:00',
            onChanged: cubit.setPracticeTime,
          ),
        ),
        // 11: Don't miss a Spanish lesson again (notification ask)
        _OnboardingStep(
          ownNavigation: true,
          build: (context, state, cubit) => NotificationStep(
            onAllow: cubit.requestNotifications,
            onNext: _next,
          ),
        ),
        // 12: Ask review / built for people like you
        _OnboardingStep(
          onContinue: (context) async {
            final review = InAppReview.instance;
            if (await review.isAvailable()) review.requestReview();
          },
          build: (context, state, cubit) => const RatingStep(),
        ),
        // 13: Promo code (optional) — validated before advancing
        _OnboardingStep(
          canContinue: (s) =>
              s.promoStatus != PromoStatus.checking &&
              s.promoStatus != PromoStatus.invalid &&
              s.promoStatus != PromoStatus.exhausted,
          onContinue: (context) async {
            final cubit = context.read<OnboardingCubit>();
            FocusScope.of(context).unfocus();
            if (cubit.state.promoCode.trim().isEmpty ||
                cubit.state.promoStatus == PromoStatus.valid) {
              return;
            }
            await cubit.submitPromoCode();
          },
          build: (context, state, cubit) => PromoCodeStep(
            status: state.promoStatus,
            onCodeChanged: cubit.setPromoCode,
          ),
        ),
        // 14: Making your plan (auto-advances)
        _OnboardingStep(
          ownNavigation: true,
          build: (context, state, cubit) => LoadingStep(onDone: _next),
        ),
        // 15: Your custom plan is ready
        _OnboardingStep(
          build: (context, state, cubit) => PlanReadyStep(state: state),
        ),
        // 16: We want you to try for free → Superwall paywall
        _OnboardingStep(
          onContinue: (context) async {
            await context
                .read<SubscriptionCubit>()
                .registerOnboardingPaywall();
          },
          build: (context, state, cubit) => const FreeTrialStep(),
        ),
        // 17: Let's finish your set-up
        _OnboardingStep(
          ownNavigation: true,
          build: (context, state, cubit) => SignInStep(
            onFinish: () async {
              await cubit
                  .completeOnboarding(context.read<SubscriptionCubit>());
            },
          ),
        ),
      ];

  /// Existing-user sign-in pushed from the start page: on success we mark
  /// onboarding complete without overwriting the account's profile.
  void _pushDirectSignIn(OnboardingCubit cubit) {
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: const BackCircleButton(),
                ),
                Expanded(
                  child: SignInStep(
                    showSkip: false,
                    onFinish: () async {
                      await cubit.markComplete();
                      // Reveal the gate (now showing the app) underneath.
                      navigator.popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Navigation ----------------

  void _goTo(int page) {
    setState(() => _page = page);
    _controller.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _next() {
    final total = _steps(AppLocalizations.of(context)!).length;
    if (_page < total - 1) _goTo(_page + 1);
  }

  void _back() {
    if (_page > 0) _goTo(_page - 1);
  }

  /// Pages where going back makes no sense (loading and after it).
  bool get _backHidden => _page == 0 || _page >= 14;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<OnboardingCubit>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            final steps = _steps(l10n);
            final step = steps[_page];
            final canContinue = step.canContinue?.call(state) ?? true;
            return Column(
              children: [
                _Header(
                  progress: _page / (steps.length - 1),
                  showBack: !_backHidden,
                  showBar: _page > 0,
                  onBack: _back,
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final s in steps) s.build(context, state, cubit),
                    ],
                  ),
                ),
                if (!step.ownNavigation)
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
                    child: Opacity(
                      opacity: canContinue ? 1 : 0.4,
                      child: IgnorePointer(
                        ignoring: !canContinue,
                        child: PrimaryButton(
                          label: l10n.onboardingContinue,
                          onPressed: () async {
                            await step.onContinue?.call(context);
                            if (!context.mounted) return;
                            // A step's side effect can invalidate its own gate
                            // (promo validation) — re-check before advancing.
                            final gate = steps[_page].canContinue;
                            if (gate?.call(cubit.state) ?? true) _next();
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Fixed header: back chevron zone + progress bar + Tuco mascot zone.
class _Header extends StatelessWidget {
  final double progress;
  final bool showBack;
  final bool showBar;
  final VoidCallback onBack;

  const _Header({
    required this.progress,
    required this.showBack,
    required this.showBar,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 52.w,
            child: showBack ? BackCircleButton(onPressed: onBack) : null,
          ),
          Expanded(
            child: Opacity(
              opacity: showBar ? 1 : 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10.h,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 52.w,
            child: Image.asset('assets/images/game/pet_rest_animation.gif',
                width: 40.w),
          ),
        ],
      ),
    );
  }
}

/// Small signal-strength style level indicator for the level survey.
class _LevelBars extends StatelessWidget {
  final int filled; // 1-5

  const _LevelBars(this.filled);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Container(
            margin: EdgeInsets.only(right: 3.w),
            width: 5.w,
            height: (8 + i * 4).h,
            decoration: BoxDecoration(
              color: i < filled ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
      ],
    );
  }
}
