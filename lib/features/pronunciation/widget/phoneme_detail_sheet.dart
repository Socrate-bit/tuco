import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/pronunciation_review_cubit.dart';
import '../screen/word_detail_screen.dart';
import 'pronunciation_review.dart';
import 'record_sheet.dart';

/// Embeddable pronunciation review: overall score header, the colored sentence
/// and its IPA, example / listen / try-again actions, and the sub-scores.
/// Expects a [PronunciationReviewCubit] provided above it (message feedback
/// modal's Pronunciation tab).
class PronunciationReviewBody extends StatelessWidget {
  final String languageCode;

  const PronunciationReviewBody({super.key, required this.languageCode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PronunciationReviewCubit, PronunciationReviewState>(
      builder: (context, state) {
        final cubit = context.read<PronunciationReviewCubit>();
        final result = state.result;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    onToggle: (c) => c.toggleRecording(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
