import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../cubit/ai_consent_cubit.dart';
import 'ai_consent_body.dart';

/// Onboarding page carrying the AI data disclosure. Placed before the app can
/// ever reach a call, so no voice, message or profile data is sent to an AI
/// provider before the user has agreed here.
///
/// Owns its navigation (Agree / Not now), like the notification step.
class AiConsentStep extends StatelessWidget {
  final VoidCallback onNext;

  const AiConsentStep({super.key, required this.onNext});

  Future<void> _agree(BuildContext context) async {
    await context.read<AiConsentCubit>().grant('onboarding');
    onNext();
  }

  /// "Not now" never just advances: the user is told what stays unavailable and
  /// chooses between continuing in limited mode and going back.
  Future<void> _decline(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AiConsentCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.aiConsentDeclineTitle,
            style: AppTextStyles.modalTitle.copyWith(fontSize: 21.sp)),
        content: Text(l10n.aiConsentDeclineBody, style: AppTextStyles.bodyGrey),
        actions: [
          TextButton(
            onPressed: () {
              Haptics.tap();
              Navigator.pop(dialogContext, false);
            },
            child: Text(l10n.aiConsentDeclineBack),
          ),
          TextButton(
            onPressed: () {
              Haptics.tap();
              Navigator.pop(dialogContext, true);
            },
            child: Text(l10n.aiConsentDeclineConfirm,
                style: const TextStyle(color: AppColors.textGrey)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await cubit.withdraw('onboarding');
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: const AiConsentBody(),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 8.h),
          child: Column(
            children: [
              PrimaryButton(
                label: l10n.aiConsentAgree,
                onPressed: () => _agree(context),
              ),
              SizedBox(height: 4.h),
              TextLinkButton(
                label: l10n.aiConsentNotNow,
                color: AppColors.textGrey,
                onPressed: () => _decline(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
