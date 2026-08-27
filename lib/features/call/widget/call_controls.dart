import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/record_button.dart';

/// Bottom control bar: Type | big mic | Inspiration (Delete while listening).
class CallControls extends StatelessWidget {
  final bool listening;
  final bool assessing;
  final VoidCallback onType;
  final VoidCallback onMic;
  final VoidCallback onInspiration;
  final VoidCallback onClear; // wipe spoken transcript, keep recording
  final bool inspirationEnabled; // one hint per message round

  const CallControls({
    super.key,
    required this.listening,
    this.assessing = false,
    required this.onType,
    required this.onMic,
    required this.onInspiration,
    required this.onClear,
    this.inspirationEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SideControl(
            icon: Icons.keyboard_alt_rounded,
            label: l10n.typeButton,
            onTap: onType,
          ),
          // Big mic button — starts a take; auto-stops on silence.
          RecordButton(
            recording: listening,
            assessing: assessing,
            onStart: onMic,
          ),
          if (listening)
            _SideControl(
              icon: Icons.backspace_rounded,
              label: l10n.clearButton,
              onTap: onClear,
            )
          else
            _SideControl(
              icon: Icons.lightbulb_rounded,
              label: l10n.inspirationButton,
              onTap: onInspiration,
              enabled: inspirationEnabled,
            ),
        ],
      ),
    );
  }
}

class _SideControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _SideControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!enabled) return;
        Haptics.tap();
        onTap();
      },
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58.r,
              height: 58.r,
              decoration: const BoxDecoration(
                  color: AppColors.primaryLight, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 28.r),
            ),
            SizedBox(height: 6.h),
            Text(label,
                style: AppTextStyles.small
                    .copyWith(color: AppColors.primary, fontSize: 15.sp)),
          ],
        ),
      ),
    );
  }
}

/// Keyboard input row shown in typing mode ("Répondre ici" + mic circle).
class TypeInputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final VoidCallback onMic;

  const TypeInputBar({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: AppColors.card,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: AppColors.aiBubble,
                borderRadius: BorderRadius.circular(26.r),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: onSubmit,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: l10n.replyHere,
                  hintStyle:
                      AppTextStyles.body.copyWith(color: AppColors.textGrey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () {
              Haptics.tap();
              onMic();
            },
            child: Container(
              width: 52.r,
              height: 52.r,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: Icon(Icons.mic_rounded, color: Colors.white, size: 26.r),
            ),
          ),
        ],
      ),
    );
  }
}
