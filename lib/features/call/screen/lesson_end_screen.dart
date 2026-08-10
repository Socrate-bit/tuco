import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../curriculum/model/curriculum_models.dart';
import '../../home/cubit/path_cubit.dart';
import '../../streak/screen/streak_win_screen.dart';
import '../../streak/widget/review_sheet.dart';
import 'call_screen.dart';

/// "Cours terminé !" end-of-lesson screen with the 3 stat cards.
class LessonEndScreen extends StatelessWidget {
  final Lesson lesson;
  final int durationSeconds;
  final int newWordsCount;
  final bool showStreakWin;

  const LessonEndScreen({
    super.key,
    required this.lesson,
    required this.durationSeconds,
    required this.newWordsCount,
    required this.showStreakWin,
  });

  String get _durationLabel {
    final m = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final completedCount =
        context.watch<PathCubit>().state.completedLessons.length;
    final nextLesson = context.read<PathCubit>().state.lessonAfter(lesson);

    return Scaffold(
      backgroundColor: AppColors.card,
      body: Stack(
        children: [
          // Blurred robot backdrop fading to white.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.35,
              child: ImageFiltered(
                imageFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.4), BlendMode.lighten),
                child: Image.asset(
                  'assets/images/robot_header.png',
                  width: 1.sw,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 420.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _CloseCircle(onTap: () => _goHome(context)),
                  ),
                  const Spacer(flex: 2),
                  Image.asset('assets/images/finish_flags.png', height: 120.h),
                  SizedBox(height: 30.h),
                  Text(
                    l10n.courseDoneBanner,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display.copyWith(fontSize: 40.sp),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    l10n.endSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyGrey.copyWith(fontSize: 20.sp),
                  ),
                  SizedBox(height: 34.h),
                  Row(
                    children: [
                      _StatCard(
                        title: l10n.newWordsCard,
                        color: AppColors.primary,
                        icon: Icons.sms_rounded,
                        value: '$newWordsCount',
                      ),
                      SizedBox(width: 12.w),
                      _StatCard(
                        title: l10n.lessonsDoneCard,
                        color: AppColors.green,
                        icon: Icons.flag_rounded,
                        value: '$completedCount',
                      ),
                      SizedBox(width: 12.w),
                      _StatCard(
                        title: l10n.lessonDurationCard,
                        color: AppColors.orangeBanner,
                        icon: Icons.access_time_filled_rounded,
                        value: _durationLabel,
                      ),
                    ],
                  ),
                  const Spacer(flex: 3),
                  PrimaryButton(
                    label: l10n.nextLessonButton,
                    onPressed: () => _nextLesson(context, nextLesson),
                  ),
                  SizedBox(height: 8.h),
                  TextLinkButton(
                    label: l10n.backHomeButton,
                    color: AppColors.navy,
                    onPressed: () => _goHome(context),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _afterFlow(BuildContext context) async {
    if (showStreakWin) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (_) => const StreakWinScreen()));
    }
    if (context.mounted) await maybeShowReviewSheet(context);
  }

  Future<void> _goHome(BuildContext context) async {
    Haptics.success();
    await _afterFlow(context);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _nextLesson(BuildContext context, Lesson? next) async {
    Haptics.success();
    await _afterFlow(context);
    if (!context.mounted) return;
    if (next == null) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => CallScreen(args: CallScreenArgs(lesson: next)),
    ));
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final String value;

  const _StatCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(4.r),
        child: Column(
          children: [
            SizedBox(
              height: 44.h,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: AppTextStyles.button.copyWith(fontSize: 14.sp),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 22.r),
                  SizedBox(width: 6.w),
                  Text(value,
                      style: AppTextStyles.itemTitle
                          .copyWith(color: color, fontSize: 20.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseCircle extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseCircle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: const BoxDecoration(
            color: AppColors.background, shape: BoxShape.circle),
        child:
            Icon(Icons.close_rounded, color: AppColors.textGrey, size: 26.r),
      ),
    );
  }
}
