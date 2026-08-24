import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../service/auth_service.dart';

/// "Let's finish your set-up" page: Apple / Google sign-in, or continue
/// anonymously ("skip for now"). Any of the three completes onboarding.
class SignInStep extends StatefulWidget {
  final VoidCallback onFinish;
  final bool showSkip; // hidden on the existing-user sign-in screen

  const SignInStep({super.key, required this.onFinish, this.showSkip = true});

  @override
  State<SignInStep> createState() => _SignInStepState();
}

class _SignInStepState extends State<SignInStep> {
  bool _loading = false;

  Future<void> _run(Future<void> Function() signIn, String provider) async {
    setState(() => _loading = true);
    try {
      await signIn();
      if (mounted) widget.onFinish();
    } catch (e) {
      debugPrint('[SignInStep] $provider sign-in failed: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.onboardingSignInFailed)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(l10n.onboardingSignInTitle,
              style: AppTextStyles.pageTitle, textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text(l10n.onboardingSignInSubtitle,
              style: AppTextStyles.bodyGrey, textAlign: TextAlign.center),
          SizedBox(height: 32.h),
          // Sign in with Apple (filled dark).
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton.icon(
              onPressed: _loading
                  ? null
                  : () {
                      Haptics.tap();
                      _run(AuthService.signInWithApple, 'Apple');
                    },
              icon: Icon(Icons.apple, size: 24.sp, color: Colors.white),
              label: Text(l10n.onboardingSignInApple,
                  style: AppTextStyles.button.copyWith(fontSize: 17.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.titleDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r)),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Continue with Google (outlined).
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: OutlinedButton(
              onPressed: _loading
                  ? null
                  : () {
                      Haptics.tap();
                      _run(AuthService.signInWithGoogle, 'Google');
                    },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.divider, width: 1.5),
                backgroundColor: AppColors.card,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r)),
              ),
              child: Text(l10n.onboardingSignInGoogle,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
          SizedBox(height: 24.h),
          if (_loading)
            const CircularProgressIndicator(color: AppColors.primary)
          else if (widget.showSkip)
            GestureDetector(
              onTap: () {
                Haptics.tap();
                // Session is already anonymous — just finish.
                widget.onFinish();
              },
              child: Text(
                l10n.onboardingSignInSkip,
                style: AppTextStyles.bodyGrey
                    .copyWith(decoration: TextDecoration.underline),
              ),
            ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
