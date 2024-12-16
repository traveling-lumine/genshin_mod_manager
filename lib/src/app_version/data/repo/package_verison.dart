import 'package:package_info_plus/package_info_plus.dart';

import '../../domain/entity/version.dart';
import '../../domain/repo/version_retriever.dart';

VersionRetriever getPackageVersion = () async {
  final info = await PackageInfo.fromPlatform();
  final version = info.version;
  final buildNumber = info.buildNumber;
  if (buildNumber.isEmpty) {
    return Version.parse(version);
  }
  return Version.parse('$version+$buildNumber');
};
