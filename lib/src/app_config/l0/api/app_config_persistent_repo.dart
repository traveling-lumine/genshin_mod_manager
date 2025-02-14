import '../../l1/entity/app_config.dart';

abstract interface class AppConfigPersistentRepo {
  Stream<Map<String, dynamic>> get stream;

  Future<void> save(final AppConfig value);

  Future<void> dispose();
}
