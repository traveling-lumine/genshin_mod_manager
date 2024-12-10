import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entity/version.dart';

part 'current_version.g.dart';

@riverpod
Future<Version> versionString(final VersionStringRef ref) async {
  final info = await PackageInfo.fromPlatform();
  final version = info.version;
  final buildNumber = info.buildNumber;
  if (buildNumber.isEmpty) {
    return Version.parse(version);
  }
  return Version.parse('$version+$buildNumber');
}
