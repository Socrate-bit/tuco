import 'package:equatable/equatable.dart';

/// Whether the Superwall subscription grants access to the app.
enum SubscriptionGateStatus { unknown, active, inactive }

class SubscriptionState extends Equatable {
  final SubscriptionGateStatus status;
  final bool isConfigured; // false when no Superwall key → app stays open

  const SubscriptionState({
    this.status = SubscriptionGateStatus.unknown,
    this.isConfigured = false,
  });

  /// Access is granted when subscribed, or when Superwall isn't configured.
  bool get hasAccess =>
      !isConfigured || status == SubscriptionGateStatus.active;

  bool get isLoaded =>
      !isConfigured || status != SubscriptionGateStatus.unknown;

  SubscriptionState copyWith(
          {SubscriptionGateStatus? status, bool? isConfigured}) =>
      SubscriptionState(
        status: status ?? this.status,
        isConfigured: isConfigured ?? this.isConfigured,
      );

  @override
  List<Object?> get props => [status, isConfigured];
}
