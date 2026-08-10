import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/model/models.dart';
import '../../../core/service/data_repository.dart';

/// All grammar & alternative feedback items.
class FeedbackState extends Equatable {
  final List<FeedbackItem> items;

  const FeedbackState({this.items = const []});

  List<FeedbackItem> get grammar =>
      items.where((i) => i.type == 'grammar').toList();

  List<FeedbackItem> get alternatives =>
      items.where((i) => i.type == 'alternative').toList();

  @override
  List<Object?> get props => [items];
}

/// Streams the feedback collection.
class FeedbackCubit extends Cubit<FeedbackState> {
  final DataRepository _repo;
  StreamSubscription? _sub;

  FeedbackCubit(this._repo) : super(const FeedbackState()) {
    _sub = _repo.feedbackStream().listen(
      (items) => emit(FeedbackState(items: items)),
      onError: (e) => debugPrint('[FeedbackCubit] stream error: $e'),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
