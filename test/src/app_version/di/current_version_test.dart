import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_version/di/current_version.dart';
import 'package:genshin_mod_manager/src/app_version/domain/entity/version.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  test('versionString test', () async {
    final container = ProviderContainer();
    final version = await container.read(versionStringProvider.future);
    expect(version, isA<Version>());
  });
}
