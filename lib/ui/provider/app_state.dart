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

@riverpod
Future<SharedPreferences> sharedPreference(
  final SharedPreferenceRef ref,
) =>
    SharedPreferences.getInstance();

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

@riverpod
AppStateStorage appStateStorage(final AppStateStorageRef ref) {
  final persistentStorage = ref.watch(sharedPreferenceStorageProvider);
  return AppStateStorageImpl(persistentStorage: persistentStorage);
}

@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() {
    final storage = ref.watch(appStateStorageProvider);
    return callAppStateInitializationUseCase(storage);
  }

  AppState changeModRoot(final String path) {
    ref.read(appStateStorageProvider).setModRoot(path);
    final curState = state;
    return callChangeModRootUseCase(curState, path);
  }

  AppState changeModExecFile(final String path) {
    ref.read(appStateStorageProvider).setModExecFile(path);
    final curState = state;
    return callChangeModExecFileUseCase(curState, path);
  }

  AppState changeLauncherFile(final String path) {
    ref.read(appStateStorageProvider).setLauncherFile(path);
    final curState = state;
    return callChangeLauncherFileUseCase(curState, path);
  }

  AppState changeRunTogether(final bool value) {
    ref.read(appStateStorageProvider).setRunTogether(value);
    final curState = state;
    return callChangeRunTogetherUseCase(curState, value);
  }

  AppState changeMoveOnDrag(final bool value) {
    ref.read(appStateStorageProvider).setMoveOnDrag(value);
    final curState = state;
    return callChangeMoveOnDragUseCase(curState, value);
  }

  AppState changeShowFolderIcon(final bool value) {
    ref.read(appStateStorageProvider).setShowFolderIcon(value);
    final curState = state;
    return callChangeShowFolderIconUseCase(curState, value);
  }

  AppState changeShowEnabledModsFirst(final bool value) {
    ref.read(appStateStorageProvider).setShowEnabledModsFirst(value);
    final curState = state;
    return callChangeShowEnabledModsFirstUseCase(curState, value);
  }

  AppState changePresetData(final PresetData data) {
    ref.read(appStateStorageProvider).setPresetData(data);
    final curState = state;
    return callChangePresetDataUseCase(curState, data);
  }
}
