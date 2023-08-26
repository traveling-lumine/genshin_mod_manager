import 'dart:io';

import 'package:path/path.dart' as p;

List<Directory> getAllChildrenFolder(Directory dir) {
  final List<Directory> a = [];
  dir.listSync().forEach((element) {
    if (element is Directory) {
      a.add(element);
    }
  });
  return a;
}

List<File> getActiveiniFiles(Directory dir) {
  final List<File> a = [];
  dir.listSync().forEach((element) {
    var path = element.path;
    final filename = path.split('\\').last;
    if (element is File &&
        path.endsWith('.ini') &&
        !filename.contains('DISABLED')) {
      a.add(element);
    }
  });
  return a;
}

List<File> getAllChildrenFiles(Directory dir) {
  final List<File> a = [];
  dir.listSync().forEach((element) {
    if (element is File) {
      a.add(element);
    }
  });
  return a;
}

void copyDirectorySync(Directory dir, String dest) {
  final newDir = Directory(dest)..createSync(recursive: true);
  dir.listSync().forEach((element) {
    final newName = p.join(newDir.path, p.basename(element.path));
    if (element is File) {
      element.copySync(newName);
    } else if (element is Directory) {
      copyDirectorySync(element, newName);
    }
  });
}

File? findPreviewFile(Directory dir) {
  for (var element in dir.listSync()) {
    if (element is! File) continue;
    final filename = p.basenameWithoutExtension(element.path).toLowerCase();
    if (filename != 'preview') continue;
    final ext = p.extension(element.path).toLowerCase();
    if (ext == '.png' || ext == '.jpg' || ext == '.jpeg') {
      return element;
    }
  }
  return null;
}

void runProgram(File program) {
  Process.run(
    'start',
    ['/b', '/d', program.parent.path, '', p.basename(program.path)],
    runInShell: true,
  );
}

void openFolder(Directory dir) {
  Process.start(
    'explorer',
    [dir.path],
    runInShell: true,
  );
}
