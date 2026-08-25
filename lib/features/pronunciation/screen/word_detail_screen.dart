import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/analytics_service.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../call/service/tts_service.dart';
import '../../feedback/screen/grammar_screen.dart';
import '../cubit/word_practice_cubit.dart';
import '../model/pronunciation_result.dart';
import '../widget/pronunciation_ring.dart';

/// Detailed practice screen for one word: phoneme breakdown, a large score
/// ring and a "Try again" button to re-record and re-score the word alone.
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
      child: _WordDetailView(languageCode: languageCode),
    );
  }
}

class _WordDetailView extends StatefulWidget {
  final String languageCode;

  const _WordDetailView({required this.languageCode});

  @override
  State<_WordDetailView> createState() => _WordDetailViewState();
}

class _WordDetailViewState extends State<_WordDetailView> {
  final _tts = TtsService();

  @override
  void initState() {
    super.initState();
    _tts.init(widget.languageCode);
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

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
            final color = pronColor(word.accuracyScore);
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
                        Text(
                          word.word,
                          style: AppTextStyles.display
                              .copyWith(fontSize: 36.sp, color: color),
                        ),
                        SizedBox(height: 10.h),
                        // Sound-by-sound breakdown, each colored by its score.
                        // Prefer IPA phonemes (the precise detail); fall back to
                        // syllable graphemes when Azure omits phoneme symbols
                        // (locales other than en-US / zh-CN).
                        _BreakdownLine(word: word),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            _CircleIcon(
                              icon: Icons.volume_up_rounded,
                              onTap: () => _tts.speak(word.word),
                            ),
                            SizedBox(width: 12.w),
                            _CircleIcon(
                              icon: Icons.hearing_rounded,
                              onTap: () => _tts.speak(word.word),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                _ResultCard(
                  score: word.accuracyScore,
                  recording: state.recording,
                  assessing: state.assessing,
                  onTryAgain: () {
                    Haptics.impact();
                    cubit.toggleRecording();
                  },
                  onContinue: () {
                    Haptics.tap();
                    Navigator.of(context).pop();
                  },
                  l10n: l10n,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Precise sound-by-sound breakdown. Each syllable grapheme is shown with the
/// score of every phoneme inside it (grouped by audio offset). Phoneme symbols
/// appear when Azure provides them (en-US / zh-CN); otherwise the score alone is
/// shown — Spanish/French still get per-phoneme scores, just without symbols.
class _BreakdownLine extends StatelessWidget {
  final WordScore word;

  const _BreakdownLine({required this.word});

  List<PhonemeScore> _phonemesIn(SyllableScore s) {
    final end = s.offset + s.duration;
    return word.phonemes
        .where((p) =>
            p.offset >= s.offset && (s.duration == 0 || p.offset < end))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final syllables = word.syllables.where((s) => s.grapheme.isNotEmpty).toList();

    // Grouped view: grapheme header + its phoneme scores.
    if (syllables.isNotEmpty) {
      return Wrap(
        spacing: 18.w,
        runSpacing: 14.h,
        children: [
          for (final s in syllables)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.grapheme,
                  style: AppTextStyles.body.copyWith(
                      fontSize: 26.sp,
                      color: pronColor(s.accuracyScore),
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 4.w,
                  runSpacing: 4.h,
                  children: [
                    for (final p in _phonemesIn(s)) _PhonemeChip(phoneme: p),
                  ],
                ),
              ],
            ),
        ],
      );
    }

    // No graphemes: fall back to a flat row of phoneme score chips.
    if (word.phonemes.isNotEmpty) {
      return Wrap(
        spacing: 6.w,
        runSpacing: 6.h,
        children: [
          for (final p in word.phonemes) _PhonemeChip(phoneme: p),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

/// A small pill showing a phoneme's score, prefixed by its IPA symbol when
/// available.
class _PhonemeChip extends StatelessWidget {
  final PhonemeScore phoneme;

  const _PhonemeChip({required this.phoneme});

  @override
  Widget build(BuildContext context) {
    final color = pronColor(phoneme.accuracyScore);
    final label = phoneme.phoneme.isNotEmpty
        ? '${phoneme.phoneme} ${phoneme.accuracyScore.round()}'
        : '${phoneme.accuracyScore.round()}';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(label,
          style: AppTextStyles.small.copyWith(color: color, fontSize: 14.sp)),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final double score;
  final bool recording;
  final bool assessing;
  final VoidCallback onTryAgain;
  final VoidCallback onContinue;
  final AppLocalizations l10n;

  const _ResultCard({
    required this.score,
    required this.recording,
    required this.assessing,
    required this.onTryAgain,
    required this.onContinue,
    required this.l10n,
  });

  ({String emoji, String label}) _band() {
    switch (scoreBandOf(score.round())) {
      case ScoreBand.excellent:
        return (emoji: '😃', label: l10n.scoreExcellent);
      case ScoreBand.canDoBetter:
        return (emoji: '🙂', label: l10n.scoreCanDoBetter);
      case ScoreBand.needsImprovement:
        return (emoji: '😕', label: l10n.scoreNeedsImprovement);
    }
  }

  @override
  Widget build(BuildContext context) {
    final band = _band();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(band.emoji, style: TextStyle(fontSize: 34.sp)),
                SizedBox(width: 12.w),
                Text(band.label,
                    style: AppTextStyles.modalTitle
                        .copyWith(color: pronColor(score))),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.nativeSpeakerScore(score.round()),
                    style: AppTextStyles.body,
                  ),
                ),
                SizedBox(width: 16.w),
                PronunciationRing(
                    score: score, size: 60, stroke: 6, showLabel: true),
              ],
            ),
            SizedBox(height: 20.h),
            if (assessing)
              SizedBox(
                height: 58.h,
                child: Center(
                  child: SizedBox(
                    width: 28.r,
                    height: 28.r,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.primary),
                  ),
                ),
              )
            else
              PrimaryButton(
                label: recording
                    ? l10n.stopRecordingButton
                    : l10n.tryAgainButton,
                color: recording ? AppColors.scoreRed : AppColors.primary,
                shadowColor:
                    recording ? AppColors.scoreRed : AppColors.primaryDark,
                onPressed: onTryAgain,
              ),
            SizedBox(height: 8.h),
            TextLinkButton(label: l10n.continueButton, onPressed: onContinue),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: Container(
        width: 54.r,
        height: 54.r,
        decoration: const BoxDecoration(
            color: AppColors.background, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primary, size: 26.r),
      ),
    );
  }
}
