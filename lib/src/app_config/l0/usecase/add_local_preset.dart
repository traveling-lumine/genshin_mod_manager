import 'dart:io';

import '../../../filesystem/l0/entity/mod_category.dart';
import '../../../filesystem/l1/impl/fsops.dart';
import '../../../filesystem/l1/impl/path_op_string.dart';
import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import '../entity/app_config.dart';
import '../entity/entries.dart';
import '../entity/preset.dart';
import 'change_preset.dart';

AppConfig addLocalPresetUseCase({
  required final AppConfigFacade facade,
  required final ModCategory category,
  required final String name,
  required final AppConfigPersistentRepo appConfigRepo,
}) {
  final presetData = facade.obtainValue(games).currentGameConfig.presetData;
  final localPresets = presetData.local;
  final categoryPresets = localPresets[category.name];
  final Map<String, PresetList> modString;
  final presetTargetData = PresetList(
    mods: getUnderSync<Directory>(category.path)
        .where((final e) => e.pIsEnabled)
        .map((final e) => e.pBasename)
        .toList(),
  );
  if (categoryPresets != null) {
    modString = {...categoryPresets.bundledPresets}..[name] = presetTargetData;
  } else {
    modString = {name: presetTargetData};
  }
  final newCategoryPresets = PresetListMap(bundledPresets: modString);
  final newLocalPresets = {...localPresets}..[category.name] =
      newCategoryPresets;
  final res = presetData.copyWith(local: newLocalPresets);
  final newState = changePresetUseCase(
    appConfigFacade: facade,
    value: res,
    appConfigPersistentRepo: appConfigRepo,
  );
  return newState;
}
