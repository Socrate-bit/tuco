import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

import '../../../core/service/analytics_service.dart';
import '../service/superwall_service.dart';
import 'subscription_state.dart';

/// Owns the subscription gate: maps Superwall's subscription status to
/// [SubscriptionGateStatus] and registers paywall placements.
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final AnalyticsService _analytics;
  StreamSubscription<SubscriptionStatus>? _sub;

  SubscriptionCubit(this._analytics)
      : super(SubscriptionState(isConfigured: SuperwallService.isConfigured)) {
    if (state.isConfigured) _listen();
  }

  void _listen() {
    try {
      _sub = Superwall.shared.subscriptionStatus.listen((status) {
        final gate = switch (status) {
          SubscriptionStatusActive() => SubscriptionGateStatus.active,
          SubscriptionStatusInactive() => SubscriptionGateStatus.inactive,
          _ => SubscriptionGateStatus.unknown,
        };
        emit(state.copyWith(status: gate));
        debugPrint('[SubscriptionCubit] Subscription status: $gate');
      });
    } catch (e) {
      debugPrint('[SubscriptionCubit] listen error: $e');
    }
  }

  /// Identify the Superwall user with the Firebase uid.
  Future<void> identifyUser(String uid) async {
    if (!state.isConfigured) return;
    try {
      await Superwall.shared.identify(uid);
      debugPrint('[SubscriptionCubit] Superwall identified $uid');
    } catch (e) {
      debugPrint('[SubscriptionCubit] identifyUser error: $e');
    }
  }

  /// Shows the onboarding paywall. Resolves when the paywall is dismissed
  /// (or immediately when Superwall isn't configured).
  Future<void> registerOnboardingPaywall() =>
      _register('onboarding_paywall');

  /// Re-fires the app-start gate paywall (tap on the locked overlay).
  Future<void> registerAppStart() => _register('app_start');

  Future<void> _register(String placement) async {
    _analytics.track('paywall_placement', {'placement': placement});
    if (!state.isConfigured) return;
    try {
      await Superwall.shared.registerPlacement(placement);
    } catch (e) {
      debugPrint('[SubscriptionCubit] register($placement) error: $e');
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
