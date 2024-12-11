import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_version/data/repo/remote_version.dart';

void main() {
  test('Remote version is retrieved', () async {
    final version = await getRemoteVersion();
    expect(version, isNotNull);
  });
}
