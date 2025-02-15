import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_config/l1/entity/app_config.dart';
import 'package:genshin_mod_manager/src/app_config/l1/entity/entry_helpers.dart';
import 'package:genshin_mod_manager/src/app_config/l1/impl/app_config_facade.dart';

void main() {
  group('obtainValue', () {
    test('default data', () {
      const config = AppConfigFacadeImpl(currentConfig: AppConfig({}));
      final entry = stringEntry(key: 'key', defaultValue: 'default');
      expect(config.obtainValue(entry), 'default');
    });
    test('retrieve data', () {
      const config =
          AppConfigFacadeImpl(currentConfig: AppConfig({'key': 'value'}));
      final entry = stringEntry(key: 'key', defaultValue: 'default');
      expect(config.obtainValue(entry), 'value');
    });
    test('invalid data', () {
      const config = AppConfigFacadeImpl(currentConfig: AppConfig({'key': 1}));
      final entry = stringEntry(key: 'key', defaultValue: 'default');
      expect(config.obtainValue(entry), 'default');
    });
  });
}
