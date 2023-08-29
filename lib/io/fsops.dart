import 'dart:io';

import 'package:genshin_mod_manager/extension/pathops.dart';

List<Directory> getFoldersUnder(Directory dir) {
  return dir.listSync().whereType<Directory>().toList(growable: false);
}

List<File> getFilesUnder(Directory dir) {
  return dir.listSync().whereType<File>().toList(growable: false);
}

List<File> getActiveiniFiles(Directory dir) {
  return getFilesUnder(dir).where((element) {
    final path = element.pathString;
    final extension = path.extension;
    if (extension != const PathString('.ini')) return false;
    final filename = path.basenameWithoutExtension;
    return filename.isEnabled;
  }).toList(growable: false);
}

File? findPreviewFile(Directory dir,
    {PathString name = const PathString('preview')}) {
  for (final element in getFilesUnder(dir)) {
    final filename = element.basenameWithoutExtension;
    if (filename != name) continue;
    final ext = element.extension;
    if (ext == const PathString('.png') ||
        ext == const PathString('.jpg') ||
        ext == const PathString('.jpeg')) {
      return element;
    }
  }
  return null;
}

void runProgram(File program) {
  Process.run(
    'start',
    ['/b', '/d', program.parent.path, '', program.basename.asString],
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
