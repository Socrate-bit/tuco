import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/model/models.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../curriculum/data/curriculum_data.dart';
import '../../curriculum/data/lesson_icons.dart';
import '../../curriculum/model/curriculum_models.dart';
import '../screen/transcript_screen.dart';

/// One call row: lesson icon (or video-cam), title, date, chevron.
class CallCard extends StatelessWidget {
  final CallRecord call;

  const CallCard({super.key, required this.call});

  Lesson? get _lesson => CurriculumData.lessonById(call.lessonId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lesson = _lesson;
    final color = lesson != null ? Color(lesson.color) : AppColors.primary;
    final icon =
        lesson != null ? LessonIcons.of(lesson.icon) : Icons.videocam_rounded;
    final title = call.type == 'free' ? l10n.freeConversation : call.title;
    final dateFormat = DateFormat("d MMMM yyyy, h:mm a", 'fr');

    return GestureDetector(
      onTap: () {
        Haptics.tap();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TranscriptScreen(call: call, title: title)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: [
            Container(
              width: 58.r,
              height: 58.r,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.itemTitle.copyWith(fontSize: 21.sp)),
                  SizedBox(height: 4.h),
                  Text(dateFormat.format(call.startedAt),
                      style: AppTextStyles.itemSubtitle
                          .copyWith(fontSize: 17.sp)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.navy, size: 28.r),
          ],
        ),
      ),
    );
  }
}
