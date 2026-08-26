import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/analytics_service.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../cubit/word_practice_cubit.dart';
import '../data/phoneme_tips.dart';
import '../model/pronunciation_result.dart';
import '../widget/pronunciation_review.dart';

/// Detailed practice screen for one word: score header, colored word + IPA,
/// example / listen / try-again actions and a per-phoneme detail column.
class WordDetailScreen extends StatelessWidget {
  final WordScore word;
  final String languageCode;

  const WordDetailScreen({
    super.key,
    required this.word,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => WordPracticeCubit(
        initial: word,
        languageCode: languageCode,
        analytics: ctx.read<AnalyticsService>(),
      ),
      child: const _WordDetailView(),
    );
  }
}

class _WordDetailView extends StatelessWidget {
  const _WordDetailView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.card,
      body: SafeArea(
        child: BlocBuilder<WordPracticeCubit, WordPracticeState>(
          builder: (context, state) {
            final cubit = context.read<WordPracticeCubit>();
            final word = state.word;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: BackCircleButton(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PronunciationHeader(score: word.accuracyScore),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          child: const Divider(
                              color: AppColors.divider,
                              height: 1,
                              thickness: 1),
                        ),
                        ColoredSentence(words: [word], fontSize: 34),
                        IpaLine(words: [word]),
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
                              onTap: state.canListen
                                  ? cubit.playRecording
                                  : null,
                            ),
                            ReviewActionButton(
                              icon: state.recording
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              label: l10n.tryAgainButton,
                              onTap: cubit.toggleRecording,
                              active: state.recording,
                              busy: state.assessing,
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        const Divider(
                            color: AppColors.divider, height: 1, thickness: 1),
                        _PhonemeColumn(word: word, l10n: l10n),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 8.h),
                  child: PrimaryButton(
                    label: l10n.continueButton,
                    onPressed: () {
                      Haptics.tap();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The per-phoneme detail list: each sound with its status and, when it needs
/// work, a short articulation tip. Falls back to syllable graphemes when Azure
/// returns no phoneme symbols (locales other than en-US / zh-CN).
class _PhonemeColumn extends StatelessWidget {
  final WordScore word;
  final AppLocalizations l10n;

  const _PhonemeColumn({required this.word, required this.l10n});

  ({String label, Color color}) _status(double score) {
    final color = bandColor(score);
    switch (pronBandOf(score)) {
      case PronBand.excellent:
        return (label: l10n.pronStatusExcellent, color: color);
      case PronBand.almost:
        return (label: l10n.pronStatusAlmost, color: color);
      case PronBand.incorrect:
        return (label: l10n.pronStatusIncorrect, color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    // (symbol, score, tip) rows.
    final rows = <({String symbol, double score, String? tip})>[];
    final hasSymbols = word.phonemes.any((p) => p.phoneme.isNotEmpty);
    if (hasSymbols) {
      for (final p in word.phonemes.where((p) => p.phoneme.isNotEmpty)) {
        final excellent = pronBandOf(p.accuracyScore) == PronBand.excellent;
        rows.add((
          symbol: '/${p.phoneme}/',
          score: p.accuracyScore,
          tip: excellent ? null : phonemeTip(p.phoneme),
        ));
      }
    } else {
      for (final s in word.syllables.where((s) => s.grapheme.isNotEmpty)) {
        rows.add((symbol: s.grapheme, score: s.accuracyScore, tip: null));
      }
    }
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final row in rows)
          Container(
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 72.w,
                  child: Text(row.symbol,
                      style: AppTextStyles.body.copyWith(fontSize: 22.sp)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_status(row.score).label,
                          style: AppTextStyles.itemTitle
                              .copyWith(color: _status(row.score).color)),
                      if (row.tip != null) ...[
                        SizedBox(height: 4.h),
                        Text(row.tip!, style: AppTextStyles.bodyGrey),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
