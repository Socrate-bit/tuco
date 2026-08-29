import 'package:equatable/equatable.dart';

/// Whether the Superwall subscription grants access to the app.
enum SubscriptionGateStatus { unknown, active, inactive }

/// Account tier stored as `user_type` on the user document. Granted by a promo
/// code; `normal` is everyone else.
enum UserType { admin, ugc, apple, normal }

UserType userTypeFromString(String? value) => switch (value) {
      'admin' => UserType.admin,
      'ugc' => UserType.ugc,
      'apple' => UserType.apple,
      _ => UserType.normal,
    };

/// Lifecycle of a promo code redemption from the settings dialog.
enum PromoRedeemStatus { idle, submitting, success, invalid, exhausted, error }

class SubscriptionState extends Equatable {
  final SubscriptionGateStatus status;
  final bool isConfigured; // false when no Superwall key → app stays open
  final UserType userType;
  final bool isUserTypeLoaded;
  final PromoRedeemStatus redeemStatus;

  const SubscriptionState({
    this.status = SubscriptionGateStatus.unknown,
    this.isConfigured = false,
    this.userType = UserType.normal,
    this.isUserTypeLoaded = false,
    this.redeemStatus = PromoRedeemStatus.idle,
  });

  /// Admin, UGC and Apple reviewers never see the paywall.
  bool get skipsPaywall =>
      userType == UserType.admin ||
      userType == UserType.ugc ||
      userType == UserType.apple;

  /// Access is granted to promo-code tiers, to subscribers, or when Superwall
  /// isn't configured.
  bool get hasAccess =>
      skipsPaywall ||
      !isConfigured ||
      status == SubscriptionGateStatus.active;

  /// The gate can decide once the user type is known and Superwall reported.
  bool get isLoaded =>
      isUserTypeLoaded &&
      (!isConfigured || status != SubscriptionGateStatus.unknown);

  SubscriptionState copyWith({
    SubscriptionGateStatus? status,
    bool? isConfigured,
    UserType? userType,
    bool? isUserTypeLoaded,
    PromoRedeemStatus? redeemStatus,
  }) =>
      SubscriptionState(
        status: status ?? this.status,
        isConfigured: isConfigured ?? this.isConfigured,
        userType: userType ?? this.userType,
        isUserTypeLoaded: isUserTypeLoaded ?? this.isUserTypeLoaded,
        redeemStatus: redeemStatus ?? this.redeemStatus,
      );

  @override
  List<Object?> get props =>
      [status, isConfigured, userType, isUserTypeLoaded, redeemStatus];
}
