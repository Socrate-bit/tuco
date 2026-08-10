import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/model/models.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../curriculum/data/curriculum_data.dart';
import '../../curriculum/data/lesson_icons.dart';
import '../../curriculum/model/curriculum_models.dart';
import '../screen/grammar_screen.dart';

/// Expandable feedback card: score pill, sentence with highlighted errors;
/// expanded → corrections with explanations + lesson footer.
class FeedbackCard extends StatefulWidget {
  final FeedbackItem item;

  const FeedbackCard({super.key, required this.item});

  @override
  State<FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<FeedbackCard> {
  bool _expanded = false;

  Color get _scoreColor => switch (scoreBandOf(widget.item.score)) {
        ScoreBand.excellent => AppColors.scoreGreen,
        ScoreBand.canDoBetter => AppColors.scoreOrange,
        ScoreBand.needsImprovement => AppColors.scoreRed,
      };

  String _scoreLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (scoreBandOf(widget.item.score)) {
      ScoreBand.excellent => l10n.scoreExcellent,
      ScoreBand.canDoBetter => l10n.scoreCanDoBetter,
      ScoreBand.needsImprovement => l10n.scoreNeedsImprovement,
    };
  }

  Lesson? get _lesson {
    for (final level in CurriculumData.levels) {
      for (final lesson in level.lessons) {
        if (lesson.id == widget.item.lessonId) return lesson;
      }
    }
    return null;
  }

  /// Sentence with erroneous fragments highlighted red + underlined.
  TextSpan _highlightedSentence() {
    final text = widget.item.originalText;
    final baseStyle = AppTextStyles.body.copyWith(fontSize: 22.sp);
    final errorStyle = baseStyle.copyWith(
      backgroundColor: AppColors.scoreRedBg,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.scoreRed,
    );

    final wrongs = widget.item.corrections
        .map((c) => c.wrong)
        .where((w) => w.isNotEmpty)
        .toList();
    if (wrongs.isEmpty) return TextSpan(text: text, style: baseStyle);

    final spans = <TextSpan>[];
    var rest = text;
    while (rest.isNotEmpty) {
      var earliest = -1;
      String? match;
      for (final w in wrongs) {
        final idx = rest.toLowerCase().indexOf(w.toLowerCase());
        if (idx >= 0 && (earliest == -1 || idx < earliest)) {
          earliest = idx;
          match = w;
        }
      }
      if (match == null) {
        spans.add(TextSpan(text: rest, style: baseStyle));
        break;
      }
      if (earliest > 0) {
        spans.add(
            TextSpan(text: rest.substring(0, earliest), style: baseStyle));
      }
      spans.add(TextSpan(
          text: rest.substring(earliest, earliest + match.length),
          style: errorStyle));
      rest = rest.substring(earliest + match.length);
    }
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lesson = _lesson;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        color: AppColors.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Collapsed part: score pill + sentence + chevron.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Haptics.tap();
                setState(() => _expanded = !_expanded);
              },
              child: Padding(
                padding: EdgeInsets.all(18.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: _scoreColor, width: 1.5),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              l10n.scoreLabel(
                                  widget.item.score, _scoreLabel(context)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.small.copyWith(
                                  color: _scoreColor, fontSize: 15.sp),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textGrey,
                          size: 28.r,
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text.rich(_highlightedSentence()),
                  ],
                ),
              ),
            ),
            // Expanded part: corrections + explanation.
            if (_expanded) ...[
              const Divider(color: AppColors.divider, thickness: 1, height: 1),
              Padding(
                padding: EdgeInsets.all(18.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final c in widget.item.corrections) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('•  ',
                              style:
                                  AppTextStyles.body.copyWith(fontSize: 22.sp)),
                          Flexible(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  c.wrong,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 21.sp,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.scoreRed,
                                    decorationThickness: 2,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Icon(Icons.arrow_forward_rounded,
                                      size: 20.r, color: AppColors.textDark),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.scoreGreenBg,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    c.right,
                                    style: AppTextStyles.body.copyWith(
                                        color: Colors.white, fontSize: 21.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (c.explanation.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Text(c.explanation,
                            style: AppTextStyles.bodyGrey
                                .copyWith(fontSize: 18.sp)),
                      ],
                      SizedBox(height: 14.h),
                    ],
                  ],
                ),
              ),
              // Lesson footer band.
              if (lesson != null)
                Container(
                  width: double.infinity,
                  color: AppColors.feedbackFooter,
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                            color: Color(lesson.color),
                            shape: BoxShape.circle),
                        child: Icon(LessonIcons.of(lesson.icon),
                            color: Colors.white, size: 24.r),
                      ),
                      SizedBox(width: 12.w),
                      Text(lesson.title,
                          style: AppTextStyles.itemTitle
                              .copyWith(fontSize: 19.sp)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
