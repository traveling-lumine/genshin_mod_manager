import '../entity/app_config.dart';
import 'disposable.dart';

abstract interface class AppConfigPersistentRepo implements Disposable {
  Stream<Map<String, dynamic>> get stream;

  Future<void> save(final AppConfig value);
}
