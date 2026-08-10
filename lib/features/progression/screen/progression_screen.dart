import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../feedback/cubit/feedback_cubit.dart';
import '../../feedback/screen/alternatives_screen.dart';
import '../../feedback/screen/grammar_screen.dart';
import '../../history/screen/history_screen.dart';
import '../../history/widget/call_card.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../streak/widget/week_fire_row.dart';
import '../../vocabulary/cubit/vocab_cubit.dart';
import '../../vocabulary/screen/vocabulary_screen.dart';
import '../cubit/stats_cubit.dart';

/// Progression tab: feedback center, vocab progress, streak, call time,
/// call history preview.
class ProgressionScreen extends StatelessWidget {
  const ProgressionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = context.watch<StatsCubit>().state;
    final vocab = context.watch<VocabCubit>().state;
    final feedback = context.watch<FeedbackCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
          children: [
            // ---- Centre de feedback ----
            Text(l10n.feedbackCenter, style: AppTextStyles.sectionTitle),
            SizedBox(height: 16.h),
            Row(
              children: [
                _FeedbackCard(
                  color: AppColors.teal,
                  emoji: '📚',
                  title: l10n.grammar,
                  count: feedback.grammar.length,
                  timesLabel: l10n.times,
                  onTap: () => _push(context, const GrammarScreen()),
                ),
                SizedBox(width: 16.w),
                _FeedbackCard(
                  color: AppColors.green,
                  emoji: '🧐',
                  title: l10n.alternatives,
                  count: feedback.alternatives.length,
                  timesLabel: l10n.times,
                  onTap: () => _push(context, const AlternativesScreen()),
                ),
              ],
            ),
            SizedBox(height: 30.h),

            // ---- Exercice de vocabulaire ----
            Text(l10n.vocabExercise, style: AppTextStyles.sectionTitle),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () {
                Haptics.tap();
                _push(context, const VocabularyScreen());
              },
              child: AppCard(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: vocab.totalCount == 0
                            ? 0
                            : vocab.learnedCount / vocab.totalCount,
                        minHeight: 8.h,
                        backgroundColor: AppColors.userBubble,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: _VocabStat(
                            label: l10n.newWordsLabel,
                            count: vocab.learnedCount,
                          ),
                        ),
                        Expanded(
                          child: _VocabStat(
                            label: l10n.upcomingWordsLabel,
                            count: vocab.upcomingCount,
                          ),
                        ),
                        Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle),
                          child: Icon(Icons.chevron_right_rounded,
                              color: AppColors.primary, size: 28.r),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),

            // ---- Votre série ----
            Text(l10n.yourStreak, style: AppTextStyles.sectionTitle),
            SizedBox(height: 16.h),
            AppCard(
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  _StreakPill(
                    color: AppColors.streakOrange,
                    background: const Color(0xFFFFF4E0),
                    label: l10n.dailyStreak,
                    value: stats.currentStreak,
                  ),
                  SizedBox(height: 12.h),
                  _StreakPill(
                    color: AppColors.lessonRed,
                    background: const Color(0xFFFDEAE6),
                    label: l10n.longestStreak,
                    value: stats.longestStreak,
                  ),
                  SizedBox(height: 22.h),
                  const WeekFireRow(),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            // ---- Temps passé en appel ----
            Text(l10n.callTimeTitle, style: AppTextStyles.sectionTitle),
            SizedBox(height: 16.h),
            AppCard(
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  Row(
                    children: [
                      _TimeStat(
                          label: l10n.timeSpent,
                          seconds: stats.totalCallSeconds),
                      _TimeStat(
                          label: l10n.average,
                          seconds: stats.averageCallSeconds),
                      _TimeStat(
                          label: l10n.goal,
                          seconds: context
                                  .watch<ProfileCubit>()
                                  .state
                                  .dailyGoalMinutes *
                              60),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _WeekBarChart(stats: stats),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            // ---- Historique des appels ----
            Row(
              children: [
                Text(l10n.callHistory, style: AppTextStyles.sectionTitle),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Haptics.tap();
                    _push(context, const HistoryScreen());
                  },
                  child: Text(l10n.showAll,
                      style: AppTextStyles.itemSubtitle
                          .copyWith(fontSize: 17.sp)),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            for (final call in stats.calls.take(3)) ...[
              CallCard(call: call),
              SizedBox(height: 14.h),
            ],
          ],
        ),
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

class _FeedbackCard extends StatelessWidget {
  final Color color;
  final String emoji;
  final String title;
  final int count;
  final String timesLabel;
  final VoidCallback onTap;

  const _FeedbackCard({
    required this.color,
    required this.emoji,
    required this.title,
    required this.count,
    required this.timesLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Haptics.tap();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emoji, style: TextStyle(fontSize: 46.sp)),
                  const Spacer(),
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.chevron_right_rounded,
                        color: color, size: 26.r),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(title,
                  style: AppTextStyles.button.copyWith(fontSize: 21.sp)),
              SizedBox(height: 6.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$count',
                      style: AppTextStyles.button
                          .copyWith(fontSize: 34.sp, height: 1)),
                  SizedBox(width: 6.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 3.h),
                    child: Text(timesLabel,
                        style: AppTextStyles.button.copyWith(
                            fontSize: 17.sp,
                            color: Colors.white.withValues(alpha: 0.8))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VocabStat extends StatelessWidget {
  final String label;
  final int count;

  const _VocabStat({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyGrey.copyWith(fontSize: 18.sp)),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 22.r),
            SizedBox(width: 6.w),
            Text('$count',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 24.sp)),
          ],
        ),
      ],
    );
  }
}

