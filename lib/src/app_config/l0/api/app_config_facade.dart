import '../../l1/entity/app_config.dart';
import '../entity/app_config_entry.dart';

abstract interface class AppConfigFacade {
  T obtainValue<T>(final AppConfigEntry<T> entry);

  AppConfig storeValue<T>(final AppConfigEntry<T> entry, final T value);
}
