import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../service/haptics.dart';
import '../theme/app_theme.dart';

/// Shared circular mic button used by the lesson call bar and the record sheet.
///
/// Manual push-to-talk: tapping toggles recording via [onTap] (mic when idle,
/// stop when recording). While assessing it shows a spinner and ignores taps.
class RecordButton extends StatelessWidget {
  final bool recording;
  final bool assessing;
  final VoidCallback onTap;
  final double size;

  const RecordButton({
    super.key,
    required this.recording,
    required this.assessing,
    required this.onTap,
    this.size = 92,
  });

  @override
  Widget build(BuildContext context) {
    final active = recording || assessing;
    final dim = size.r;
    return GestureDetector(
      onTap: assessing
          ? null
          : () {
              Haptics.impact();
              onTap();
            },
      child: Container(
        width: dim,
        height: dim,
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
          child: assessing
              ? SizedBox(
                  width: dim * 0.4,
                  height: dim * 0.4,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Icon(
                  recording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: dim * 0.48,
                ),
        ),
      ),
    );
  }
}
