import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/usecase/separate_run.dart';
import 'current_target_game.dart';
import 'storage.dart';

part 'separate_run_override.g.dart';

@riverpod
class SeparateRunOverride extends _$SeparateRunOverride {
  @override
  bool? build() {
    final repository = ref.watch(persistentStorageProvider).valueOrNull;
    final currentGame = ref.watch(targetGameProvider);
    return initializeSeparateRunOverrideUseCase(repository, currentGame);
  }

  void setValue(final bool? value) {
    final repository = ref.read(persistentStorageProvider).valueOrNull;
    final currentGame = ref.read(targetGameProvider);
    setSeparateRunOverrideUseCase(repository, currentGame, value);
    state = value;
  }
}
