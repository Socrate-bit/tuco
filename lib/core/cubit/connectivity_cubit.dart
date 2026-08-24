import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Connectivity state: whether the device currently has a network connection.
class ConnectivityState extends Equatable {
  final bool isOnline;

  const ConnectivityState({required this.isOnline});

  @override
  List<Object?> get props => [isOnline];
}

/// Watches device connectivity and emits online/offline changes.
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const ConnectivityState(isOnline: true)) {
    _init();
  }

  // Reads the initial status then listens for changes.
  Future<void> _init() async {
    try {
      _onChanged(await _connectivity.checkConnectivity());
      _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
      debugPrint('[ConnectivityCubit] Watching connectivity changes');
    } catch (e) {
      debugPrint('[ConnectivityCubit] Failed to watch connectivity: $e');
    }
  }

  void _onChanged(List<ConnectivityResult> results) {
    final isOnline = results.any((r) => r != ConnectivityResult.none);
    if (isOnline != state.isOnline) {
      debugPrint('[ConnectivityCubit] Online: $isOnline');
      emit(ConnectivityState(isOnline: isOnline));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
