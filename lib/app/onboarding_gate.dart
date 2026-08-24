import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/onboarding/cubit/onboarding_cubit.dart';
import '../features/onboarding/cubit/onboarding_state.dart';
import '../features/onboarding/screen/onboarding_screen.dart';
import '../features/subscription/screen/app_gate_wrapper.dart';

/// Routes to the onboarding funnel until it completes, then to the
/// subscription-gated app.
class OnboardingGate extends StatelessWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (prev, curr) => prev.isComplete != curr.isComplete,
      builder: (context, state) => state.isComplete
          ? const AppGateWrapper()
          : const OnboardingScreen(),
    );
  }
}
