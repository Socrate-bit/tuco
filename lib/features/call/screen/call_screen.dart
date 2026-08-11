import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/model/models.dart';
import '../../../core/service/data_repository.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../curriculum/model/curriculum_models.dart';
import '../../feedback/cubit/feedback_cubit.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../progression/cubit/stats_cubit.dart';
import '../cubit/call_cubit.dart';
import '../widget/call_controls.dart';
import '../widget/chat_bubbles.dart';
import 'lesson_end_screen.dart';

/// Arguments to open a call: lesson (null = free conversation), optional
/// resume session, or direct start at the practice phase.
class CallScreenArgs {
  final Lesson? lesson;
  final SavedSession? resumeSession;
  final bool startAtPractice;

  const CallScreenArgs({
    required this.lesson,
    this.resumeSession,
    this.startAtPractice = false,
  });
}

/// Immersive "video call" with the robot tutor.
class CallScreen extends StatelessWidget {
  final CallScreenArgs args;

  const CallScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => CallCubit(
        repo: ctx.read<DataRepository>(),
        profile: ctx.read<ProfileCubit>().state,
        lesson: args.lesson,
        resumeSession: args.resumeSession,
        startAtPractice: args.startAtPractice,
      ),
      child: _CallView(lesson: args.lesson),
    );
  }
}

class _CallView extends StatefulWidget {
  final Lesson? lesson;

  const _CallView({required this.lesson});

  @override
  State<_CallView> createState() => _CallViewState();
}

class _CallViewState extends State<_CallView> {
  final _scrollCtrl = ScrollController();
  final _textCtrl = TextEditingController();
  bool _showScrollDown = false;
  late final bool _hadLessonToday;

