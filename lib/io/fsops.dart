import 'dart:io';

import 'package:genshin_mod_manager/extension/pathops.dart';

List<Directory> getDirsUnder(Directory dir) {
  return dir.listSync().whereType<Directory>().toList(growable: false);
}

List<File> getFilesUnder(Directory dir) {
  return dir.listSync().whereType<File>().toList(growable: false);
}

List<File> getActiveiniFiles(Directory dir) {
  return getFilesUnder(dir).where((element) {
    final path = element.pathString;
    final extension = path.extension;
    if (extension != const PathW('.ini')) return false;
    final filename = path.basenameWithoutExtension;
    return filename.isEnabled;
  }).toList(growable: false);
}

const _previewExtensions = [
  PathW('.png'),
  PathW('.jpg'),
  PathW('.jpeg'),
  PathW('.gif'),
];

File? findPreviewFile(Directory dir, {PathW name = const PathW('preview')}) =>
    findPreviewFileIn(getFilesUnder(dir), name: name);

File? findPreviewFileIn(List<File> dir, {PathW name = const PathW('preview')}) {
  for (final element in dir) {
    final filename = element.basenameWithoutExtension;
    if (filename != name) continue;
    final ext = element.extension;
    if (_previewExtensions.contains(ext)) return element;
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
