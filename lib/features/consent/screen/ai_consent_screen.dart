import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../cubit/ai_consent_cubit.dart';
import '../cubit/ai_consent_state.dart';
import '../service/ai_consent_service.dart';
import '../widget/ai_consent_body.dart';

/// Standalone AI disclosure. Used in two places:
/// - the gate: an AI call was requested without consent, so the disclosure is
///   presented instead of making the call (pops true once agreed);
/// - Settings: reviewing the disclosure already agreed to, with a way out.
class AiConsentScreen extends StatelessWidget {
  /// Where this was opened from — recorded on the analytics event.
  final String source;

  /// Settings review: adds the back button and the withdraw action.
  final bool reviewing;

  const AiConsentScreen({
    super.key,
    required this.source,
    this.reviewing = false,
  });

  Future<void> _agree(BuildContext context) async {
    final navigator = Navigator.of(context);
    await context.read<AiConsentCubit>().grant(source);
    if (reviewing) return; // stay on the page; the status row updates itself
    navigator.pop(true);
  }

  /// "Not now": never silent. Spell out what stays unavailable, then let the
  /// user either continue without AI or go back to the disclosure.
  Future<void> _decline(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
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
    await cubit.withdraw(source);
    navigator.pop(false);
  }

  /// Settings: turn the gate back on for every future AI request.
  Future<void> _withdraw(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AiConsentCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.aiConsentWithdrawTitle,
            style: AppTextStyles.modalTitle.copyWith(fontSize: 21.sp)),
        content: Text(l10n.aiConsentWithdrawBody, style: AppTextStyles.bodyGrey),
        actions: [
          TextButton(
            onPressed: () {
              Haptics.tap();
              Navigator.pop(dialogContext, false);
            },
            child: Text(l10n.aiConsentWithdrawCancel),
          ),
          TextButton(
            onPressed: () {
              Haptics.tap();
              Navigator.pop(dialogContext, true);
            },
            child: Text(l10n.aiConsentWithdrawConfirm,
                style: const TextStyle(color: AppColors.scoreRed)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await cubit.withdraw(source);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AiConsentCubit, AiConsentState>(
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              if (reviewing)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: BackCircleButton(),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                  child: const AiConsentBody(),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
                child: state.granted
                    ? _GrantedActions(onWithdraw: () => _withdraw(context))
                    : Column(
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
          ),
        ),
      ),
    );
  }
}

/// Footer shown when permission is already given: current status + a way out.
class _GrantedActions extends StatelessWidget {
  final VoidCallback onWithdraw;

  const _GrantedActions({required this.onWithdraw});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded,
                size: 20.r, color: AppColors.scoreGreen),
            SizedBox(width: 8.w),
            Text(l10n.aiConsentStatusGranted,
                style: AppTextStyles.body.copyWith(fontSize: 16.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        TextLinkButton(
          label: l10n.aiConsentWithdraw,
          color: AppColors.scoreRed,
          onPressed: onWithdraw,
        ),
      ],
    );
  }
}

/// The gate used at every entry point that would trigger an AI request.
/// Returns true when the app may talk to the AI providers; when it returns
/// false the caller must not start the call.
Future<bool> ensureAiConsent(BuildContext context,
    {required String source}) async {
  if (AiConsentService.isGranted) return true;
  final granted = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => AiConsentScreen(source: source)),
  );
  return granted ?? false;
}
