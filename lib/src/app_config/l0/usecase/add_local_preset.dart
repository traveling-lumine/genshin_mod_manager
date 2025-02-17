import '../../../filesystem/l0/api/filesystem.dart';
import '../../../filesystem/l0/entity/mod_category.dart';
import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import '../entity/app_config.dart';
import '../entity/entries.dart';
import '../entity/preset.dart';
import 'change_preset.dart';

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
