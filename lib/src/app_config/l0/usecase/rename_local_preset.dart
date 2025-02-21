import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import '../entity/app_config.dart';
import '../entity/preset.dart';
import 'change_preset.dart';

AppConfig? renameLocalPresetUseCase({
  required final PresetData presetData,
  required final String category2,
  required final String oldName,
  required final String newName,
  required final AppConfigFacade read,
  required final AppConfigPersistentRepo read2,
}) {
  final localPresets = presetData.local;
  final categoryPresets = localPresets[category2];
  if (categoryPresets == null) {
    return null;
  }
  final modString = {...categoryPresets.bundledPresets};
  final oldMods = modString.remove(oldName);
  if (oldMods == null) {
    return null;
  }
  if (modString.containsKey(newName)) {
    return null;
  }
  modString[newName] = oldMods;
  final newCategoryPresets = PresetListMap(bundledPresets: modString);
  final newLocalPresets = {...localPresets}..[category2] = newCategoryPresets;
  final res = presetData.copyWith(local: newLocalPresets);
  final newState = changePresetUseCase(
    appConfigFacade: read,
    value: res,
    appConfigPersistentRepo: read2,
  );
  return newState;
}
