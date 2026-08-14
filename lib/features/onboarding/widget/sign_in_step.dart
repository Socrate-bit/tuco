import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';

/// "Let's finish your set-up" final page.
/// Auth providers are not wired yet (anonymous session only), so the CTA
/// simply completes onboarding; provider buttons can be added later.
class SignInStep extends StatelessWidget {
  final VoidCallback onFinish;

  const SignInStep({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboardingSignInTitle, style: AppTextStyles.pageTitle),
          SizedBox(height: 8.h),
          Text(l10n.onboardingSignInSubtitle, style: AppTextStyles.bodyGrey),
          Expanded(
            child: Center(
              child: Image.asset('assets/images/game/pet_rest_animation.gif',
                  width: 150.w),
            ),
          ),
          PrimaryButton(label: l10n.onboardingSignInCta, onPressed: onFinish),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
