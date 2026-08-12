import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../feedback/cubit/feedback_cubit.dart';

/// Feedback sheet for one user sentence (grammar corrections if any).
/// Shared by the live call screen and the past-call transcript screen.
void showFeedbackSheet(BuildContext context, String text) {
  Haptics.tap();
  final l10n = AppLocalizations.of(context)!;
  final items = context
      .read<FeedbackCubit>()
      .state
      .items
      .where((f) => f.originalText == text)
      .toList();
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.card,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r))),
    builder: (_) => Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.h),
              child: Center(
                child: Text(l10n.noErrorsHere,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyGrey),
              ),
            )
          else
            for (final item in items) ...[
              for (final c in item.corrections) ...[
                // Wrap so long corrections flow onto multiple lines instead of overflowing.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 4.h,
                  children: [
                    Text('• ', style: AppTextStyles.body),
                    Text(c.wrong,
                        style: AppTextStyles.body.copyWith(
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.scoreRed)),
                    Text('  →  ', style: AppTextStyles.body),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.scoreGreenBg,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(c.right,
                          style: AppTextStyles.body
                              .copyWith(color: Colors.white)),
                    ),
                  ],
                ),
                if (c.explanation.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(c.explanation, style: AppTextStyles.bodyGrey),
                ],
                SizedBox(height: 16.h),
              ],
            ],
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
  );
}
