import '../entity/app_config.dart';
import 'disposable.dart';

abstract interface class AppConfigPersistentRepo implements Disposable {
  Stream<AppConfig> get stream;

  Future<void> save(final AppConfig value);
}
