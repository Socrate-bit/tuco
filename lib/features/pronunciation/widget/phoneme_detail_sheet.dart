import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../call/service/tts_service.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../model/pronunciation_result.dart';
import '../screen/word_detail_screen.dart';
import 'pronunciation_ring.dart';

/// Bottom sheet: the recognized sentence with each word colored by its
/// pronunciation score. Tap a word to open its detailed practice screen.
Future<void> showPhonemeDetailSheet(
    BuildContext context, PronunciationResult result) {
  Haptics.tap();
  final languageCode = context.read<ProfileCubit>().state.targetLanguage;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _PhonemeDetailSheet(result: result, languageCode: languageCode),
  );
}

class _PhonemeDetailSheet extends StatefulWidget {
  final PronunciationResult result;
  final String languageCode;

  const _PhonemeDetailSheet(
      {required this.result, required this.languageCode});

  @override
  State<_PhonemeDetailSheet> createState() => _PhonemeDetailSheetState();
}

class _PhonemeDetailSheetState extends State<_PhonemeDetailSheet> {
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
    final result = widget.result;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle.
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
            // Header: overall score + play sentence.
            Row(
              children: [
                PronunciationRing(
                    score: result.pronScore,
                    size: 52,
                    stroke: 5,
                    showLabel: true),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(l10n.pronunciationSheetTitle,
                      style: AppTextStyles.modalTitle),
                ),
                _CircleIcon(
                  icon: Icons.volume_up_rounded,
                  onTap: () => _tts.speak(result.recognizedText),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // Sub-scores: the overall ring blends these, so it can sit below
            // the per-word accuracy tiles even when every word scores high.
            _SubScores(result: result, l10n: l10n),
            SizedBox(height: 24.h),
            // Words colored by their accuracy score, each tappable.
            Wrap(
              spacing: 8.w,
              runSpacing: 10.h,
              children: [
                for (final w in result.words)
                  GestureDetector(
                    onTap: () {
                      Haptics.tap();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WordDetailScreen(
                            word: w,
                            languageCode: widget.languageCode,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      w.word,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 22.sp,
                        color: pronColor(w.accuracyScore),
                        decoration: TextDecoration.underline,
                        decorationColor:
                            pronColor(w.accuracyScore).withValues(alpha: 0.4),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(l10n.pronunciationTapWordHint, style: AppTextStyles.bodyGrey),
          ],
        ),
      ),
    );
  }
}

/// The four dimensions that make up the overall score, so the user can see
/// why the sentence ring differs from the per-word accuracy tiles.
class _SubScores extends StatelessWidget {
  final PronunciationResult result;
  final AppLocalizations l10n;

  const _SubScores({required this.result, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final items = <(String, double)>[
      (l10n.pronAccuracy, result.accuracyScore),
      (l10n.pronFluency, result.fluencyScore),
      if (result.prosodyScore != null)
        (l10n.pronProsody, result.prosodyScore!),
      (l10n.pronCompleteness, result.completenessScore),
    ];
    return Row(
      children: [
        for (final (label, score) in items)
          Expanded(
            child: Column(
              children: [
                Text('${score.round()}',
                    style: AppTextStyles.itemTitle
                        .copyWith(color: pronColor(score))),
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
        width: 48.r,
        height: 48.r,
        decoration: const BoxDecoration(
            color: AppColors.background, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primary, size: 24.r),
      ),
    );
  }
}
