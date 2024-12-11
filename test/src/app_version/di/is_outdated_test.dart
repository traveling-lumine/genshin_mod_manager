import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_version/di/current_version.dart';
import 'package:genshin_mod_manager/src/app_version/di/is_outdated.dart';
import 'package:genshin_mod_manager/src/app_version/di/remote_version.dart';
import 'package:genshin_mod_manager/src/app_version/domain/entity/version.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  test('Test version not outdated', () async {
    final container = ProviderContainer(
      overrides: [
        versionStringProvider.overrideWith(
          (final ref) => Future.value(Version.parse('1.0.1')),
        ),
        remoteVersionProvider.overrideWith(
          (final ref) => Future.value(Version.parse('1.0.1')),
        ),
      ],
    );
    final isOutdated = await container.read(isOutdatedProvider.future);
    expect(isOutdated, isFalse);
  });
  test('Test version outdated', () async {
    final container = ProviderContainer(
      overrides: [
        versionStringProvider.overrideWith(
          (final ref) => Future.value(Version.parse('1.0.1')),
        ),
        remoteVersionProvider.overrideWith(
          (final ref) => Future.value(Version.parse('1.0.2')),
        ),
      ],
    );
    final isOutdated = await container.read(isOutdatedProvider.future);
    expect(isOutdated, isTrue);
  });
}
