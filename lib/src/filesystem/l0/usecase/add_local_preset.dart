import '../../../app_config/l0/api/app_config_facade.dart';
import '../../../app_config/l0/api/app_config_persistent_repo.dart';
import '../../../app_config/l0/entity/app_config.dart';
import '../../../app_config/l0/entity/entries.dart';
import '../../../app_config/l0/entity/preset.dart';
import '../../../app_config/l0/usecase/change_preset.dart';
import '../api/filesystem.dart';
import '../entity/mod_category.dart';

Future<AppConfig> addLocalPresetUseCase({
  required final AppConfigFacade facade,
  required final Filesystem fs,
  required final ModCategory category,
  required final String name,
  required final AppConfigPersistentRepo appConfigRepo,
}) async {
  final presetData = facade.obtainValue(games).currentGameConfig.presetData;
  final localPresets = presetData.local;
  final categoryPresets = localPresets[category.name];
  final Map<String, PresetList> modString;
  final presetTargetData = PresetList(
    mods: await fs.getSubDirNames(path: category.path, onlyEnabled: true),
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
