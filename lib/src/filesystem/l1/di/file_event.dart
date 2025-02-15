import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'filesystem.dart';

part 'file_event.g.dart';

@riverpod
Stream<FileSystemEvent?> fileEvent(
  final Ref ref, {
  required final String path,
}) {
  final fs = ref.watch(filesystemProvider);
  final watcher = fs.watchFile(path: path);
  ref.onDispose(watcher.cancel);
  return watcher.stream;
}

@riverpod
Stream<FileSystemEvent?> fileEventDebounced(
  final Ref ref, {
  required final String path,
}) {
  final fs = ref.watch(filesystemProvider);
  final watcher = fs.watchFile(path: path);
  ref.onDispose(watcher.cancel);
  return watcher.stream.debounceTime(const Duration(milliseconds: 100));
}
