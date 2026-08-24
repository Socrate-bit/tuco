import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/model/models.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../pronunciation/widget/phoneme_detail_sheet.dart';
import '../../pronunciation/widget/pronunciation_ring.dart';

/// Grey AI bubble with translate + play buttons on its right.
class AiBubble extends StatelessWidget {
  final ChatMessage message;
  final bool translating;
  final VoidCallback onTranslate;
  final VoidCallback onPlay;

  const AiBubble({
    super.key,
    required this.message,
    required this.translating,
    required this.onTranslate,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final translated = message.translation != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: 0.64.sw),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.aiBubble,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message.text, style: AppTextStyles.body),
                if (translated) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: const Divider(
                        color: AppColors.divider, thickness: 1, height: 1),
                  ),
                  Text(message.translation!,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textGrey)),
                ],
              ],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        _CircleAction(
          onTap: onTranslate,
          child: translating
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                )
              : Icon(Icons.translate_rounded,
                  size: 20.r,
                  color:
                      translated ? AppColors.primary : AppColors.textGrey),
        ),
        SizedBox(width: 8.w),
        _CircleAction(
          onTap: onPlay,
          child: Icon(Icons.play_arrow_rounded,
              size: 24.r, color: AppColors.textGrey),
        ),
      ],
    );
  }
}

/// Light-blue user bubble with the feedback button on its left.
class UserBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onFeedbackTap;
  final bool pending; // partial voice transcript
  final bool hasFeedback; // corrections exist → show notification dot

  const UserBubble({
    super.key,
    required this.message,
    required this.onFeedbackTap,
    this.pending = false,
    this.hasFeedback = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!pending) ...[
          _CircleAction(
            onTap: onFeedbackTap,
            child: Stack(
              children: [
                Icon(Icons.sms_rounded, size: 20.r, color: AppColors.textGrey),
                if (hasFeedback)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
        ],
        Flexible(
          child: Opacity(
            opacity: pending ? 0.6 : 1,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  // Tap a scored message to open its phoneme breakdown.
                  onTap: message.pronunciation == null
                      ? null
                      : () {
                          Haptics.tap();
                          showPhonemeDetailSheet(
                              context, message.pronunciation!);
                        },
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 0.64.sw),
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.userBubble,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Text(message.text, style: AppTextStyles.body),
                  ),
                ),
                // Exercise result badge (correct / wrong attempt).
                if (message.verdict != null)
                  Positioned(
                    top: -6.r,
                    right: -6.r,
                    child: Container(
                      width: 22.r,
                      height: 22.r,
                      decoration: BoxDecoration(
                        color: message.verdict == 'win'
                            ? AppColors.scoreGreen
                            : AppColors.scoreRed,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        message.verdict == 'win'
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        size: 15.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                // Progressive pronunciation score ring.
                if (message.pronunciation != null)
                  Positioned(
                    bottom: -6.r,
                    right: -6.r,
                    child: Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: const BoxDecoration(
                          color: AppColors.card, shape: BoxShape.circle),
                      child: PronunciationRing(
                        score: message.pronunciation!.pronScore,
                        size: 24,
                        stroke: 3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Cream "Inspiration" bubble with example sentences.
class InspirationBubble extends StatelessWidget {
  final ChatMessage message;
  final bool translating;
  final VoidCallback onTranslate;
  final VoidCallback onPlay;

  const InspirationBubble({
    super.key,
    required this.message,
    required this.translating,
    required this.onTranslate,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final translated = message.translation != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CircleAction(
          onTap: onTranslate,
          child: translating
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                )
              : Icon(Icons.translate_rounded,
                  size: 20.r,
                  color:
                      translated ? AppColors.primary : AppColors.textGrey),
        ),
        SizedBox(width: 8.w),
        _CircleAction(
          onTap: onPlay,
          child: Icon(Icons.play_arrow_rounded,
              size: 24.r, color: AppColors.textGrey),
        ),
        SizedBox(width: 10.w),
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: 0.68.sw),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.inspirationBubble,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.inspirationTitle,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w800)),
                SizedBox(height: 6.h),
                Text(message.text,
                    style: AppTextStyles.body.copyWith(fontSize: 16.sp)),
                if (translated) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: const Divider(
                        color: AppColors.divider, thickness: 1, height: 1),
                  ),
                  Text(message.translation!,
                      style: AppTextStyles.body.copyWith(
                          fontSize: 16.sp, color: AppColors.textGrey)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-width phase banners: "Cours", "Entraînement", "Cours terminé !".
class PhaseBanner extends StatelessWidget {
  final String banner; // 'course' | 'practice' | 'courseDone'

  const PhaseBanner({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (banner) {
      'courseDone' => Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.orangeBanner,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            children: [
              Text('🏁', style: TextStyle(fontSize: 30.sp)),
              SizedBox(height: 4.h),
              Text(l10n.courseDoneBanner,
                  style: AppTextStyles.button.copyWith(fontSize: 21.sp)),
              SizedBox(height: 2.h),
              Text(l10n.yourTurn,
                  style: AppTextStyles.button.copyWith(
                      fontSize: 17.sp, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      'practice' => _iconBanner(
          color: AppColors.purple,
          icon: Icons.theater_comedy_rounded,
          label: l10n.practiceBanner,
        ),
      _ => _iconBanner(
          color: AppColors.orangeBanner,
          icon: Icons.spellcheck_rounded,
          label: l10n.courseBanner,
        ),
    };
  }

  Widget _iconBanner(
      {required Color color, required IconData icon, required String label}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 26.r),
          ),
          SizedBox(width: 14.w),
          Text(label, style: AppTextStyles.button.copyWith(fontSize: 20.sp)),
        ],
      ),
    );
  }
}

/// Small grey circular action button used beside bubbles.
class _CircleAction extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _CircleAction({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: const BoxDecoration(
            color: AppColors.aiBubble, shape: BoxShape.circle),
        child: Center(child: child),
      ),
    );
  }
}
