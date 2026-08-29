import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';

/// Subscription gate around the main app: shows a spinner until the user type
/// and Superwall status are known, then either the app or the app under a
/// locked overlay that re-fires the paywall on every tap.
/// Promo-code tiers (admin / ugc / apple) are never gated.
class AppGateWrapper extends StatelessWidget {
  const AppGateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, sub) {
        if (!sub.isLoaded) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (sub.hasAccess) return const AppShell();
        return Stack(
          children: [
            const AppShell(),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    context.read<SubscriptionCubit>().registerAppStart(),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}
