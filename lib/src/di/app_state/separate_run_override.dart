import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../backend/storage/domain/usecase/separate_run.dart';
import '../storage.dart';
import 'current_target_game.dart';

part 'separate_run_override.g.dart';

@riverpod
class SeparateRunOverride extends _$SeparateRunOverride {
  @override
  bool? build() {
    final repository = ref.watch(persistentStorageProvider);
    final currentGame = ref.watch(targetGameProvider);
    return initializeSeparateRunOverrideUseCase(repository, currentGame);
  }

  void setValue(final bool? value) {
    final repository = ref.read(persistentStorageProvider);
    final currentGame = ref.read(targetGameProvider);
    setSeparateRunOverrideUseCase(repository, currentGame, value);
    state = value;
  }
}