class _StreakPill extends StatelessWidget {
  final Color color;
  final Color background;
  final String label;
  final int value;

  const _StreakPill({
    required this.color,
    required this.background,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Center(
                child: Text('🔥', style: TextStyle(fontSize: 20.sp))),
          ),
          SizedBox(width: 12.w),
          Text(label,
              style: AppTextStyles.itemTitle.copyWith(color: color)),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text('$value',
                style: AppTextStyles.itemTitle.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

class _TimeStat extends StatelessWidget {
  final String label;
  final int seconds;

  const _TimeStat({required this.label, required this.seconds});

  String get _label {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (s == 0) return '$m m';
    return '$m m $s s';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.bodyGrey.copyWith(fontSize: 17.sp)),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.hourglass_bottom_rounded,
                  color: AppColors.chartBar, size: 20.r),
              SizedBox(width: 4.w),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(_label,
                      style: AppTextStyles.sectionTitle
                          .copyWith(fontSize: 20.sp)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Last-7-days call time bar chart (pure widgets, no chart package).
class _WeekBarChart extends StatelessWidget {
  final StatsState stats;

  const _WeekBarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final days = stats.last7Days;
    final maxSeconds =
        days.fold<int>(0, (max, e) => e.value > max ? e.value : max);
    final chartHeight = 150.h;

    return SizedBox(
      height: chartHeight + 54.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final entry in days)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (entry.value > 0) ...[
                    Text(
                      '${(entry.value / 60).round()}m',
                      style: AppTextStyles.small.copyWith(
                          color: AppColors.chartBar,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 34.w,
                      height: maxSeconds == 0
                          ? 0
                          : chartHeight * (entry.value / maxSeconds),
                      decoration: BoxDecoration(
                        color: AppColors.chartBar,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ] else
                    Container(
                      width: 34.w,
                      height: 2,
                      color: AppColors.divider,
                    ),
                  SizedBox(height: 10.h),
                  Text(
                    _weekdayLabel(context, entry.key),
                    style:
                        AppTextStyles.small.copyWith(fontSize: 15.sp),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _weekdayLabel(BuildContext context, DateTime day) {
    const labels = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
    return labels[day.weekday - 1];
  }
}
