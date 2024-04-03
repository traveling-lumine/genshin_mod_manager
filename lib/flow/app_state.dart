import 'package:genshin_mod_manager/data/repo/app_state_storage.dart';
import 'package:genshin_mod_manager/data/repo/sharedpreference_storage.dart';
import 'package:genshin_mod_manager/domain/entity/app_state.dart';
import 'package:genshin_mod_manager/domain/entity/preset.dart';
import 'package:genshin_mod_manager/domain/repo/app_state_storage.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';
import 'package:genshin_mod_manager/domain/usecase/app_state/change.dart';
import 'package:genshin_mod_manager/domain/usecase/app_state/initialization.dart';
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

/// The storage for the app state.
@riverpod
AppStateStorage appStateStorage(final AppStateStorageRef ref) {
  final persistentStorage = ref.watch(sharedPreferenceStorageProvider);
  return AppStateStorageImpl(persistentStorage: persistentStorage);
}

/// The notifier for the app state.
@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() {
    final storage = ref.watch(appStateStorageProvider);
    return callAppStateInitializationUseCase(storage);
  }

  /// Changes the mod root.
  void changeModRoot(final String path) {
    ref.read(appStateStorageProvider).setModRoot(path);
    state = callChangeModRootUseCase(state, path);
  }

  /// Changes the mod executable file.
  void changeModExecFile(final String path) {
    ref.read(appStateStorageProvider).setModExecFile(path);
    state = callChangeModExecFileUseCase(state, path);
  }

  /// Changes the launcher file.
  void changeLauncherFile(final String path) {
    ref.read(appStateStorageProvider).setLauncherFile(path);
    state = callChangeLauncherFileUseCase(state, path);
  }

  /// Changes the run together.
// ignore: avoid_positional_boolean_parameters
  void changeRunTogether(final bool value) {
    ref.read(appStateStorageProvider).setRunTogether(value);
    state = callChangeRunTogetherUseCase(state, value);
  }

  /// Changes the move on drag.
// ignore: avoid_positional_boolean_parameters
  void changeMoveOnDrag(final bool value) {
    ref.read(appStateStorageProvider).setMoveOnDrag(value);
    state = callChangeMoveOnDragUseCase(state, value);
  }

  /// Changes the show folder icon.
// ignore: avoid_positional_boolean_parameters
  void changeShowFolderIcon(final bool value) {
    ref.read(appStateStorageProvider).setShowFolderIcon(value);
    state = callChangeShowFolderIconUseCase(state, value);
  }

  /// Changes the show enabled mods first.
// ignore: avoid_positional_boolean_parameters
  void changeShowEnabledModsFirst(final bool value) {
    ref.read(appStateStorageProvider).setShowEnabledModsFirst(value);
    state = callChangeShowEnabledModsFirstUseCase(state, value);
  }

  /// Changes the preset data.
  void changePresetData(final PresetData data) {
    ref.read(appStateStorageProvider).setPresetData(data);
    state = callChangePresetDataUseCase(state, data);
  }
}
