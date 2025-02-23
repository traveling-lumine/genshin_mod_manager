import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/entity/ini.dart';
import '../l0/entity/mod.dart';
import '../l1/di/filesystem.dart';

part 'mod_card.g.dart';

@riverpod
Stream<List<IniFile>> iniPaths(final Ref ref, final Mod mod) {
  final watch = ref.watch(filesystemProvider);
  final watcher = watch.watchDirectory(path: mod.path);
  ref.onDispose(watcher.cancel);
  return watch.iniPathsStream(watcher.stream, mod);
}

@riverpod
Stream<String?> modPreviewPath(final Ref ref, final Mod mod) {
  final fs = ref.watch(filesystemProvider);
  final watcher = fs.watchDirectory(path: mod.path);
  ref.onDispose(watcher.cancel);
  final stream = watcher.stream;
  return fs.modPreviewPathStream(stream, mod);
}
