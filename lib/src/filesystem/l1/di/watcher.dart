import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/transformers.dart';

import '../../l0/api/watcher.dart';
import 'filesystem.dart';

part 'watcher.g.dart';

@riverpod
Watcher directoryWatch(final Ref ref, final String path) {
  final fs = ref.watch(filesystemProvider);
  final watcher = fs.watchDirectory(path: path);
  ref.onDispose(watcher.cancel);
  return watcher;
}

@riverpod
Watcher fileWatch(final Ref ref, final String path) {
  final fs = ref.watch(filesystemProvider);
  final watcher = fs.watchFile(path: path);
  ref.onDispose(watcher.cancel);
  return watcher;
}

@riverpod
Stream<FileSystemEvent?> fileWatchDebounced(final Ref ref, final String path) {
  final fs = ref.watch(fileWatchProvider(path));
  return fs.stream.debounceTime(const Duration(milliseconds: 100));
}
