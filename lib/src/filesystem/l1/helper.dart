import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

const _disabledHeader = 'DISABLED';
const _previewExtensions = [
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
  '.webp',
  '.bmp',
  '.avif',
  '.wbmp',
];

Future<String?> findPreviewPath(
  final String path, {
  final String name = 'preview',
}) async {
  final paths = await pathsUnder<File>(path);
  for (final entityPath in paths) {
    final basename = p.basenameWithoutExtension(entityPath);
    if (!p.equals(basename, name)) {
      continue;
    }
    final ext = p.extension(entityPath);
    for (final previewExt in _previewExtensions) {
      if (p.equals(ext, previewExt)) {
        return entityPath;
      }
    }
  }
  return null;
}

Future<List<String>> pathsUnder<T extends FileSystemEntity>(
  final String path,
) async {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    return [];
  }
  final res =
      dir.list().whereType<T>().map((final event) => event.path).toList();
  return res;
}

extension PathOpString on String {
  String get pDisabledForm {
    var baseName = p.basename(this);
    if (baseName.pIsEnabled) {
      baseName = '$_disabledHeader ${baseName.trimLeft()}';
    }
    if (p.split(this).length == 1) {
      return baseName;
    } else {
      return p.join(
        p.dirname(this),
        baseName,
      );
    }
  }

  String get pEnabledForm {
    var baseName = p.basename(this);
    while (!baseName.pIsEnabled) {
      baseName = baseName.substring(_disabledHeader.length).trimLeft();
    }
    if (p.split(this).length == 1) {
      return baseName;
    } else {
      return p.join(
        p.dirname(this),
        baseName,
      );
    }
  }

  bool get pIsEnabled =>
      !p.basename(this).toLowerCase().startsWith(_disabledHeader.toLowerCase());
}
