import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../service/haptics.dart';
import '../theme/app_theme.dart';

/// Shared circular mic button used by the lesson call bar and the record sheet.
///
/// The user can only *start* a take: tapping while idle fires [onStart]. While
/// recording it pulses red and ignores taps (recording auto-stops on silence);
/// while assessing it shows a spinner.
class RecordButton extends StatefulWidget {
  final bool recording;
  final bool assessing;
  final VoidCallback onStart;
  final double size;

  const RecordButton({
    super.key,
    required this.recording,
    required this.assessing,
    required this.onStart,
    this.size = 92,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    lowerBound: 0.9,
    upperBound: 1.0,
  );

  @override
  void initState() {
    super.initState();
    if (widget.recording) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(RecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recording && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.recording && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.recording || widget.assessing;
    final size = widget.size.r;
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: active ? AppColors.lessonRed : AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: active ? const Color(0xFFC53F27) : AppColors.primaryDark,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Center(
        child: widget.assessing
            ? SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Icon(
                widget.recording ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: size * 0.48,
              ),
      ),
    );

    return GestureDetector(
      onTap: active
          ? null
          : () {
              Haptics.impact();
              widget.onStart();
            },
      child: widget.recording
          ? ScaleTransition(scale: _pulse, child: button)
          : button,
    );
  }
}
