import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';

/// Tuco start page (Levio v2 layout): stars, top-anchored headline,
/// centered logo (no pet here — Tuco is revealed on the next page),
/// prominent CTA with arrow and a social-proof caption.
class WelcomeStep extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onSignIn;

  const WelcomeStep({super.key, required this.onStart, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 32.sp)),
          SizedBox(height: 28.h),
          Text(
            l10n.onboardingWelcomeTitle,
            style: AppTextStyles.pageTitle.copyWith(
              fontSize: 36.sp,
              height: 1.12,
              letterSpacing: -0.5,
              color: AppColors.titleDark,
            ),
          ),
          SizedBox(height: 16.h),
          Text(l10n.onboardingWelcomeSubtitle, style: AppTextStyles.bodyGrey),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Haptics.tap();
              onStart();
            },
            child: Container(
              width: double.infinity,
              height: 66.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primaryDark, offset: Offset(0, 4.h)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.onboardingWelcomeCta, style: AppTextStyles.button),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, size: 22.sp, color: Colors.white),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              l10n.onboardingWelcomeJoin,
              maxLines: 1,
              style: AppTextStyles.small.copyWith(
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: GestureDetector(
              onTap: () {
                Haptics.tap();
                onSignIn();
              },
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.small,
                  children: [
                    TextSpan(text: l10n.onboardingAlreadyAccount),
                    TextSpan(
                      text: l10n.onboardingSignInLink,
                      style: AppTextStyles.small.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Meet Tuco, your new companion" page with the waving Hello GIF.
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
              child: Image.asset('assets/onboarding/pet_hello.gif',
                  width: 240.w),
            ),
          ),
        ],
      ),
    );
  }
}
