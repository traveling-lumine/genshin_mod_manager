import '../../../filesystem/l0/api/filesystem.dart';
import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import '../entity/app_config.dart';
import '../entity/entries.dart';
import '../entity/preset.dart';
import 'change_preset.dart';

Future<AppConfig?> addGlobalPresetUseCase({
  required final AppConfigFacade appConfigFacade,
  required final Filesystem fs,
  required final String name,
  required final AppConfigPersistentRepo appConfigRepo,
  final bool force = false,
}) async {
  final currentGameConfig =
      appConfigFacade.obtainValue(games).currentGameConfig;
  final rootPath = currentGameConfig.modRoot;
  if (rootPath == null) {
    return null;
  }
  if (currentGameConfig.presetData.global.containsKey(name) && !force) {
    return null;
  }
  final bpd = PresetListMap(
    bundledPresets: {
      for (final categoryDir in await fs.getSubDirNames(path: rootPath))
        categoryDir: PresetList(
          mods: await fs.getSubDirNames(path: categoryDir, onlyEnabled: true),
        ),
    },
  );
  final presetData = currentGameConfig.presetData;
  final newGlobalPresets = {...presetData.global}..[name] = bpd;
  final res = presetData.copyWith(global: newGlobalPresets);
  final newState = changePresetUseCase(
    appConfigFacade: appConfigFacade,
    value: res,
    appConfigPersistentRepo: appConfigRepo,
  );
  return newState;
}
