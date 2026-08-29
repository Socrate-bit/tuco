import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../subscription/cubit/subscription_cubit.dart';
import '../../subscription/cubit/subscription_state.dart';

/// Promo code entry from the settings screen. Redeems immediately and closes
/// on success; errors stay in the dialog so the user can retry.
class PromoCodeDialog extends StatefulWidget {
  const PromoCodeDialog({super.key});

  @override
  State<PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<PromoCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close(BuildContext context) {
    context.read<SubscriptionCubit>().clearRedeemStatus();
    Navigator.pop(context);
  }

  // Error line under the field; null while idle, submitting or successful.
  (Color, String)? _error(SubscriptionState state, AppLocalizations l10n) =>
      switch (state.redeemStatus) {
        PromoRedeemStatus.invalid => (AppColors.scoreRed, l10n.promoInvalid),
        PromoRedeemStatus.exhausted => (
            AppColors.scoreOrange,
            l10n.promoUsageLimit
          ),
        PromoRedeemStatus.error => (AppColors.scoreRed, l10n.promoError),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listenWhen: (prev, curr) => prev.redeemStatus != curr.redeemStatus,
      listener: (context, state) {
        if (state.redeemStatus != PromoRedeemStatus.success) return;
        Haptics.success();
        _close(context);
      },
      builder: (context, state) {
        final isSubmitting = state.redeemStatus == PromoRedeemStatus.submitting;
        final error = _error(state, l10n);
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(l10n.promoTitle, style: AppTextStyles.modalTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                enabled: !isSubmitting,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: l10n.promoCodeLabel,
                  hintStyle: AppTextStyles.bodyGrey,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                ),
              ),
              if (error != null) ...[
                SizedBox(height: 8.h),
                Text(error.$2,
                    style: AppTextStyles.small.copyWith(color: error.$1)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      Haptics.tap();
                      _close(context);
                    },
              child: Text(l10n.promoCancel, style: AppTextStyles.bodyGrey),
            ),
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      Haptics.tap();
                      context
                          .read<SubscriptionCubit>()
                          .redeemPromoCode(_controller.text);
                    },
              child: isSubmitting
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : Text(l10n.promoSubmit,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }
}
