import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/model/models.dart';
import '../../../core/service/data_repository.dart';

/// Holds the user profile and applies optimistic updates on edits.
class ProfileCubit extends Cubit<UserProfile> {
  final DataRepository _repo;
  StreamSubscription? _sub;

  ProfileCubit(this._repo) : super(const UserProfile()) {
    _sub = _repo.profileStream().listen(
      emit,
      onError: (e) => debugPrint('[ProfileCubit] stream error: $e'),
    );
  }

  /// Optimistically apply an updated profile and persist it.
  Future<void> update(UserProfile updated) async {
    emit(updated);
    try {
      await _repo.saveProfile(updated);
    } catch (e) {
      debugPrint('[ProfileCubit] update error: $e');
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
