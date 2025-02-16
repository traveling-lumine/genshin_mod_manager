import 'dart:io';
import '../../../filesystem/l1/impl/fsops.dart';
import '../../../filesystem/l1/impl/path_op_string.dart';
import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import '../entity/app_config.dart';
import '../entity/entries.dart';
import '../entity/preset.dart';
import 'change_preset.dart';

AppConfig? addGlobalPresetUseCase({
  required final AppConfigFacade appConfigFacade,
  required final String name,
  required final AppConfigPersistentRepo appConfigRepo,
  final bool force = false,
}) {
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
      for (final categoryDir in getUnderSync<Directory>(rootPath))
        categoryDir.pBasename: PresetList(
          mods: getUnderSync<Directory>(categoryDir)
              .map((final e) => e.pBasename)
              .where((final e) => e.pIsEnabled)
              .toList(),
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
