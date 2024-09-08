import 'dart:io';

import 'path_op_string.dart';

/// Returns a String path list under the given [path], synchronously.
List<String> getUnderSync<T extends FileSystemEntity>(
  final String path,
) {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    return [];
  }
  final res =
      dir.listSync().whereType<T>().map((final event) => event.path).toList();
  return res;
}

/// In the [paths] list, find a file path that has a [name],
/// ignoring extensions.
String? findPreviewFileInString(
  final List<String> paths, {
  final String name = 'preview',
}) {
  for (final element in paths) {
    final filename = element.pBNameWoExt;
    if (!filename.pEquals(name)) {
      continue;
    }
    return element;
  }
  return null;
}
