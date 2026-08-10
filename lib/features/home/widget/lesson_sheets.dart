import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../curriculum/model/curriculum_models.dart';

/// Bottom sheet shown when tapping an unlocked lesson: colored header with
/// title/description/chips, exercise buttons and the word grid.
Future<String?> showLessonStartSheet(BuildContext context, Lesson lesson) {
  Haptics.tap();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LessonStartSheet(lesson: lesson),
  );
}

class _LessonStartSheet extends StatelessWidget {
  final Lesson lesson;

  const _LessonStartSheet({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Color(lesson.color);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored header.
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            ),
            padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 28.h),
            child: Column(
              children: [
                Container(
                  width: 64.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(height: 28.h),
                Text(
                  lesson.title,
                  style: AppTextStyles.display
                      .copyWith(color: Colors.white, fontSize: 34.sp),
                ),
                SizedBox(height: 12.h),
                Text(
                  lesson.description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 19.sp),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _HeaderChip(label: l10n.wordsChip(lesson.vocab.length)),
                    SizedBox(width: 14.w),
                    _HeaderChip(
                        label: l10n.grammarChip(lesson.grammarPoints.length)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 26.h, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.exercisesSection,
                    style: AppTextStyles.sectionTitle.copyWith(
                        color: color, fontSize: 17.sp, letterSpacing: 0.5)),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    _ExerciseButton(
                      label: l10n.lessonExercise,
                      badgeColor: AppColors.green,
                      icon: Icons.spellcheck_rounded,
                      onTap: () => Navigator.pop(context, 'lesson'),
                    ),
                    SizedBox(width: 18.w),
                    _ExerciseButton(
                      label: l10n.practiceExercise,
                      badgeColor: AppColors.purple,
                      icon: Icons.theater_comedy_rounded,
                      onTap: () => Navigator.pop(context, 'practice'),
                    ),
                  ],
                ),
                SizedBox(height: 26.h),
                Text(l10n.wordsToPracticeSection,
                    style: AppTextStyles.sectionTitle.copyWith(
                        color: color, fontSize: 17.sp, letterSpacing: 0.5)),
                SizedBox(height: 16.h),
                // Horizontally scrollable 2-row word grid.
                SizedBox(
                  height: 172.h,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(right: 24.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14.w,
                      crossAxisSpacing: 14.h,
                      childAspectRatio: 78.h / 280.w,
                    ),
                    itemCount: lesson.vocab.length,
                    itemBuilder: (_, i) => _WordCard(word: lesson.vocab[i]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
            child: PrimaryButton(
              label: l10n.wellUnderstood,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;

  const _HeaderChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(label,
          style: AppTextStyles.button.copyWith(fontSize: 17.sp)),
    );
  }
}

class _ExerciseButton extends StatelessWidget {
  final String label;
  final Color badgeColor;
  final IconData icon;
  final VoidCallback onTap;

  const _ExerciseButton({
    required this.label,
    required this.badgeColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.impact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: badgeColor, width: 1.5),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration:
                  BoxDecoration(color: badgeColor, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Text(label,
                style: AppTextStyles.itemTitle.copyWith(color: badgeColor)),
          ],
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final VocabWord word;

  const _WordCard({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider, width: 1.5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: const BoxDecoration(
                color: AppColors.background, shape: BoxShape.circle),
            child:
                Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 24.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word.word,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.itemTitle.copyWith(fontSize: 18.sp)),
                Text(word.translation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.itemSubtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered dialog shown when tapping a locked lesson (🦘 skip ahead?).
Future<bool?> showSkipLessonDialog(BuildContext context, String language) {
  Haptics.tap();
  final l10n = AppLocalizations.of(context)!;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🦘', style: TextStyle(fontSize: 64.sp)),
            SizedBox(height: 20.h),
            Text(l10n.skipLessonTitle,
                textAlign: TextAlign.center, style: AppTextStyles.modalTitle),
            SizedBox(height: 16.h),
            Text(l10n.skipLessonBody(language),
                textAlign: TextAlign.center, style: AppTextStyles.bodyGrey),
            SizedBox(height: 26.h),
            PrimaryButton(
              label: l10n.followPath,
              onPressed: () => Navigator.pop(ctx, false),
            ),
            SizedBox(height: 10.h),
            TextLinkButton(
              label: l10n.goToExercise,
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Bottom sheet asking to resume or restart an in-progress lesson.
Future<String?> showResumeLessonSheet(BuildContext context) {
  Haptics.tap();
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.card,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          24.w, 36.h, 24.w, 16.h + MediaQuery.of(ctx).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.resumeLessonTitle,
              textAlign: TextAlign.center, style: AppTextStyles.modalTitle),
          SizedBox(height: 30.h),
          PrimaryButton(
            label: l10n.resumeLessonButton,
            onPressed: () => Navigator.pop(ctx, 'resume'),
          ),
          SizedBox(height: 10.h),
          TextLinkButton(
            label: l10n.restartLessonButton,
            onPressed: () => Navigator.pop(ctx, 'restart'),
          ),
        ],
      ),
    ),
  );
}
