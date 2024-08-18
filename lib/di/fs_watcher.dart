import 'dart:io';

import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/repo/fs_watcher.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fs_watcher.g.dart';

@riverpod
FolderWatcher<File> folderFileWatcher(
  final FolderFileWatcherRef ref,
  final String path,
  final bool watchModifications,
) {
  final folderWatcher = FolderWatcher<File>(
    path: path,
    watchModifications: watchModifications,
    broadcast: true,
  );
  ref.onDispose(folderWatcher.dispose);
  return folderWatcher;
}

@riverpod
Stream<int> fileWatcher(
  final FileWatcherRef ref,
  final String path,
) {
  print('fileWatcher: $path');
  final fileModificationWatcher = FileModificationWatcher(
    path: path,
    watcher: ref.watch(folderFileWatcherProvider(path.pDirname, true)),
  );
  ref.onDispose(fileModificationWatcher.dispose);
  return fileModificationWatcher.eventTime;
}
