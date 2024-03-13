import 'dart:collection';
import 'dart:io';

import 'package:genshin_mod_manager/data/extension/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:rxdart/rxdart.dart';

Future<List<ModCategory>> getCategories(AppStateService service) async {
  final root = service.modRoot.latest;
  if (root == null) return [];
  final dir = Directory(root);
  if (!await dir.exists()) return [];
  final res = await dir.list().whereType<Directory>().map((event) {
    final path = event.path;
    return ModCategory(
      path: path,
      name: path.pBasename,
    );
  }).toList();
  return UnmodifiableListView(res);
}

Future<List<Mod>> getMods(ModCategory category) async {
  final root = category.path;
  final res = await Directory(root).list().whereType<Directory>().map((event) {
    final path = event.path;
    return Mod(
      path: path,
      displayName: path.pEnabledForm.pBasename,
      isEnabled: path.pIsEnabled,
    );
  }).toList();
  return UnmodifiableListView(res);
}

Future<List<File>> getActiveIniFiles(Mod mod) async {
  final res =
      await Directory(mod.path).list().whereType<File>().where((element) {
    final path = element.path;
    final extension = path.pExtension;
    if (!extension.pEquals('.ini')) return false;
    return path.pBasename.pIsEnabled;
  }).toList();
  return List.unmodifiable(res);
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
