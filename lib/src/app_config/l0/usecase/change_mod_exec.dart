import '../entity/app_config.dart';
import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import '../entity/entries.dart';
import 'change_app_config.dart';

AppConfig changeModExecUseCase({
  required final AppConfigFacade appConfigFacade,
  required final AppConfigPersistentRepo appConfigPersistentRepo,
  required final String value,
}) {
  final currentConfig = appConfigFacade.obtainValue(games);
  final newMap = {
    ...currentConfig.gameConfig,
    currentConfig.current!:
        currentConfig.currentGameConfig.copyWith(modExecFile: value),
  };
  final newGamesConfig = currentConfig.copyWith(gameConfig: newMap);
  return changeAppConfigUseCase(
    appConfigFacade: appConfigFacade,
    appConfigPersistentRepo: appConfigPersistentRepo,
    entry: games,
    value: newGamesConfig,
  );
}
