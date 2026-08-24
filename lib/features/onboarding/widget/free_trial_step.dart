import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// "We want you to try Tuco for free" pre-paywall pitch page.
/// The Continue press on this page registers the Superwall placement.
class FreeTrialStep extends StatelessWidget {
  const FreeTrialStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboardingTrialTitle, style: AppTextStyles.pageTitle),
          SizedBox(height: 8.h),
          Text(l10n.onboardingTrialSubtitle, style: AppTextStyles.bodyGrey),
          SizedBox(height: 24.h),
          Center(
            child: Image.asset('assets/images/game/pet_rest_animation.gif',
                width: 130.w),
          ),
          SizedBox(height: 24.h),
          _TrialRow(
              icon: Icons.lock_open_rounded, text: l10n.onboardingTrialPoint1),
          _TrialRow(
              icon: Icons.notifications_rounded,
              text: l10n.onboardingTrialPoint2),
          _TrialRow(icon: Icons.star_rounded, text: l10n.onboardingTrialPoint3),
        ],
      ),
    );
  }
}

class _TrialRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrialRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
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
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
