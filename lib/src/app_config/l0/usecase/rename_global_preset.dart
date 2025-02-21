import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import '../entity/app_config.dart';
import '../entity/preset.dart';
import 'change_preset.dart';

AppConfig? renameGlobalPresetUseCase({
  required final PresetData presetData,
  required final String oldName,
  required final String newName,
  required final AppConfigFacade read,
  required final AppConfigPersistentRepo read2,
}) {
  final globalPresets = presetData.global;
  final oldData = globalPresets[oldName];
  if (oldData == null) {
    return null;
  }
  if (globalPresets.containsKey(newName)) {
    return null;
  }
  final res = presetData.copyWith(
    global: {
      for (final MapEntry(:key, :value) in globalPresets.entries)
        if (key == oldName) newName: value else key: value,
    },
  );
  final newState = changePresetUseCase(
    appConfigFacade: read,
    value: res,
    appConfigPersistentRepo: read2,
  );
  return newState;
}
