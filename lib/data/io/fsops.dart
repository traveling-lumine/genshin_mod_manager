import 'dart:io';

import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:rxdart/rxdart.dart';

Future<List<T>> getFSEUnder<T extends FileSystemEntity>(String path) async {
  final dir = Directory(path);
  if (!await dir.exists()) return [];
  final res = await dir.list().whereType<T>().toList();
  return List.unmodifiable(res);
}

Future<List<File>> getActiveiniFiles(String path) async {
  final fseUnder = await getFSEUnder<File>(path);
  return List.unmodifiable(fseUnder.where((element) {
    final path = element.path;
    final extension = path.pExtension;
    if (!extension.pEquals('.ini')) return false;
    final filename = path.pBNameWoExt;
    return filename.pIsEnabled;
  }));
}

const _previewExtensions = [
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
];

String? findPreviewFileInString(List<String> dir, {String name = 'preview'}) {
  for (final element in dir) {
    final filename = element.pBNameWoExt;
    if (!filename.pEquals(name)) continue;
    final ext = element.pExtension;
    for (final previewExt in _previewExtensions) {
      if (ext.pEquals(previewExt)) return element;
    }
  }
  return null;
}

void runProgram(File program) {
  final pwd = program.parent.path;
  final pName = program.path.pBasename;
  Process.run('start', ['/b', '/d', pwd, '', pName], runInShell: true);
}

void openFolder(String dirPath) {
  Process.start('explorer', [dirPath], runInShell: true);
}
