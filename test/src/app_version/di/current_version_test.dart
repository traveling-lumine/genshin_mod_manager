import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_version/di/current_version.dart';
import 'package:genshin_mod_manager/src/app_version/domain/entity/version.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test('versionString test', () async {
    PackageInfo.setMockInitialValues(
      appName: 'appName',
      packageName: 'packageName',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'buildSignature',
    );
    final container = ProviderContainer();
    final version = await container.read(versionStringProvider.future);
    expect(version, isA<Version>());
    expect(version.formatted, '1.0.0+1');
  });
}
