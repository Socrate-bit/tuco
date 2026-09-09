import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../service/auth_service.dart';

/// Start-page sign-in: email + password against Firebase Auth, for accounts
/// that already exist (the App Store review account). Signing in swaps the
/// anonymous session for the account's uid — its `user_type` then grants the
/// tier — and skips the onboarding funnel. Everyone else stays anonymous.
class SignInStep extends StatefulWidget {
  final VoidCallback onFinish;

  const SignInStep({super.key, required this.onFinish});

  @override
  State<SignInStep> createState() => _SignInStepState();
}

class _SignInStepState extends State<SignInStep> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.onboardingSignInFailed)));
  }

  /// Signs into the account; the subscription cubit picks up its user type
  /// from the auth change on its own.
  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await AuthService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      debugPrint('[SignInStep] Email sign-in succeeded');
      if (mounted) widget.onFinish();
    } catch (e) {
      debugPrint('[SignInStep] Email sign-in failed: $e');
      if (mounted) _showError();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Styling shared by the email and password inputs.
  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.bodyGrey,
    filled: true,
    fillColor: AppColors.card,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Scrollable so the form stays reachable above the keyboard.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 48.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.onboardingSignInTitle,
                style: AppTextStyles.pageTitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.onboardingSignInSubtitle,
                style: AppTextStyles.bodyGrey,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                style: AppTextStyles.body,
                decoration: _fieldDecoration(l10n.onboardingSignInEmail),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _passwordController,
                obscureText: true,
                autocorrect: false,
                style: AppTextStyles.body,
                onSubmitted: (_) => _loading ? null : _signIn(),
                decoration: _fieldDecoration(l10n.onboardingSignInPassword),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          Haptics.tap();
                          _signIn();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: Text(
                    l10n.onboardingSignInEmailCta,
                    style: AppTextStyles.button.copyWith(fontSize: 17.sp),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              if (_loading)
                const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
