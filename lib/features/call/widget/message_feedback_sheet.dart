import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/model/models.dart';
import '../../../core/service/analytics_service.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../feedback/cubit/feedback_cubit.dart';
import '../../pronunciation/cubit/pronunciation_review_cubit.dart';
import '../../pronunciation/model/pronunciation_result.dart';
import '../../pronunciation/widget/phoneme_detail_sheet.dart';
import '../../pronunciation/widget/pronunciation_review.dart';

/// Feedback modal for one user message, with two tabs: Grammar (correct /
/// incorrect, CEFR level, corrections and a more advanced alternative) and
/// Pronunciation (the full pronunciation review). Opened by tapping the
/// message bubble. Shared by the live call screen and the transcript screen.
Future<void> showMessageFeedbackSheet(
  BuildContext context, {
  required ChatMessage message,
  required String languageCode,
  void Function(PronunciationResult result, String? recordingUrl)?
      onPronunciationUpdated,
}) {
  Haptics.tap();
  final feedbackCubit = context.read<FeedbackCubit>();
  final analytics = context.read<AnalyticsService>();
  final pron = message.pronunciation;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      final sheet = BlocProvider.value(
        value: feedbackCubit,
        child: _MessageFeedbackSheet(
            message: message, languageCode: languageCode),
      );
      if (pron == null) return sheet;
      // The review cubit lives at modal level so the score in the tab selector
      // stays in sync with "try again" re-scores.
      return BlocProvider(
        create: (_) => PronunciationReviewCubit(
          initial: pron,
          recordingUrl: message.recordingUrl,
          localRecordingPath: message.localRecordingPath,
          languageCode: languageCode,
          referenceText: pron.recognizedText,
          analytics: analytics,
          onUpdated: onPronunciationUpdated,
        ),
        child: sheet,
      );
    },
  );
}

class _MessageFeedbackSheet extends StatefulWidget {
  final ChatMessage message;
  final String languageCode;

  const _MessageFeedbackSheet(
      {required this.message, required this.languageCode});

  @override
  State<_MessageFeedbackSheet> createState() => _MessageFeedbackSheetState();
}

class _MessageFeedbackSheetState extends State<_MessageFeedbackSheet> {
  late int _tab; // 0 = grammar, 1 = pronunciation

  @override
  void initState() {
    super.initState();
    // Default to the tab that has something to say: grammar issues first,
    // otherwise the pronunciation review when the message was spoken.
    final item =
        context.read<FeedbackCubit>().state.grammarFor(widget.message.text);
    final hasGrammarIssue = item != null &&
        (item.corrections.isNotEmpty ||
            (item.alternative?.isNotEmpty ?? false));
    _tab =
        !hasGrammarIssue && widget.message.pronunciation != null ? 1 : 0;
  }

  void _selectTab(int tab) {
    if (_tab == tab) return;
    Haptics.select();
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item =
        context.watch<FeedbackCubit>().state.grammarFor(widget.message.text);
    final hasPron = widget.message.pronunciation != null;
    // Live score (follows "try again" re-scores) when the message was spoken.
    final pronScore = hasPron
        ? context.watch<PronunciationReviewCubit>().state.result.pronScore
        : null;

    return Container(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                _TabSelector(
                  title: l10n.grammar,
                  metric: _GrammarMetric(item: item),
                  selected: _tab == 0,
                  onTap: () => _selectTab(0),
                ),
                SizedBox(width: 12.w),
                _TabSelector(
                  title: l10n.pronunciationSheetTitle,
                  metric: _PronunciationMetric(score: pronScore),
                  selected: _tab == 1,
                  onTap: () => _selectTab(1),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Flexible(
              child: SingleChildScrollView(
                child: _tab == 0
                    ? _GrammarDetail(item: item)
                    : hasPron
                        ? PronunciationReviewBody(
                            languageCode: widget.languageCode)
                        : Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: Center(
                              child: Text(l10n.pronNoRecording,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyGrey),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the two tab buttons: tab title on top, headline metric below.
class _TabSelector extends StatelessWidget {
  final String title;
  final Widget metric;
  final bool selected;
  final VoidCallback onTap;

  const _TabSelector({
    required this.title,
    required this.metric,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.card : AppColors.background,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(title, style: AppTextStyles.small),
              SizedBox(height: 6.h),
              metric,
            ],
          ),
        ),
      ),
    );
  }
}

/// "Correct / Incorrect" + CEFR level chip, or a dash while unanalysed.
class _GrammarMetric extends StatelessWidget {
  final FeedbackItem? item;

  const _GrammarMetric({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (item == null) {
      return Text('—',
          style: AppTextStyles.itemTitle
              .copyWith(color: AppColors.textLightGrey));
    }
    final correct = item!.corrections.isEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            correct ? l10n.grammarCorrect : l10n.grammarIncorrect,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.itemTitle.copyWith(
                color:
                    correct ? AppColors.scoreGreen : AppColors.scoreRed),
          ),
        ),
        if (item!.level?.isNotEmpty ?? false) ...[
          SizedBox(width: 6.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(item!.level!,
                style: AppTextStyles.small
                    .copyWith(color: AppColors.navy)),
          ),
        ],
      ],
    );
  }
}

