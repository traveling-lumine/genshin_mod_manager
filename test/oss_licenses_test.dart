import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/oss_licenses.dart';

void main() {
  test('Licnese packages are available', () {
    expect(dependencies, isA<List<Package>>());
  });
}
