import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/onboarding_state.dart';

/// "Congratulations! Your custom plan is ready" recap: daily-recommendation
/// stats card + a 2x2 grid of value tiles derived from the answers.
class PlanReadyStep extends StatelessWidget {
  final OnboardingState state;

  const PlanReadyStep({super.key, required this.state});

  /// Short month + year label for the fluency goal (e.g. "Aug 2027").
  String _fluentBy(BuildContext context) {
    final target =
        DateTime.now().add(Duration(days: state.fluencyMonths * 30));
    return DateFormat.yMMM(Localizations.localeOf(context).toString())
        .format(target);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Derived "value" numbers, scaled from the daily goal.
    final speakingMin = state.dailyMinutes;
    final wordsPerDay = (state.dailyMinutes / 1.5).round();
    final lessons = 24 + state.fluencyMonths * 2;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        children: [
          Text('🎉', style: TextStyle(fontSize: 44.sp)),
          SizedBox(height: 12.h),
          Text(
            l10n.onboardingPlanTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.pageTitle
                .copyWith(color: AppColors.titleDark, height: 1.2),
          ),
          SizedBox(height: 24.h),
          // Daily recommendation card.
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.onboardingPlanDailyRecommendation,
                    style: AppTextStyles.itemTitle),
                SizedBox(height: 4.h),
                Text(l10n.onboardingPlanStayConsistent,
                    style: AppTextStyles.small),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    _Stat(
                      emoji: '🗣️',
                      value: '+$speakingMin min',
                      label: l10n.onboardingPlanStatSpeaking,
                    ),
                    _Stat(
                      emoji: '📖',
                      value: '+$wordsPerDay',
                      label: l10n.onboardingPlanStatWords,
                    ),
                    _Stat(
                      emoji: '📞',
                      value: '1',
                      label: l10n.onboardingPlanStatCall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // 2x2 value tiles.
          Row(
            children: [
              _Tile(emoji: '📚', label: l10n.onboardingPlanTileLessons(lessons)),
              SizedBox(width: 16.w),
              _Tile(
                  emoji: '🎯',
                  label: l10n.onboardingPlanTileFluent(_fluentBy(context))),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _Tile(emoji: '🗺️', label: l10n.onboardingPlanTilePath),
              SizedBox(width: 16.w),
              _Tile(
                  emoji: '⏱️',
                  label: l10n.onboardingPlanTileMinutes(state.dailyMinutes)),
            ],
          ),
        ],
      ),
    );
  }
}

/// One column of the daily-recommendation card.
class _Stat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _Stat({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 28.sp)),
          SizedBox(height: 8.h),
          Text(value,
              style: AppTextStyles.itemTitle
                  .copyWith(color: AppColors.primary, fontSize: 21.sp)),
          SizedBox(height: 2.h),
          Text(label, style: AppTextStyles.small, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// One square tile of the 2x2 value grid.
class _Tile extends StatelessWidget {
  final String emoji;
  final String label;

  const _Tile({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 150.h,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 34.sp)),
            SizedBox(height: 12.h),
            Text(label,
                style: AppTextStyles.itemTitle.copyWith(fontSize: 17.sp),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
