import 'dart:io';

import 'package:genshin_mod_manager/data/extension/pathops.dart';

List<T> getFSEUnder<T extends FileSystemEntity>(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return [];
  return dir.listSync().whereType<T>().toList(growable: false);
}

List<File> getActiveiniFiles(String path) {
  return getFSEUnder<File>(path).where((element) {
    final path = element.path;
    final extension = path.pExtension;
    if (!extension.pEquals('.ini')) return false;
    final filename = path.pBNameWoExt;
    return filename.pIsEnabled;
  }).toList(growable: false);
}

const _previewExtensions = [
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
];

File? findPreviewFile(String path, {String name = 'preview'}) =>
    findPreviewFileIn(getFSEUnder<File>(path), name: name);

File? findPreviewFileIn(List<File> dir, {String name = 'preview'}) {
  for (final element in dir) {
    final filename = element.path.pBNameWoExt;
    if (!filename.pEquals(name)) continue;
    final ext = element.path.pExtension;
    for (final previewExt in _previewExtensions) {
      if (ext.pEquals(previewExt)) return element;
    }
  }
  return null;
}

void runProgram(File program) {
  Process.run(
    'start',
    [
      '/b',
      '/d',
      program.parent.path,
      '',
      program.path.pBasename,
    ],
    runInShell: true,
  );
}

void openFolder(String dirPath) {
  Process.start(
    'explorer',
    [dirPath],
    runInShell: true,
  );
}
