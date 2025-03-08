import 'dart:io';

import 'package:path/path.dart' as p;

import '../../l0/api/basic_path.dart';

class BasicPathProviderImpl implements BasicPathProvider {
  @override
  late Directory resourceDir = Directory(p.join(workDir.path, 'Resources'));

  @override
  late File settingFile = File(p.join(workDir.path, 'settings.json'));

  @override
  late Directory workDir = File(Platform.resolvedExecutable).parent;

  @override
  Directory getIconRoot(final String gameName) =>
      Directory(p.join(resourceDir.path, gameName));
}
