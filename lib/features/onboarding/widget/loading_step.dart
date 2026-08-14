import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// "Making your plan" page: animated progress with rotating status lines,
/// auto-advances when the fake computation completes.
class LoadingStep extends StatefulWidget {
  final VoidCallback onDone;

  const LoadingStep({super.key, required this.onDone});

  @override
  State<LoadingStep> createState() => _LoadingStepState();
}

class _LoadingStepState extends State<LoadingStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_finished) {
          _finished = true;
          // Small pause on 100% before advancing.
          Timer(const Duration(milliseconds: 400), widget.onDone);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = [
      l10n.onboardingLoadingStep1,
      l10n.onboardingLoadingStep2,
      l10n.onboardingLoadingStep3,
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final value = _controller.value;
          final stepIndex =
              (value * steps.length).clamp(0, steps.length - 1).floor();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/game/pet_rest_animation.gif',
                  width: 130.w),
              SizedBox(height: 32.h),
              Text('${(value * 100).round()}%',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 40.sp)),
              SizedBox(height: 16.h),
              Text(l10n.onboardingLoadingTitle,
                  style: AppTextStyles.pageTitle, textAlign: TextAlign.center),
              SizedBox(height: 24.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10.h,
                  backgroundColor: AppColors.divider,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              SizedBox(height: 16.h),
              Text(steps[stepIndex], style: AppTextStyles.bodyGrey),
            ],
          );
        },
      ),
    );
  }
}
