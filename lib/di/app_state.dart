import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entity/game_config.dart';
import '../domain/entity/preset.dart';
import '../domain/entity/setting_data.dart';
import '../domain/usecase/app_state/card_color.dart';
import '../domain/usecase/app_state/dark_mode.dart';
import '../domain/usecase/app_state/enabled_first.dart';
import '../domain/usecase/app_state/folder_icon.dart';
import '../domain/usecase/app_state/game_config.dart';
import '../domain/usecase/app_state/move_on_drag.dart';
import '../domain/usecase/app_state/paimon_icon.dart';
import '../domain/usecase/app_state/run_together.dart';
import '../domain/usecase/app_state/separate_run.dart';
import 'storage.dart';

part 'app_state.g.dart';

@riverpod
class GamesList extends _$GamesList {
  @override
  List<String> build() {
    final storage = ref.watch(sharedPreferenceStorageProvider);
    final gamesList = storage.getList('games') ?? [];
    return gamesList;
  }

  void addGame(final String game) {
    final storage = ref.read(sharedPreferenceStorageProvider);
    if (state.contains(game)) {
      return;
    }
    final newGamesList = [...state, game];
    storage.setList('games', newGamesList);
    state = newGamesList;
  }

  void removeGame(final String game) {
    final storage = ref.read(sharedPreferenceStorageProvider);
    if (!state.contains(game)) {
      return;
    }
    final newGamesList = state.where((final e) => e != game).toList();
    storage.setList('games', newGamesList);
    state = newGamesList;
  }
}

/// The target game.
@riverpod
class TargetGame extends _$TargetGame {
  @override
  String build() {
    final storage = ref.watch(sharedPreferenceStorageProvider);
    final gamesList = ref.watch(gamesListProvider);
    final lastGame = storage.getString('lastGame');
    if (gamesList.contains(lastGame)) {
      return lastGame!;
    } else {
      final first = gamesList.first;
      storage.setString('lastGame', first);
      return first;
    }
  }

  /// Sets the value.
  void setValue(final String value) {
    final read = ref.read(sharedPreferenceStorageProvider);
    final gamesList = ref.read(gamesListProvider);
    if (!gamesList.contains(value)) {
      return;
    }
    read.setString('lastGame', value);
    state = value;
  }
}

/// The notifier for the app state.
@riverpod
class GameConfigNotifier extends _$GameConfigNotifier {
  @override
  GameConfig build() {
    final storage2 = ref.watch(sharedPreferenceStorageProvider);
    final targetGame = ref.watch(targetGameProvider);
    final gameConfig = initializeGameConfigUseCase(storage2, targetGame);
    return gameConfig;
  }

  /// Changes the mod root.
  void changeModRoot(final String path) {
    final read = ref.read(sharedPreferenceStorageProvider);
    final targetGame = ref.read(targetGameProvider);
    setModRootUseCase(read, targetGame, path);
    state = state.copyWith(modRoot: path);
  }

  /// Changes the mod executable file.
  void changeModExecFile(final String path) {
    final read = ref.read(sharedPreferenceStorageProvider);
    final targetGame = ref.read(targetGameProvider);
    setModExecFileUseCase(read, targetGame, path);
    state = state.copyWith(modExecFile: path);
  }

  /// Changes the launcher file.
  void changeLauncherFile(final String path) {
    final read = ref.read(sharedPreferenceStorageProvider);
    final targetGame = ref.read(targetGameProvider);
    setLauncherFileUseCase(read, targetGame, path);
    state = state.copyWith(launcherFile: path);
  }

  /// Changes the preset data.
  void changePresetData(final PresetData data) {
    final read = ref.read(sharedPreferenceStorageProvider);
    final targetGame = ref.read(targetGameProvider);
    setPresetDataUseCase(data, read, targetGame);
    state = state.copyWith(presetData: data);
  }
}

/// The notifier for boolean value.
abstract interface class ValueSettable<T> implements AutoDisposeNotifier<T> {
  /// Sets the value.
  void setValue(final T value);
}

/// The notifier for the dark mode.
@riverpod
class DarkMode extends _$DarkMode implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(sharedPreferenceStorageProvider);
    return initializeDarkModeUseCase(watch);
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(sharedPreferenceStorageProvider);
    setDarkModeUseCase(read, value);
    state = value;
  }
}

/// The notifier for the enabled first.
@riverpod
class EnabledFirst extends _$EnabledFirst implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(sharedPreferenceStorageProvider);
    final showEnabledModsFirst = initializeEnabledFirstUseCase(watch);
    return showEnabledModsFirst;
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(sharedPreferenceStorageProvider);
    setEnabledFirstUseCase(read, value);
    state = value;
  }
}

/// The notifier for the folder icon.
@riverpod
class FolderIcon extends _$FolderIcon implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(sharedPreferenceStorageProvider);
    return initializeFolderIconUseCase(watch);
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(sharedPreferenceStorageProvider);
    setFolderIconUseCase(read, value);
    state = value;
  }
}

/// The notifier for the move on drag.
@riverpod
class MoveOnDrag extends _$MoveOnDrag implements ValueSettable<DragImportType> {
  @override
  DragImportType build() {
    final watch = ref.watch(sharedPreferenceStorageProvider);
    return initializeMoveOnDragUseCase(watch)
        ? DragImportType.move
        : DragImportType.copy;
  }

  @override
  void setValue(final DragImportType value) {
    final read = ref.read(sharedPreferenceStorageProvider);
    final boolValue = value == DragImportType.move;
    setMoveOnDragUseCase(read, boolValue);
    state = value;
  }
}

/// The notifier for the run together.
@riverpod
class RunTogether extends _$RunTogether implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(sharedPreferenceStorageProvider);
    return initializeRunTogetherUseCase(watch);
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(sharedPreferenceStorageProvider);
    setRunTogetherUseCase(read, value);
    state = value;
  }
}

/// The notifier for the folder icon.
@riverpod
class PaimonIcon extends _$PaimonIcon implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(sharedPreferenceStorageProvider);
    return initializePaimonIconUseCase(watch);
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(sharedPreferenceStorageProvider);
    setPaimonIconUseCase(read, value);
    state = value;
  }
}

@riverpod
class CardColor extends _$CardColor {
  @override
  Color build({required final bool isBright, required final bool isEnabled}) {
    final repository = ref.watch(sharedPreferenceStorageProvider);
    final color = initializeCardColorUseCase(
      repository,
      isBright: isBright,
      isEnabled: isEnabled,
    );
    return color;
  }

  void setColor(final Color color) {
    final repository = ref.read(sharedPreferenceStorageProvider);
    setCardColorUseCase(
      repository,
      color,
      isBright: isBright,
      isEnabled: isEnabled,
    );
    state = color;
  }
}

@riverpod
class SeparateRunOverride extends _$SeparateRunOverride {
  @override
  bool? build() {
    final repository = ref.watch(sharedPreferenceStorageProvider);
    final currentGame = ref.watch(targetGameProvider);
    return initializeSeparateRunOverrideUseCase(repository, currentGame);
  }

  void setValue(final bool? value) {
    final repository = ref.read(sharedPreferenceStorageProvider);
    final currentGame = ref.read(targetGameProvider);
    setSeparateRunOverrideUseCase(repository, currentGame, value);
    state = value;
  }
}
