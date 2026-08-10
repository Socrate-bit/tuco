import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';

bool _reviewShownThisSession = false;

/// Shows the "Merci d'utiliser Learna !" rating sheet once per session.
Future<void> maybeShowReviewSheet(BuildContext context) async {
  if (_reviewShownThisSession) return;
  _reviewShownThisSession = true;
  final l10n = AppLocalizations.of(context)!;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          24.w, 40.h, 24.w, 16.h + MediaQuery.of(ctx).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.asset('assets/images/review_cat.png',
                width: 220.r, height: 220.r, fit: BoxFit.cover),
          ),
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Icon(Icons.star_rounded,
                    color: AppColors.streakOrange, size: 38.r),
              ),
            ),
          ),
          SizedBox(height: 22.h),
          Text(l10n.reviewTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.modalTitle.copyWith(fontSize: 30.sp)),
          SizedBox(height: 14.h),
          Text(l10n.reviewBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyGrey.copyWith(fontSize: 19.sp)),
          SizedBox(height: 28.h),
          PrimaryButton(
            label: l10n.letsGo,
            onPressed: () async {
              Navigator.pop(ctx);
              final review = InAppReview.instance;
              if (await review.isAvailable()) review.requestReview();
            },
          ),
          SizedBox(height: 8.h),
          TextLinkButton(
            label: l10n.maybeLater,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );
}
