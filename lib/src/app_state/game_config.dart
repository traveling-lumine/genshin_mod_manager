import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/di/storage.dart';
import '../storage/domain/entity/game_config.dart';
import '../storage/domain/entity/preset.dart';
import '../storage/domain/usecase/game_config.dart';
import 'current_target_game.dart';

part 'game_config.g.dart';

@riverpod
class GameConfigNotifier extends _$GameConfigNotifier {
  @override
  GameConfig build() {
    final storage2 = ref.watch(persistentStorageProvider).requireValue;
    final targetGame = ref.watch(targetGameProvider);
    final gameConfig = initializeGameConfigUseCase(storage2, targetGame);
    return gameConfig;
  }

  /// Changes the mod root.
  void changeModRoot(final String path) {
    final read = ref.read(persistentStorageProvider).requireValue;
    final targetGame = ref.read(targetGameProvider);
    setModRootUseCase(read, targetGame, path);
    state = state.copyWith(modRoot: path);
  }

  /// Changes the mod executable file.
  void changeModExecFile(final String path) {
    final read = ref.read(persistentStorageProvider).requireValue;
    final targetGame = ref.read(targetGameProvider);
    setModExecFileUseCase(read, targetGame, path);
    state = state.copyWith(modExecFile: path);
  }

  /// Changes the launcher file.
  void changeLauncherFile(final String path) {
    final read = ref.read(persistentStorageProvider).requireValue;
    final targetGame = ref.read(targetGameProvider);
    setLauncherFileUseCase(read, targetGame, path);
    state = state.copyWith(launcherFile: path);
  }

  /// Changes the preset data.
  void changePresetData(final PresetData data) {
    final read = ref.read(persistentStorageProvider).requireValue;
    final targetGame = ref.read(targetGameProvider);
    setPresetDataUseCase(data, read, targetGame);
    state = state.copyWith(presetData: data);
  }
}
