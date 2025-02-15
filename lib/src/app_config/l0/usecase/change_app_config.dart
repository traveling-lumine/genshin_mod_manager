import 'dart:async';

import '../entity/app_config.dart';
import '../api/app_config_facade.dart';
import '../api/app_config_persistent_repo.dart';
import '../entity/app_config_entry.dart';

AppConfig changeAppConfigUseCase<T>({
  required final AppConfigFacade appConfigFacade,
  required final AppConfigPersistentRepo appConfigPersistentRepo,
  required final AppConfigEntry<T> entry,
  required final T value,
}) {
  final storeValue = appConfigFacade.storeValue(entry, value);
  unawaited(appConfigPersistentRepo.save(storeValue));
  return storeValue;
}
