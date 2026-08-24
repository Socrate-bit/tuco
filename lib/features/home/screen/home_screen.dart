import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/model/app_language.dart';
import '../../../core/service/data_repository.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../call/screen/call_screen.dart';
import '../../curriculum/model/curriculum_models.dart';
import '../../streak/screen/streak_screen.dart';
import '../cubit/path_cubit.dart';
import '../widget/home_header.dart';
import '../widget/lesson_path.dart';
import '../widget/lesson_sheets.dart';

/// Home tab: fixed robot header + scrollable winding lesson path.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollCtrl = ScrollController();
  bool _showScrollTop = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final show = _scrollCtrl.offset > 400.h;
      if (show != _showScrollTop) setState(() => _showScrollTop = show);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pathState = context.watch<PathCubit>().state;

    String levelTitle(String id) => switch (id) {
          'beginner' => l10n.levelBeginner,
          'intermediate' => l10n.levelIntermediate,
          _ => l10n.levelAdvanced,
        };

    return Scaffold(
      backgroundColor: AppColors.card,
      body: Stack(
        children: [
          Column(
            children: [
              HomeHeader(
                onStreakTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StreakScreen())),
                onExchangeTap: _startFreeConversation,
              ),
              Expanded(
                child: ListView(
                  controller: _scrollCtrl,
                  padding: EdgeInsets.only(bottom: 130.h),
                  children: [
                    for (final level in pathState.levels)
                      LevelSection(
                        title: levelTitle(level.id),
                        lessons: level.lessons,
                        pathState: pathState,
                        onLessonTap: (lesson) => _onLessonTap(lesson, pathState),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Scroll-to-top floating button.
          if (_showScrollTop)
            Positioned(
              right: 20.w,
              bottom: 120.h,
              child: GestureDetector(
                onTap: () {
                  Haptics.tap();
                  _scrollCtrl.animateTo(0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut);
                },
                child: Container(
                  width: 60.r,
                  height: 60.r,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: AppColors.divider, width: 1.5),
                  ),
                  child: Icon(Icons.arrow_upward_rounded,
                      color: AppColors.primary, size: 30.r),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onLessonTap(Lesson lesson, PathState pathState) async {
    final status = pathState.statusOf(lesson);

    // Locked lessons ask for confirmation before skipping ahead.
    if (status == LessonStatus.locked) {
      final skip = await showSkipLessonDialog(
          context, AppLanguages.labelOf(pathState.targetLanguage));
      if (skip != true || !mounted) return;
    }

    await _openLesson(lesson);
  }

  Future<void> _openLesson(Lesson lesson) async {
    final repo = context.read<DataRepository>();

    // In-progress session → propose resume/restart.
    final saved = await repo.getSavedSession(lesson.id);
    if (!mounted) return;
    if (saved != null) {
      final choice = await showResumeLessonSheet(context);
      if (choice == null || !mounted) return;
      if (choice == 'restart') await repo.deleteSession(lesson.id);
      if (!mounted) return;
      _startCall(CallScreenArgs(
        lesson: lesson,
        resumeSession: choice == 'resume' ? saved : null,
      ));
      return;
    }

    final choice = await showLessonStartSheet(context, lesson);
    if (choice == null || !mounted) return;
    _startCall(CallScreenArgs(
      lesson: lesson,
      startAtPractice: choice == 'practice',
    ));
  }

  void _startFreeConversation() =>
      _startCall(const CallScreenArgs(lesson: null));

  void _startCall(CallScreenArgs args) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CallScreen(args: args)),
    );
  }
}
