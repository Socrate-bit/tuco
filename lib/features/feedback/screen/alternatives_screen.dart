import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../cubit/feedback_cubit.dart';
import '../widget/feedback_card.dart';

/// "Alternatives" page: alternative-phrasing feedback or the empty state.
class AlternativesScreen extends StatelessWidget {
  const AlternativesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = context.watch<FeedbackCubit>().state.alternatives;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SubPageHeader(title: l10n.alternatives),
          Expanded(
            child: items.isEmpty
                ? _EmptyState(text: l10n.noErrorsHere)
                : ListView.separated(
                    padding: EdgeInsets.all(20.r),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => SizedBox(height: 14.h),
                    itemBuilder: (_, i) => FeedbackCard(item: items[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Big illustration circle + helper text.
class _EmptyState extends StatelessWidget {
  final String text;

  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          SizedBox(height: 120.h),
          // Illustration: feedback icon + pointing hand over chat lines.
          SizedBox(
            width: 240.r,
            height: 240.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4E8F5),
                    shape: BoxShape.circle,
                  ),
                ),
                Positioned(
                  right: 36.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _chatLine(120.r, const Color(0xFFC3C9D9)),
                      SizedBox(height: 10.r),
                      _chatLine(96.r, const Color(0xFFDDE2EE)),
                    ],
                  ),
                ),
                Positioned(
                  left: 34.r,
                  top: 76.r,
                  child: Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.sms_rounded,
                            size: 26.r, color: const Color(0xFF9AA3B5)),
                        Positioned(
                          right: 12.r,
                          top: 12.r,
                          child: Container(
                            width: 9.r,
                            height: 9.r,
                            decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 62.r,
                  top: 122.r,
                  child: Text('👆', style: TextStyle(fontSize: 52.sp)),
                ),
              ],
            ),
          ),
          SizedBox(height: 34.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyGrey.copyWith(fontSize: 19.sp),
          ),
        ],
      ),
    );
  }

  Widget _chatLine(double width, Color color) => Container(
        width: width,
        height: 26.r,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(13.r),
        ),
      );
}
