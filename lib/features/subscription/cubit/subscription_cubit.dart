import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

import '../../../core/service/analytics_service.dart';
import '../service/promo_service.dart';
import '../service/superwall_service.dart';
import 'subscription_state.dart';

/// Owns the subscription gate: maps Superwall's subscription status to
/// [SubscriptionGateStatus], tracks the promo-code [UserType] read from the
/// user document, and registers paywall placements.
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final AnalyticsService _analytics;
  StreamSubscription<SubscriptionStatus>? _sub;
  StreamSubscription<User?>? _authSub;

  SubscriptionCubit(this._analytics)
      : super(SubscriptionState(isConfigured: SuperwallService.isConfigured)) {
    if (state.isConfigured) _listen();
    _listenAuth();
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

  /// Re-reads the user type whenever the signed-in user changes — the uid
  /// switches when an anonymous session is linked to (or replaced by) an
  /// account, and the promo tier lives on that account's document.
  void _listenAuth() {
    try {
      _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user == null) {
          emit(state.copyWith(
              userType: UserType.normal, isUserTypeLoaded: true));
          return;
        }
        identifyUser(user.uid);
        refreshUserType();
      });
    } catch (e) {
      debugPrint('[SubscriptionCubit] auth listen error: $e');
      // Without Firebase there is no user type to load — never block the gate.
      emit(state.copyWith(isUserTypeLoaded: true));
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

  /// Reads `user_type` from the user document (after sign-in, or after a promo
  /// code is redeemed).
  Future<void> refreshUserType() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(state.copyWith(isUserTypeLoaded: true));
      return;
    }
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final type = userTypeFromString(doc.data()?['user_type'] as String?);
      emit(state.copyWith(userType: type, isUserTypeLoaded: true));
      debugPrint('[SubscriptionCubit] User type: ${type.name}');
    } catch (e) {
      debugPrint('[SubscriptionCubit] refreshUserType error: $e');
      emit(state.copyWith(isUserTypeLoaded: true));
    }
  }

  /// Validates then redeems [code], granting the promo user type on success.
  Future<void> redeemPromoCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;
    emit(state.copyWith(redeemStatus: PromoRedeemStatus.submitting));
    _analytics.track('promo_redeem_attempt');
    try {
      final validType = await PromoService.validateCode(trimmed);
      if (validType == null) {
        emit(state.copyWith(redeemStatus: PromoRedeemStatus.invalid));
        _analytics.track('promo_redeem_failed', {'reason': 'invalid'});
        return;
      }
      if (validType == PromoService.exhausted) {
        emit(state.copyWith(redeemStatus: PromoRedeemStatus.exhausted));
        _analytics.track('promo_redeem_failed', {'reason': 'exhausted'});
        return;
      }
      final userType = await PromoService.redeemCode(trimmed);
      emit(state.copyWith(
        userType: userTypeFromString(userType),
        isUserTypeLoaded: true,
        redeemStatus: PromoRedeemStatus.success,
      ));
      _analytics.track('promo_redeem_success', {'user_type': userType});
      debugPrint('[SubscriptionCubit] Promo code applied → $userType');
    } catch (e) {
      debugPrint('[SubscriptionCubit] redeemPromoCode error: $e');
      emit(state.copyWith(redeemStatus: PromoRedeemStatus.error));
      _analytics.track('promo_redeem_failed', {'reason': 'error'});
    }
  }

  void clearRedeemStatus() =>
      emit(state.copyWith(redeemStatus: PromoRedeemStatus.idle));

  /// Shows the onboarding paywall. Resolves when the paywall is dismissed
  /// (or immediately when Superwall isn't configured).
  Future<void> registerOnboardingPaywall() =>
      _register('app_gate');

  /// Re-fires the app-start gate paywall (tap on the locked overlay).
  Future<void> registerAppStart() => _register('app_gate');

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
    _authSub?.cancel();
    return super.close();
  }
}
