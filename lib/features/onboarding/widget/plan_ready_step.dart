import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/onboarding_state.dart';

/// "Your custom plan is ready" recap of the collected answers.
class PlanReadyStep extends StatelessWidget {
  final OnboardingState state;

  const PlanReadyStep({super.key, required this.state});

  /// Month + year label for the fluency goal (e.g. "August 2027").
  String _fluentBy(BuildContext context) {
    final target =
        DateTime.now().add(Duration(days: state.fluencyMonths * 30));
    return DateFormat.yMMMM(Localizations.localeOf(context).toString())
        .format(target);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboardingPlanTitle, style: AppTextStyles.pageTitle),
          SizedBox(height: 8.h),
          Text(l10n.onboardingPlanSubtitle, style: AppTextStyles.bodyGrey),
          SizedBox(height: 24.h),
          Center(
            child: Image.asset('assets/images/game/pet_rest_animation.gif',
                width: 110.w),
          ),
          SizedBox(height: 24.h),
          _PlanRow(
            icon: Icons.flag_rounded,
            label: l10n.onboardingPlanFluentBy,
            value: _fluentBy(context),
          ),
          _PlanRow(
            icon: Icons.timer_rounded,
            label: l10n.onboardingPlanDailyGoal,
            value: l10n.onboardingMinutesValue(state.dailyMinutes),
          ),
          if (state.practiceTime != null)
            _PlanRow(
              icon: Icons.notifications_rounded,
              label: l10n.onboardingPlanReminder,
              value: state.practiceTime!,
            ),
          _PlanRow(
            icon: Icons.chat_bubble_rounded,
            label: l10n.onboardingPlanMethod,
            value: l10n.onboardingPlanMethodValue,
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PlanRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.r),
          ),
          SizedBox(width: 14.w),
          Expanded(child: Text(label, style: AppTextStyles.itemSubtitle)),
          Text(value, style: AppTextStyles.itemTitle),
        ],
      ),
    );
  }
}
