import 'dart:io';

import 'package:path/path.dart' as p;

extension CopyDirectory on Directory {
  void copyTo(String dest) {
    _copyDirectorySync(this, dest);
  }
}

void _copyDirectorySync(Directory dir, String dest) {
  final newDir = Directory(dest)..createSync(recursive: true);
  dir.listSync().forEach((element) {
    final newName = p.join(newDir.path, p.basename(element.path));
    if (element is File) {
      element.copySync(newName);
    } else if (element is Directory) {
      _copyDirectorySync(element, newName);
    }
  });
}
