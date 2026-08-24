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
import '../../streak/widget/streak_milestone_card.dart';
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
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 130.h),
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
            const StreakMilestoneCard(),
            SizedBox(height: 16.h),
            _LongestStreakCard(value: stats.longestStreak),
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

/// "Série la plus longue" record card: trophy art, value and label.
class _LongestStreakCard extends StatelessWidget {
  final int value;

  const _LongestStreakCard({required this.value});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          Image.asset('assets/images/trophy.png', width: 56.r, height: 56.r),
          SizedBox(height: 4.h),
          Text('$value',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 32.sp)),
          Text(l10n.longestStreak, style: AppTextStyles.itemSubtitle),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label,
                maxLines: 1,
                style: AppTextStyles.bodyGrey.copyWith(fontSize: 15.sp)),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.hourglass_bottom_rounded,
                  color: AppColors.chartBar, size: 18.r),
              SizedBox(width: 4.w),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(_label,
                      maxLines: 1,
                      style: AppTextStyles.sectionTitle
                          .copyWith(fontSize: 17.sp)),
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
    final labelHeight = 24.h;

    return SizedBox(
      height: 200.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final entry in days)
            Expanded(
              child: Column(
                children: [
                  // Bar zone: value label + bar sized from available space
                  // so tall bars can never overflow.
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final barMax = constraints.maxHeight - labelHeight;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (entry.value > 0) ...[
                              SizedBox(
                                height: labelHeight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${(entry.value / 60).round()}m',
                                    style: AppTextStyles.small.copyWith(
                                        color: AppColors.chartBar,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                              Container(
                                width: 34.w,
                                height: maxSeconds == 0
                                    ? 0
                                    : barMax * (entry.value / maxSeconds),
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
                          ],
                        );
                      },
                    ),
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
