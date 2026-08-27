import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/analytics_service.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/pronunciation_review_cubit.dart';
import '../model/pronunciation_result.dart';
import '../screen/word_detail_screen.dart';
import 'pronunciation_review.dart';
import 'record_sheet.dart';

/// Message pronunciation review sheet: overall score, the colored sentence and
/// its IPA, example / listen / try-again actions, and the sub-scores.
Future<void> showPronunciationReview(
  BuildContext context, {
  required PronunciationResult result,
  required String? recordingUrl,
  required String languageCode,
  void Function(PronunciationResult result, String? recordingUrl)? onUpdated,
}) {
  Haptics.tap();
  final analytics = context.read<AnalyticsService>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => PronunciationReviewCubit(
        initial: result,
        recordingUrl: recordingUrl,
        languageCode: languageCode,
        referenceText: result.recognizedText,
        analytics: analytics,
        onUpdated: onUpdated,
      ),
      child: _ReviewSheet(languageCode: languageCode),
    ),
  );
}

class _ReviewSheet extends StatelessWidget {
  final String languageCode;

  const _ReviewSheet({required this.languageCode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PronunciationReviewCubit, PronunciationReviewState>(
      builder: (context, state) {
        final cubit = context.read<PronunciationReviewCubit>();
        final result = state.result;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(height: 20.h),
                  PronunciationHeader(score: result.pronScore),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    child: const Divider(
                      color: AppColors.divider,
                      height: 1,
                      thickness: 1,
                    ),
                  ),
                  ColoredSentence(
                    words: result.words,
                    onWordTap: (w) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WordDetailScreen(
                          word: w,
                          languageCode: languageCode,
                        ),
                      ),
                    ),
                  ),
                  IpaLine(words: result.words),
                  SizedBox(height: 24.h),
                  SubScoresRow(result: result),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ReviewActionButton(
                        icon: Icons.volume_up_rounded,
                        label: l10n.pronExampleButton,
                        onTap: cubit.playExample,
                      ),
                      ReviewActionButton(
                        icon: Icons.graphic_eq_rounded,
                        label: l10n.pronListenButton,
                        onTap: state.canListen ? cubit.playRecording : null,
                      ),
                      ReviewActionButton(
                        icon: Icons.mic_rounded,
                        label: l10n.tryAgainButton,
                        onTap: () => showRecordSheet<PronunciationReviewCubit,
                            PronunciationReviewState>(
                          context,
                          cubit: cubit,
                          recording: (s) => s.recording,
                          assessing: (s) => s.assessing,
                          onStart: (c) => c.startRecording(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
