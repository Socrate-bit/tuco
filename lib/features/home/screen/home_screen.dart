import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/cubit/connectivity_cubit.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/model/app_language.dart';
import '../../../core/service/data_repository.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../call/screen/call_screen.dart';
import '../../curriculum/model/curriculum_models.dart';
import '../../game/cubit/game_cubit.dart';
import '../../game/screen/hospital_screen.dart';
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
    _jumpToCurrentLesson(context.read<PathCubit>().state);
  }

  /// Opens the path on the current lesson: learners who declared an
  /// intermediate/advanced level start below the levels unlocked for review.
  void _jumpToCurrentLesson(PathState pathState) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollCtrl.hasClients) return;
      _scrollCtrl.jumpTo(_currentLessonOffset(pathState)
          .clamp(0.0, _scrollCtrl.position.maxScrollExtent));
    });
  }

  /// Scroll offset placing the current lesson just under the header.
  double _currentLessonOffset(PathState pathState) {
    final current = pathState.currentLesson;
    var offset = 0.0;
    for (final level in pathState.levels) {
      final i = level.lessons.indexWhere((l) => l.id == current.id);
      if (i >= 0) return offset + LevelSection.lessonOffset(i) - 40.h;
      offset += LevelSection.sectionHeight(level.lessons.length);
    }
    return 0;
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

    return BlocListener<PathCubit, PathState>(
      // Anything moving the current lesson — the profile arriving, the learner
      // changing level/language, or completion data loading from its own stream
      // — re-opens the path on it.
      listenWhen: (prev, next) =>
          prev.currentLesson.id != next.currentLesson.id ||
          prev.targetLanguage != next.targetLanguage,
      listener: (_, state) => _jumpToCurrentLesson(state),
      child: Scaffold(
        backgroundColor: AppColors.card,
        body: Stack(
          children: [
            Column(
              children: [
                HomeHeader(
                  onStreakTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StreakScreen())),
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
                          onLessonTap: (lesson) =>
                              _onLessonTap(lesson, pathState),
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
      ),
    );
  }

  // Lessons and free practice are locked while the pet has no hearts left: the
  // hospital gate takes over, and only a paid discharge lets the tap through.
  Future<bool> _checkHospital() async {
    if (!context.read<GameCubit>().state.inHospital) return true;
    return showHospitalScreen(context);
  }

  // Lessons and free practice need the network; blocks with an error when offline.
  bool _checkInternet() {
    if (context.read<ConnectivityCubit>().state.isOnline) return true;
    Haptics.impact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.errorNoInternet)),
    );
    return false;
  }

  Future<void> _onLessonTap(Lesson lesson, PathState pathState) async {
    if (!await _checkHospital() || !mounted) return;
    if (!_checkInternet()) return;
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
      final resumeChoice = await showResumeLessonSheet(context);
      if (resumeChoice == null || !mounted) return;
      if (resumeChoice == 'resume') {
        _startCall(CallScreenArgs(lesson: lesson, resumeSession: saved));
        return;
      }
      // Restart: fall through to the lesson detail sheet instead of starting
      // the call straight away.
    }

    final choice = await showLessonStartSheet(context, lesson);
    if (choice == null || !mounted) return;
    // Discard the in-progress session only once a fresh start is confirmed,
    // so dismissing the detail sheet keeps the saved progress.
    if (saved != null) {
      await repo.deleteSession(lesson.id);
      if (!mounted) return;
    }
    _startCall(CallScreenArgs(
      lesson: lesson,
      startAtPractice: choice == 'practice',
    ));
  }

  Future<void> _startFreeConversation() async {
    if (!await _checkHospital() || !mounted) return;
    if (!_checkInternet()) return;
    _startCall(const CallScreenArgs(lesson: null));
  }

  void _startCall(CallScreenArgs args) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CallScreen(args: args)),
    );
  }
}
