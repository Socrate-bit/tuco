import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';

/// "Never miss a lesson" page — fires the iOS notification prompt.
/// Owns its own navigation (Allow / Not now), no shared Continue button.
class NotificationStep extends StatelessWidget {
  final String languageName; // learner's target language, shown in the title
  final Future<void> Function() onAllow;
  final VoidCallback onNext;

  const NotificationStep(
      {super.key,
      required this.languageName,
      required this.onAllow,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboardingNotifTitle(languageName),
              style: AppTextStyles.pageTitle),
          SizedBox(height: 8.h),
          Text(l10n.onboardingNotifSubtitle, style: AppTextStyles.bodyGrey),
          Expanded(
            child: Center(
              child: Container(
                width: 140.r,
                height: 140.r,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications_active_rounded,
                    color: AppColors.primary, size: 70.r),
              ),
            ),
          ),
          PrimaryButton(
            label: l10n.onboardingNotifAllow,
            onPressed: () async {
              await onAllow();
              onNext();
            },
          ),
          SizedBox(height: 8.h),
          Center(
            child: TextLinkButton(
              label: l10n.onboardingNotifLater,
              color: AppColors.textGrey,
              onPressed: onNext,
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
