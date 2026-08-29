import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/onboarding_state.dart';

/// Optional promo code page. The code is only validated here — redemption
/// happens at the end of the funnel, once the final uid is known.
class PromoCodeStep extends StatelessWidget {
  final PromoStatus status;
  final ValueChanged<String> onCodeChanged;

  const PromoCodeStep({
    super.key,
    required this.status,
    required this.onCodeChanged,
  });

  // Feedback line under the field: icon, color and message per status.
  (IconData, Color, String)? _feedback(AppLocalizations l10n) =>
      switch (status) {
        PromoStatus.valid => (
            Icons.check_circle,
            AppColors.scoreGreen,
            l10n.onboardingPromoApplied
          ),
        PromoStatus.invalid => (
            Icons.error_outline,
            AppColors.scoreRed,
            l10n.onboardingPromoInvalid
          ),
        PromoStatus.exhausted => (
            Icons.block,
            AppColors.scoreOrange,
            l10n.onboardingPromoLimit
          ),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final feedback = _feedback(l10n);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Text(l10n.onboardingPromoTitle, style: AppTextStyles.pageTitle),
          SizedBox(height: 8.h),
          Text(l10n.onboardingPromoSubtitle, style: AppTextStyles.bodyGrey),
          const Spacer(),
          TextField(
            textCapitalization: TextCapitalization.characters,
            style: AppTextStyles.body,
            onChanged: onCodeChanged,
            decoration: InputDecoration(
              hintText: l10n.onboardingPromoLabel,
              hintStyle: AppTextStyles.bodyGrey,
              filled: true,
              fillColor: AppColors.card,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
            ),
          ),
          if (status == PromoStatus.checking) ...[
            SizedBox(height: 16.h),
            Center(
              child: SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          ] else if (feedback != null) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(feedback.$1, color: feedback.$2, size: 20.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(feedback.$3,
                      style: AppTextStyles.body.copyWith(color: feedback.$2)),
                ),
              ],
            ),
          ],
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
