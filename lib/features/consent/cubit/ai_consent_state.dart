import 'package:equatable/equatable.dart';

/// Whether the user currently allows their data to be sent to the AI providers.
class AiConsentState extends Equatable {
  final bool granted;

  const AiConsentState({this.granted = false});

  @override
  List<Object?> get props => [granted];
}
