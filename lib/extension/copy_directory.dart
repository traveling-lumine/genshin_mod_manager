import 'dart:io';

import 'package:genshin_mod_manager/extension/pathops.dart';

extension CopyDirectory on Directory {
  void copyToPath(String dest) {
    _copyDirectorySync(this, dest);
  }
}

void _copyDirectorySync(Directory dir, String dest) {
  final newDir = Directory(dest)..createSync(recursive: true);
  final listSync = dir.listSync();
  for (final element in listSync) {
    final newName = newDir.path.pJoin(element.path.pBasename);
    if (element is File) {
      element.copySync(newName);
    } else if (element is Directory) {
      _copyDirectorySync(element, newName);
    }
  }
}
