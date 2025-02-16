import '../../../filesystem/l0/entity/mod_category.dart';
import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import '../entity/app_config.dart';
import '../entity/entries.dart';
import '../entity/preset.dart';
import 'change_preset.dart';

AppConfig? removeLocalPresetUseCase({
  required final AppConfigFacade read,
  required final ModCategory category2,
  required final String name,
  required final AppConfigPersistentRepo read2,
}) {
  final presetData = read.obtainValue(games).currentGameConfig.presetData;
  final localPresets = presetData.local;
  final categoryPresets = localPresets[category2.name];
  if (categoryPresets == null) {
    return null;
  }
  final modString = {...categoryPresets.bundledPresets}..remove(name);
  final newCategoryPresets = PresetListMap(bundledPresets: modString);
  final newLocalPresets = {...localPresets}..[category2.name] =
      newCategoryPresets;
  final res = presetData.copyWith(local: newLocalPresets);
  final newState = changePresetUseCase(
    appConfigFacade: read,
    value: res,
    appConfigPersistentRepo: read2,
  );
  return newState;
}
