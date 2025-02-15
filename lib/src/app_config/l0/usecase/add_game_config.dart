import '../entity/app_config.dart';
import '../entity/game_config.dart';
import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import '../entity/entries.dart';
import '../entity/game_already_exists_exception.dart';
import 'change_app_config.dart';

AppConfig addGameConfig({
  required final AppConfigFacade appConfigFacade,
  required final AppConfigPersistentRepo appConfigPersistentRepo,
  required final String gameName,
  final bool force = false,
}) {
  final currentGameConfig = appConfigFacade.obtainValue(games);
  if (currentGameConfig.gameConfig.containsKey(gameName) && !force) {
    throw GameAlreadyExistsException(gameName);
  }
  final storeValue = currentGameConfig.copyWith(
    current: gameName,
    gameConfig: {
      ...currentGameConfig.gameConfig,
      gameName: const GameConfig(),
    },
  );
  return changeAppConfigUseCase(
    appConfigFacade: appConfigFacade,
    appConfigPersistentRepo: appConfigPersistentRepo,
    entry: games,
    value: storeValue,
  );
}
