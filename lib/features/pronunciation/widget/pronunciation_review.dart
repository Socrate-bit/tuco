import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../model/pronunciation_result.dart';
import 'pronunciation_ring.dart';

// ---------------- Score bands ----------------

enum PronBand { excellent, almost, incorrect }

PronBand pronBandOf(double score) {
  if (score >= 80) return PronBand.excellent;
  if (score >= 60) return PronBand.almost;
  return PronBand.incorrect;
}

/// Three-tier highlight color (green / yellow / red) for text and labels —
/// distinct from the 4-tier ring color (which also uses blue at the top).
Color bandColor(double score) => switch (pronBandOf(score)) {
      PronBand.excellent => AppColors.scoreGreen,
      PronBand.almost => AppColors.scoreOrange,
      PronBand.incorrect => AppColors.scoreRed,
    };

/// Tuco mascot expression for a band.
String pronBandAsset(PronBand band) => switch (band) {
      PronBand.excellent => 'assets/images/game/pet_rest_animation.gif',
      PronBand.almost => 'assets/images/game/bored_pet.gif',
      PronBand.incorrect => 'assets/images/game/sad_pet.gif',
    };

String pronBandLabel(AppLocalizations l10n, PronBand band) => switch (band) {
      PronBand.excellent => l10n.pronBandExcellent,
      PronBand.almost => l10n.pronBandAlmost,
      PronBand.incorrect => l10n.pronBandIncorrect,
    };

// ---------------- Header ----------------

/// Tuco avatar + band label + "You sound X% like a native speaker" + ring.
class PronunciationHeader extends StatelessWidget {
  final double score;

  const PronunciationHeader({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final band = pronBandOf(score);
    return Row(
      children: [
        ClipOval(
          child: Image.asset(pronBandAsset(band),
              width: 56.r, height: 56.r, fit: BoxFit.cover),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pronBandLabel(l10n, band),
                  style: AppTextStyles.itemTitle
                      .copyWith(color: bandColor(score))),
              SizedBox(height: 2.h),
              _NativeSpeakerScore(score: score.round()),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        PronunciationRing(score: score, size: 52, stroke: 5, showLabel: true),
      ],
    );
  }
}

/// "You sound {score}% like a native speaker!" with the number bolded.
/// Splits the localized string around the number so it works in any locale.
class _NativeSpeakerScore extends StatelessWidget {
  final int score;

  const _NativeSpeakerScore({required this.score});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = l10n.nativeSpeakerScore(score);
    final numStr = '$score';
    final base = AppTextStyles.bodyGrey;
    final parts = text.split(numStr);
    // Fallback: number not found in the resolved string.
    if (parts.length < 2) return Text(text, style: base);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: parts.first),
          TextSpan(
              text: numStr,
              style: base.copyWith(fontWeight: FontWeight.w800)),
          TextSpan(text: parts.sublist(1).join(numStr)),
        ],
      ),
    );
  }
}

// ---------------- Colored text ----------------

/// Colored spans for one word: each syllable grapheme tinted by its score
/// (approximate per-letter coloring), or the whole word when no syllables.
List<InlineSpan> wordSpans(WordScore word,
    {required double fontSize, bool underline = true}) {
  final base = AppTextStyles.body
      .copyWith(fontSize: fontSize, fontWeight: FontWeight.w800);
  TextStyle styled(double score) => base.copyWith(
        color: bandColor(score),
        decoration: underline ? TextDecoration.underline : null,
        decorationColor: bandColor(score),
      );
  final syllables = word.syllables.where((s) => s.grapheme.isNotEmpty).toList();
  if (syllables.isEmpty) {
    return [TextSpan(text: word.word, style: styled(word.accuracyScore))];
  }
  return [
    for (final s in syllables)
      TextSpan(text: s.grapheme, style: styled(s.accuracyScore)),
  ];
}

/// The recognized sentence, each word colored by its score and (optionally)
/// tappable to open the word detail.
class ColoredSentence extends StatelessWidget {
  final List<WordScore> words;
  final void Function(WordScore word)? onWordTap;
  final double fontSize;

  const ColoredSentence({
    super.key,
    required this.words,
    this.onWordTap,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 6.h,
      children: [
        for (final w in words)
          GestureDetector(
            onTap: onWordTap == null
                ? null
                : () {
                    Haptics.tap();
                    onWordTap!(w);
                  },
            child: Text.rich(
              TextSpan(children: wordSpans(w, fontSize: fontSize.sp)),
            ),
          ),
      ],
    );
  }
}

/// The IPA transcription, each phoneme colored by its score. Renders nothing
/// when the provider returns no phoneme symbols (locales other than en-US / zh-CN).
class IpaLine extends StatelessWidget {
  final List<WordScore> words;

  const IpaLine({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    final hasSymbols =
        words.any((w) => w.phonemes.any((p) => p.phoneme.isNotEmpty));
    if (!hasSymbols) return const SizedBox.shrink();

    final base = AppTextStyles.body.copyWith(fontSize: 20.sp);
    final spans = <InlineSpan>[TextSpan(text: '/', style: base)];
    for (var i = 0; i < words.length; i++) {
      for (final p in words[i].phonemes.where((p) => p.phoneme.isNotEmpty)) {
        spans.add(TextSpan(
            text: p.phoneme,
            style: base.copyWith(color: bandColor(p.accuracyScore))));
      }
      if (i != words.length - 1) spans.add(TextSpan(text: ' ', style: base));
    }
    spans.add(TextSpan(text: '/', style: base));
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Text.rich(TextSpan(children: spans)),
    );
  }
}

// ---------------- Sub-scores ----------------

/// Pronunciation / Fluency / Rhythm, each colored by its value. Rhythm is blank
/// when the provider returns no prosody (available for en-US only).
class SubScoresRow extends StatelessWidget {
  final PronunciationResult result;

  const SubScoresRow({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <(String, double?)>[
      (l10n.pronPronunciation, result.accuracyScore),
      (l10n.pronFluency, result.fluencyScore),
      (l10n.pronRhythm, result.prosodyScore),
    ];
    return Row(
      children: [
        for (final (label, score) in items)
          Expanded(
            child: Column(
              children: [
                Text(
                  score == null ? '—' : '${score.round()}',
                  style: AppTextStyles.itemTitle.copyWith(
                      color: score == null
                          ? AppColors.textLightGrey
                          : bandColor(score)),
                ),
                SizedBox(height: 2.h),
                Text(label,
                    style: AppTextStyles.small, textAlign: TextAlign.center),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------- Action buttons ----------------

/// A circular icon button used in the Example / Listen / Try-again row.
class ReviewActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;
  final bool busy;

  const ReviewActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !busy;
    final color = active ? AppColors.scoreRed : AppColors.primary;
    return GestureDetector(
      onTap: enabled
          ? () {
              Haptics.tap();
              onTap!();
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration:
                  const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
              child: busy
                  ? Padding(
                      padding: EdgeInsets.all(16.r),
                      child: const CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.black),
                    )
                  : Icon(icon, color: color, size: 26.r),
            ),
            SizedBox(height: 6.h),
            Text(label, style: AppTextStyles.small),
          ],
        ),
      ),
    );
  }
}
