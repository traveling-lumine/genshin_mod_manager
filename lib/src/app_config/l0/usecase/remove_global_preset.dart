import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import '../entity/app_config.dart';
import '../entity/entries.dart';
import 'change_preset.dart';

AppConfig removeGlobalPresetUseCase({
  required final AppConfigFacade read,
  required final String name,
  required final AppConfigPersistentRepo read2,
}) {
  final presetData = read.obtainValue(games).currentGameConfig.presetData;
  final res = presetData.copyWith(global: {...presetData.global}..remove(name));
  final newState = changePresetUseCase(
    appConfigFacade: read,
    value: res,
    appConfigPersistentRepo: read2,
  );
  return newState;
}