/// Pronunciation percentage colored by band, or a dash for typed messages.
class _PronunciationMetric extends StatelessWidget {
  final double? score;

  const _PronunciationMetric({required this.score});

  @override
  Widget build(BuildContext context) {
    if (score == null) {
      return Text('—',
          style: AppTextStyles.itemTitle
              .copyWith(color: AppColors.textLightGrey));
    }
    return Text('${score!.round()}%',
        style: AppTextStyles.itemTitle.copyWith(color: bandColor(score!)));
  }
}

/// Grammar tab body: corrections with explanations, then the more advanced
/// alternative phrasing when one exists.
class _GrammarDetail extends StatelessWidget {
  final FeedbackItem? item;

  const _GrammarDetail({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (item == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: Text(l10n.grammarNoFeedback,
              textAlign: TextAlign.center, style: AppTextStyles.bodyGrey),
        ),
      );
    }
    final corrections = item!.corrections;
    // final alternative = item!.alternative;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (corrections.isEmpty)
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.scoreGreen, size: 24.r),
              SizedBox(width: 10.w),
              Expanded(
                child:
                    Text(l10n.grammarAllGood, style: AppTextStyles.body),
              ),
            ],
          )
        else
          for (final c in corrections) ...[
            // Wrap so long corrections flow onto multiple lines.
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
                      style:
                          AppTextStyles.body.copyWith(color: Colors.white)),
                ),
              ],
            ),
            if (c.explanation.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(c.explanation, style: AppTextStyles.bodyGrey),
            ],
            SizedBox(height: 16.h),
          ],
        // "Take it further" (alternative phrasing) section — hidden for now.
        // if (alternative?.isNotEmpty ?? false) ...[
        //   Padding(
        //     padding: EdgeInsets.symmetric(vertical: 14.h),
        //     child: const Divider(
        //         color: AppColors.divider, thickness: 1, height: 1),
        //   ),
        //   Row(
        //     children: [
        //       Icon(Icons.lightbulb_rounded,
        //           color: AppColors.streakOrange, size: 22.r),
        //       SizedBox(width: 8.w),
        //       Text(l10n.sayItBetter, style: AppTextStyles.itemTitle),
        //     ],
        //   ),
        //   SizedBox(height: 10.h),
        //   Container(
        //     width: double.infinity,
        //     padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        //     decoration: BoxDecoration(
        //       color: AppColors.primaryLight,
        //       borderRadius: BorderRadius.circular(14.r),
        //     ),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text(alternative!, style: AppTextStyles.body),
        //         if (item!.alternativeTranslation?.isNotEmpty ?? false) ...[
        //           SizedBox(height: 4.h),
        //           Text(item!.alternativeTranslation!,
        //               style: AppTextStyles.bodyGrey
        //                   .copyWith(fontStyle: FontStyle.italic)),
        //         ],
        //       ],
        //     ),
        //   ),
        //   if (item!.alternativeExplanation?.isNotEmpty ?? false) ...[
        //     SizedBox(height: 10.h),
        //     Text(item!.alternativeExplanation!,
        //         style: AppTextStyles.bodyGrey),
        //   ],
        // ],
      ],
    );
  }
}
