import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/entity/mod.dart';
import '../l1/di/filesystem.dart';
import '../l1/impl/fsops.dart';
import '../l1/impl/path_op_string.dart';

part 'mod_card.g.dart';

@riverpod
Stream<List<String>> iniPaths(final Ref ref, final Mod mod) {
  final watch = ref.watch(filesystemProvider);
  final watcher = watch.watchDirectory(path: mod.path);
  ref.onDispose(watcher.cancel);
  return watcher.stream.asyncMap(
    (final event) async => (await getUnder<File>(mod.path))
        .where((final e) => e.pExtension.pEquals('.ini') && e.pIsEnabled)
        .toList(),
  );
}

@riverpod
Stream<String?> modPreviewPath(final Ref ref, final Mod mod) {
  final fs = ref.watch(filesystemProvider);
  final watcher = fs.watchDirectory(path: mod.path);
  ref.onDispose(watcher.cancel);
  return watcher.stream.asyncMap(
    (final event) async =>
        findPreviewFileInString(await getUnder<File>(mod.path)),
  );
}
