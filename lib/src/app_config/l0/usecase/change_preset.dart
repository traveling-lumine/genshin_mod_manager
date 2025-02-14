import '../../l1/entity/app_config.dart';
import '../../l1/entity/entries.dart';
import '../../l1/entity/preset.dart';
import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import 'change_app_config.dart';

AppConfig changePresetUseCase({
  required final AppConfigFacade appConfigFacade,
  required final AppConfigPersistentRepo appConfigPersistentRepo,
  required final PresetData? value,
}) {
  final currentConfig = appConfigFacade.obtainValue(games);
  final newMap = {
    ...currentConfig.gameConfig,
    currentConfig.current!:
        currentConfig.currentGameConfig.copyWith(presetData: value),
  };
  final newGamesConfig = currentConfig.copyWith(gameConfig: newMap);
  return changeAppConfigUseCase(
    appConfigFacade: appConfigFacade,
    appConfigPersistentRepo: appConfigPersistentRepo,
    entry: games,
    value: newGamesConfig,
  );
}
