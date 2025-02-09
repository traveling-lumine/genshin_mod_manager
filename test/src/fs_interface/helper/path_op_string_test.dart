import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/filesystem/l1/impl/path_op_string.dart';

void main() {
  group('Enabled recognition', () {
    test('Enabled path', () {
      const path = 'test';
      expect(path.pIsEnabled, true);
    });
    test('Disabled path', () {
      const path = 'DISABLED test';
      expect(path.pIsEnabled, false);
    });
  });
  group('Form change', () {
    test('Enabled to enabled', () {
      const path = 'test';
      expect(path.pEnabledForm, 'test');
    });
    test('Disabled to enabled', () {
      const path = 'DISABLED test';
      expect(path.pEnabledForm, 'test');
    });
    test('Enabled to disabled', () {
      const path = 'test';
      expect(path.pDisabledForm, 'DISABLED test');
    });
    test('Disabled to disabled', () {
      const path = 'DISABLED test';
      expect(path.pDisabledForm, 'DISABLED test');
    });
  });
}
