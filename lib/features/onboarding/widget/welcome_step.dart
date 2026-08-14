import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';

/// Tuco start page: logo, tagline and the "Get started" CTA.
class WelcomeStep extends StatelessWidget {
  final VoidCallback onStart;

  const WelcomeStep({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        children: [
          const Spacer(),
          Image.asset('assets/logo.png', width: 160.w),
          SizedBox(height: 24.h),
          Text(l10n.onboardingWelcomeTitle,
              style: AppTextStyles.pageTitle.copyWith(fontSize: 32.sp),
              textAlign: TextAlign.center),
          SizedBox(height: 12.h),
          Text(l10n.onboardingWelcomeSubtitle,
              style: AppTextStyles.bodyGrey, textAlign: TextAlign.center),
          const Spacer(),
          PrimaryButton(label: l10n.onboardingWelcomeCta, onPressed: onStart),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

/// "Meet Tuco, your new companion" page (used twice in the funnel).
class MeetTucoStep extends StatelessWidget {
  final String title;
  final String subtitle;

  const MeetTucoStep({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.pageTitle),
          SizedBox(height: 8.h),
          Text(subtitle, style: AppTextStyles.bodyGrey),
          Expanded(
            child: Center(
              child: Image.asset('assets/images/game/pet_rest_animation.gif',
                  width: 220.w),
            ),
          ),
        ],
      ),
    );
  }
}
