import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/usecase/run_together.dart';
import 'storage.dart';
import 'value_settable.dart';

part 'run_together.g.dart';

@riverpod
class RunTogether extends _$RunTogether implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(persistentStorageProvider).valueOrNull;
    return initializeRunTogetherUseCase(watch);
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(persistentStorageProvider).valueOrNull;
    setRunTogetherUseCase(read, value);
    state = value;
  }
}
