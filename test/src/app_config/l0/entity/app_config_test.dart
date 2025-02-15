import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_config/l0/entity/app_config.dart';

void main() {
  test('test name', () {
    var a = AppConfig.fromJson({});
    a = a.copyWith(
      entry: {
        ...a.entry,
        'key': 'value',
      },
    );
    expect(a.entry['key'], 'value');
  });
}
