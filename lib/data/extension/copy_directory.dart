import 'dart:io';

import 'package:genshin_mod_manager/data/extension/path_op_string.dart';

/// Extension for [Directory] to copy the directory to another path.
extension CopyDirectory on Directory {
  /// Copy this directory to the given path.
  void copyToPath(final String dest) {
    _copyDirectorySync(this, dest);
  }
}

void _copyDirectorySync(final Directory dir, final String dest) {
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
