import '../../l0/api/app_config_facade.dart';
import '../../l0/entity/app_config_entry.dart';
import '../entity/app_config.dart';
import '../entity/entries.dart';

class AppConfigFacadeImpl implements AppConfigFacade {
  const AppConfigFacadeImpl({required this.config});

  final AppConfig? config;

  @override
  T obtainValue<T>(final AppConfigEntry<T> entry) {
    final config = this.config;
    if (config == null) {
      if (entry == darkMode) {
        return entry.defaultValue;
      }
      throw StateError(
        'AppConfig is not initialized. Value cannot be obtained.',
      );
    }
    final value = config.entry[entry.key];
    if (value == null) {
      return entry.defaultValue;
    }
    try {
      return entry.fromJson(value);
    } on Exception {
      return entry.defaultValue;
    }
  }

  @override
  AppConfig storeValue<T>(final AppConfigEntry<T> entry, final T value) {
    final config = this.config;
    if (config == null) {
      throw StateError(
        'AppConfig is not initialized. Value cannot be stored.',
      );
    }
    final entries = {
      ...config.entry,
      entry.key: entry.toJson(value),
    };
    return config.copyWith(entry: entries);
  }
}
