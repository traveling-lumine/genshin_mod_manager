import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'filesystem.dart';

part 'watcher.g.dart';

@riverpod
Stream<FileSystemEvent?> watchFile(
  final Ref ref, {
  required final String path,
}) {
  final fs = ref.watch(filesystemProvider);
  final watcher = fs.watchFile(path: path);
  ref.onDispose(watcher.cancel);
  return watcher.stream;
}
