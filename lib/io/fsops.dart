import 'dart:io';

import 'package:path/path.dart' as p;

List<Directory> getFoldersUnder(Directory dir) {
  return dir.listSync().whereType<Directory>().toList(growable: false);
}

List<File> getFilesUnder(Directory dir) {
  return dir.listSync().whereType<File>().toList(growable: false);
}

List<File> getActiveiniFiles(Directory dir) {
  return getFilesUnder(dir).where((element) {
    final path = element.path;
    final extension = p.extension(path).toLowerCase();
    if (extension != '.ini') return false;
    final filename = p.basenameWithoutExtension(path).toLowerCase();
    return !filename.startsWith('disabled');
  }).toList(growable: false);
}

File? findPreviewFile(Directory dir, {String name = 'preview'}) {
  name = name.toLowerCase();
  for (final element in getFilesUnder(dir)) {
    final filename = p.basenameWithoutExtension(element.path).toLowerCase();
    if (filename != name) continue;
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
