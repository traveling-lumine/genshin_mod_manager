import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_version/data/repo/package_verison.dart';
import 'package:genshin_mod_manager/src/app_version/domain/entity/version.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test('Package version is retrieved', () async {
    PackageInfo.setMockInitialValues(
      appName: 'appName',
      packageName: 'packageName',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'buildSignature',
    );
    final version = await getPackageVersion();
    expect(version, isA<Version>());
    expect(version.formatted, '1.0.0+1');
  });
  test('Package version is retrieved 2', () async {
    PackageInfo.setMockInitialValues(
      appName: 'appName',
      packageName: 'packageName',
      version: '1.0.0',
      buildNumber: '',
      buildSignature: 'buildSignature',
    );
    final version = await getPackageVersion();
    expect(version, isA<Version>());
    expect(version.formatted, '1.0.0');
  });
}
