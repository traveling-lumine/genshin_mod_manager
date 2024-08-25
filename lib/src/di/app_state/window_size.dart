import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../backend/storage/domain/usecase/window_size.dart';
import '../storage.dart';

part 'window_size.g.dart';

@riverpod
class WindowSize extends _$WindowSize {
  @override
  Size? build() {
    final watch = ref.watch(sharedPreferenceStorageProvider);
    return initializeWindowSizeUseCase(watch);
  }

  void setValue(final Size value) {
    final read = ref.read(sharedPreferenceStorageProvider);
    setWindowSizeUseCase(read, value);
    state = value;
  }
}
