import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/di/storage.dart';
import '../storage/domain/usecase/window_size.dart';

part 'window_size.g.dart';

@riverpod
class WindowSize extends _$WindowSize {
  @override
  Size? build() {
    final watch = ref.watch(persistentStorageProvider).valueOrNull;
    return initializeWindowSizeUseCase(watch);
  }

  void setValue(final Size value) {
    final read = ref.read(persistentStorageProvider).valueOrNull;
    setWindowSizeUseCase(read, value);
    state = value;
  }
}
