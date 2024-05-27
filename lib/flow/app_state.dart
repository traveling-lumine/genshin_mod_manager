import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/repo/app_state_storage.dart';
import 'package:genshin_mod_manager/data/repo/sharedpreference_storage.dart';
import 'package:genshin_mod_manager/domain/entity/game_config.dart';
import 'package:genshin_mod_manager/domain/entity/game_enum.dart';
import 'package:genshin_mod_manager/domain/entity/preset.dart';
import 'package:genshin_mod_manager/domain/repo/app_state_storage.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_state.g.dart';

/// The shared preference.
@riverpod
Future<SharedPreferences> sharedPreference(
  final SharedPreferenceRef ref,
) =>
    SharedPreferences.getInstance().timeout(const Duration(seconds: 5));

/// The storage for the shared preference.
@riverpod
PersistentStorage sharedPreferenceStorage(
  final SharedPreferenceStorageRef ref,
) {
  final sharedPreferences =
      ref.watch(sharedPreferenceProvider).unwrapPrevious().valueOrNull;
  if (sharedPreferences == null) {
    return NullSharedPreferenceStorage();
  }
  return SharedPreferenceStorage(sharedPreferences);
}

/// The target game.
@riverpod
class TargetGame extends _$TargetGame {
  static const _key = 'targetGame';

  @override
  TargetGames build() {
    final storage = ref.watch(sharedPreferenceStorageProvider);
    final savedValue = storage.getString(_key);
    return TargetGames.values.firstWhere(
      (final element) => element.prefix == savedValue,
      orElse: () => TargetGames.gshin,
    );
  }

  /// Sets the value.
  void setValue(final TargetGames value) {
    ref.read(sharedPreferenceStorageProvider).setString(_key, value.prefix);
    state = value;
  }
}

/// The storage for the app state.
@riverpod
AppStateStorage appStateStorage(final AppStateStorageRef ref) {
  final persistentStorage = ref.watch(sharedPreferenceStorageProvider);
  final game = ref.watch(targetGameProvider);
  return AppStateStorageImpl(
    persistentStorage: persistentStorage,
    prefix: game.prefix,
  );
}

/// The notifier for the app state.
@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  GameConfig build() {
    final storage = ref.watch(appStateStorageProvider);
    const dotString = '.';
    final tDirRaw = storage.getTargetDir();
    final targetDir = tDirRaw ?? dotString;

    var modRoot = storage.getModRoot();
    if (modRoot == null && targetDir != dotString) {
      modRoot = targetDir.pJoin('Mods');
    }

    var modExecFile = storage.getModExecFile();
    if (modExecFile == null && targetDir != dotString) {
      modExecFile = targetDir.pJoin('3DMigoto Loader.exe');
    }

    if (targetDir != dotString) {
      storage.setTargetDir(dotString);
    }
    return GameConfig(
      modRoot: modRoot,
      modExecFile: modExecFile,
      presetData: storage.getPresetData(),
      launcherFile: storage.getLauncherFile(),
    );
  }

  /// Changes the mod root.
  void changeModRoot(final String path) {
    ref.read(appStateStorageProvider).setModRoot(path);
    state = state.copyWith(modRoot: path);
  }

  /// Changes the mod executable file.
  void changeModExecFile(final String path) {
    ref.read(appStateStorageProvider).setModExecFile(path);
    state = state.copyWith(modExecFile: path);
  }

  /// Changes the launcher file.
  void changeLauncherFile(final String path) {
    ref.read(appStateStorageProvider).setLauncherFile(path);
    state = state.copyWith(launcherFile: path);
  }

  /// Changes the preset data.
  void changePresetData(final PresetData data) {
    ref.read(appStateStorageProvider).setPresetData(data);
    state = state.copyWith(presetData: data);
  }
}

/// The notifier for boolean value.
mixin ValueSettable on AutoDisposeNotifier<bool> {
  /// Sets the value.
  // ignore: avoid_positional_boolean_parameters
  void setValue(final bool value);
}

/// The notifier for the dark mode.
@riverpod
class DarkMode extends _$DarkMode with ValueSettable {
  @override
  bool build() => ref.watch(appStateStorageProvider).getDarkMode();

  @override
  void setValue(final bool value) {
    ref.read(appStateStorageProvider).setDarkMode(value);
    state = value;
  }
}

/// The notifier for the enabled first.
@riverpod
class EnabledFirst extends _$EnabledFirst with ValueSettable {
  @override
  bool build() => ref.watch(appStateStorageProvider).getShowEnabledModsFirst();

  @override
  void setValue(final bool value) {
    ref.read(appStateStorageProvider).setShowEnabledModsFirst(value);
    state = value;
  }
}

/// The notifier for the folder icon.
@riverpod
class FolderIcon extends _$FolderIcon with ValueSettable {
  @override
  bool build() => ref.watch(appStateStorageProvider).getShowFolderIcon();

  @override
  void setValue(final bool value) {
    ref.read(appStateStorageProvider).setShowFolderIcon(value);
    state = value;
  }
}

/// The notifier for the move on drag.
@riverpod
class MoveOnDrag extends _$MoveOnDrag with ValueSettable {
  @override
  bool build() => ref.watch(appStateStorageProvider).getMoveOnDrag();

  @override
  void setValue(final bool value) {
    ref.read(appStateStorageProvider).setMoveOnDrag(value);
    state = value;
  }
}

/// The notifier for the run together.
@riverpod
class RunTogether extends _$RunTogether with ValueSettable {
  @override
  bool build() => ref.watch(appStateStorageProvider).getRunTogether();

  @override
  void setValue(final bool value) {
    ref.read(appStateStorageProvider).setRunTogether(value);
    state = value;
  }
}
