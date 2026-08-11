import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks whether the shop modal is open so the home header can reactively
/// swap its streak pill for the live coin balance (ported from Elevate).
class ShopCubit extends Cubit<bool> {
  ShopCubit() : super(false);

  /// Marks the shop modal as open.
  void open() {
    debugPrint('[ShopCubit] shop opened');
    emit(true);
  }

  /// Marks the shop modal as dismissed.
  void dismiss() {
    debugPrint('[ShopCubit] shop closed');
    emit(false);
  }
}
