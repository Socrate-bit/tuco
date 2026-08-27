import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widget/record_button.dart';

/// Bottom sheet holding just the shared [RecordButton], wired to an existing
/// practice cubit ([cubit]) so the screen behind it updates in place. The sheet
/// auto-closes once a started take has finished recording and scoring.
///
/// Generic over the cubit ([C]) and its state ([S]) so both the word-practice
/// and message-review cubits can reuse it.
Future<void> showRecordSheet<C extends StateStreamableSource<S>, S>(
  BuildContext context, {
  required C cubit,
  required bool Function(S state) recording,
  required bool Function(S state) assessing,
  required void Function(C cubit) onStart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider<C>.value(
      value: cubit,
      child: _RecordSheet<C, S>(
        recording: recording,
        assessing: assessing,
        onStart: onStart,
      ),
    ),
  );
}

class _RecordSheet<C extends StateStreamableSource<S>, S>
    extends StatefulWidget {
  final bool Function(S state) recording;
  final bool Function(S state) assessing;
  final void Function(C cubit) onStart;

  const _RecordSheet({
    required this.recording,
    required this.assessing,
    required this.onStart,
  });

  @override
  State<_RecordSheet<C, S>> createState() => _RecordSheetState<C, S>();
}

class _RecordSheetState<C extends StateStreamableSource<S>, S>
    extends State<_RecordSheet<C, S>> {
  // Becomes true once the user has kicked off a take, so we only auto-close
  // after a real recording completes (not on the initial idle state).
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<C, S>(
      listener: (context, state) {
        final rec = widget.recording(state);
        final busy = widget.assessing(state);
        if (rec) _started = true;
        if (_started && !rec && !busy && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
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
              children: [
                Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(height: 32.h),
                RecordButton(
                  recording: widget.recording(state),
                  assessing: widget.assessing(state),
                  onStart: () => widget.onStart(context.read<C>()),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