  @override
  void initState() {
    super.initState();
    // Captured now to decide whether to show the streak-win screen after.
    final stats = context.read<StatsCubit>().state;
    _hadLessonToday = stats.practiceDays
        .where((d) => d.date == DataRepository.dayKey(DateTime.now()))
        .any((d) => d.lessonsCompleted > 0);
    _scrollCtrl.addListener(() {
      final nearBottom = _scrollCtrl.position.extentAfter < 120;
      if (_showScrollDown == nearBottom) {
        setState(() => _showScrollDown = !nearBottom);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallCubit, CallState>(
      listener: (context, state) {
        // Auto-scroll on new messages.
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        if (state.finished && widget.lesson != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => LessonEndScreen(
              lesson: widget.lesson!,
              durationSeconds: state.elapsedSeconds,
              newWordsCount: widget.lesson!.vocab.length,
              showStreakWin: !_hadLessonToday,
            ),
          ));
        }
      },
      builder: (context, state) {
        final cubit = context.read<CallCubit>();
        return Scaffold(
          backgroundColor: AppColors.card,
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              _CallHeader(
                lesson: widget.lesson,
                phase: state.phase,
                speedLabel: state.ttsSpeedLabel,
                onClose: () => _confirmQuit(context),
                onSpeedTap: () => cubit.toggleTtsSpeed(),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ListView.separated(
                      controller: _scrollCtrl,
                      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
                      itemCount:
                          state.messages.length + (state.listening ? 1 : 0),
                      separatorBuilder: (_, _) => SizedBox(height: 14.h),
                      itemBuilder: (context, i) {
                        // Pending partial transcript bubble while listening.
                        if (i == state.messages.length) {
                          return UserBubble(
                            message: ChatMessage(
                                role: MessageRole.user,
                                text: state.partialTranscript.isEmpty
                                    ? '…'
                                    : state.partialTranscript),
                            onFeedbackTap: () {},
                            pending: true,
                          );
                        }
                        final msg = state.messages[i];
                        if (msg.banner != null) {
                          return PhaseBanner(banner: msg.banner!);
                        }
                        return switch (msg.role) {
                          MessageRole.ai => AiBubble(
                              message: msg,
                              translating: state.translatingIndex == i,
                              onTranslate: () => cubit.translateMessage(i),
                              onPlay: () => cubit.replayMessage(i),
                            ),
                          MessageRole.user => UserBubble(
                              message: msg,
                              onFeedbackTap: () =>
                                  _showFeedbackSheet(context, msg.text),
                            ),
                          MessageRole.inspiration =>
                            InspirationBubble(message: msg),
                        };
                      },
                    ),
                    if (state.aiThinking)
                      Positioned(
                        left: 24.w,
                        bottom: 12.h,
                        child: SizedBox(
                          width: 26.r,
                          height: 26.r,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2.5, color: AppColors.primary),
                        ),
                      ),
                    if (_showScrollDown)
                      Positioned(
                        right: 20.w,
                        bottom: 16.h,
                        child: GestureDetector(
                          onTap: () {
                            Haptics.tap();
                            _scrollToBottom();
                          },
                          child: Container(
                            width: 54.r,
                            height: 54.r,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.divider, width: 1.5),
                            ),
                            child: Icon(Icons.arrow_downward_rounded,
                                color: AppColors.primary, size: 26.r),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: state.typingMode
                    ? TypeInputBar(
                        controller: _textCtrl,
                        onSubmit: (text) {
                          _textCtrl.clear();
                          cubit.sendUserMessage(text);
                        },
                        onMic: () {
                          cubit.setTypingMode(false);
                          cubit.toggleListening();
                        },
                      )
                    : CallControls(
                        listening: state.listening,
                        onType: () => cubit.setTypingMode(true),
                        onMic: cubit.toggleListening,
                        onInspiration: cubit.requestInspiration,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Quit confirmation dialog (🤔 "Êtes-vous sûr(e) ?").
  Future<void> _confirmQuit(BuildContext context) async {
    Haptics.tap();
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<CallCubit>();
    final quit = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Padding(
          padding: EdgeInsets.all(28.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🤔', style: TextStyle(fontSize: 64.sp)),
              SizedBox(height: 20.h),
              Text(l10n.quitCallTitle,
                  textAlign: TextAlign.center, style: AppTextStyles.modalTitle),
              SizedBox(height: 16.h),
              Text(l10n.quitCallBody,
                  textAlign: TextAlign.center, style: AppTextStyles.bodyGrey),
              SizedBox(height: 26.h),
              PrimaryButton(
                label: l10n.resumeCall,
                onPressed: () => Navigator.pop(ctx, false),
              ),
              SizedBox(height: 10.h),
              TextLinkButton(
                label: l10n.quitCall,
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );
    if (quit == true && mounted) {
      await cubit.quitCall();
      if (mounted) Navigator.of(this.context).pop();
    }
  }

  /// Feedback sheet for one user sentence (grammar corrections if any).
  void _showFeedbackSheet(BuildContext context, String text) {
    Haptics.tap();
    final l10n = AppLocalizations.of(context)!;
    final items = context
        .read<FeedbackCubit>()
        .state
        .items
        .where((f) => f.originalText == text)
        .toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Center(
                  child: Text(l10n.noErrorsHere,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyGrey),
                ),
              )
            else
              for (final item in items) ...[
                for (final c in item.corrections) ...[
                  Row(
                    children: [
                      Text('• ', style: AppTextStyles.body),
                      Text(c.wrong,
                          style: AppTextStyles.body.copyWith(
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.scoreRed)),
                      Text('  →  ', style: AppTextStyles.body),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.scoreGreenBg,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(c.right,
                            style: AppTextStyles.body
                                .copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                  if (c.explanation.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(c.explanation, style: AppTextStyles.bodyGrey),
                  ],
                  SizedBox(height: 16.h),
                ],
              ],
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

/// Dark header: robot image, close, TTS speed, phase stepper, expand.
class _CallHeader extends StatelessWidget {
  final Lesson? lesson;
  final CallPhase phase;
  final String speedLabel;
  final VoidCallback onClose;
  final VoidCallback onSpeedTap;

  const _CallHeader({
    required this.lesson,
    required this.phase,
    required this.speedLabel,
    required this.onClose,
    required this.onSpeedTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 270.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 1.0),
                radius: 1.5,
                colors: [Color(0xFF33507F), Color(0xFF2B3D5F)],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/robot_header.png',
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundOverlayButton(
                        onTap: onClose,
                        child: Icon(Icons.close_rounded,
                            color: Colors.white, size: 26.r),
                      ),
                      _RoundOverlayButton(
                        onTap: onSpeedTap,
                        child: Text(speedLabel,
                            style: AppTextStyles.button
                                .copyWith(fontSize: 16.sp)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Lesson/practice vertical stepper.
                      if (lesson != null)
                        _PhaseStepper(
                          practiceActive: phase == CallPhase.practice,
                          lessonLabel: l10n.stepLesson,
                          practiceLabel: l10n.stepPractice,
                        )
                      else
                        const SizedBox.shrink(),
                      const Spacer(),
                      Icon(Icons.open_in_full_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 26.r),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseStepper extends StatelessWidget {
  final bool practiceActive;
  final String lessonLabel;
  final String practiceLabel;

  const _PhaseStepper({
    required this.practiceActive,
    required this.lessonLabel,
    required this.practiceLabel,
  });

  @override
  Widget build(BuildContext context) {
    final inactive = Colors.white.withValues(alpha: 0.45);
    Widget step(String label, bool active) => Row(
          children: [
            Container(
              width: 14.r,
              height: 14.r,
              decoration: BoxDecoration(
                color: active ? Colors.white : inactive,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                fontSize: 19.sp,
                color: active ? Colors.white : inactive,
              ),
            ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        step(lessonLabel, !practiceActive),
        Padding(
          padding: EdgeInsets.only(left: 6.r),
          child: Container(width: 2.5, height: 26.h, color: inactive),
        ),
        step(practiceLabel, practiceActive),
      ],
    );
  }
}

class _RoundOverlayButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _RoundOverlayButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: Container(
        width: 52.r,
        height: 52.r,
        decoration: const BoxDecoration(
          color: AppColors.whiteTranslucent,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}
