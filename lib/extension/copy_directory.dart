import 'dart:io';

import 'package:genshin_mod_manager/extension/pathops.dart';

extension CopyDirectory on Directory {
  void copyToPath(PathString dest) {
    _copyDirectorySync(this, dest);
  }
}

void _copyDirectorySync(Directory dir, PathString dest) {
  final newDir = dest.toDirectory..createSync(recursive: true);
  dir.listSync().forEach((element) {
    final newName = newDir.join(element.basename);
    if (element is File) {
      element.copySyncPath(newName);
    } else if (element is Directory) {
      _copyDirectorySync(element, newName);
    }
  });
}
