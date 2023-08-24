import 'dart:io';

import 'package:path/path.dart' as p;

List<Directory> getAllChildrenFolder(Directory dir) {
  List<Directory> a = [];
  dir.listSync().forEach((element) {
    if (element is Directory) {
      a.add(element);
    }
  });
  return a;
}

List<File> getActiveiniFiles(Directory dir) {
  List<File> a = [];
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
