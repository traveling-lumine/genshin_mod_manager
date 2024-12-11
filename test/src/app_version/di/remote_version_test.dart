import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_version/di/remote_version.dart';
import 'package:genshin_mod_manager/src/app_version/domain/entity/version.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  test('Test remote version provider', () async {
    final container = ProviderContainer();
    final remoteVersion = await container.read(remoteVersionProvider.future);
    expect(remoteVersion, isA<Version>());
  });
}
