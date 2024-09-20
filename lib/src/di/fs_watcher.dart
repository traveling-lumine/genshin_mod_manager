import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/fs_interface/domain/helper/fsops.dart';
import '../backend/fs_interface/domain/helper/path_op_string.dart';
import 'app_state/current_target_game.dart';
import 'fs_interface.dart';

part 'fs_watcher.g.dart';

@riverpod
Raw<Stream<FileSystemEvent>> directoryEventWatcher(
  final DirectoryEventWatcherRef ref,
  final String path, {
  required final bool detectModifications,
}) {
  if (!detectModifications) {
    final folderWatchStream = ref
        .watch(directoryEventWatcherProvider(path, detectModifications: true));
    return folderWatchStream
        .where((final event) => event is! FileSystemModifyEvent);
  }
  return Directory(path).watch().asBroadcastStream();
}

@riverpod
Raw<Stream<FileSystemEvent>> fileEventWatcher(
  final FileEventWatcherRef ref,
  final String path, {
  required final bool detectModifications,
}) {
  final dirWatcher = ref.watch(
    directoryEventWatcherProvider(
      path.pDirname,
      detectModifications: detectModifications,
    ),
  );
  return dirWatcher.where((final event) => event.path == path);
}

@riverpod
Raw<Stream<List<String>>> directoryInFolder(
  final DirectoryInFolderRef ref,
  final String path,
) {
  final controller = StreamController<List<String>>.broadcast();
  ref.onDispose(controller.close);

  final watcher = ref
      .watch(directoryEventWatcherProvider(path, detectModifications: false));
  final subscription = watcher
      .listen((final event) => controller.add(getUnderSync<Directory>(path)));
  ref.onDispose(subscription.cancel);

  return controller.stream;
}

@riverpod
Raw<Stream<List<String>>> fileInFolder(
  final FileInFolderRef ref,
  final String path,
) {
  final controller = StreamController<List<String>>.broadcast();
  ref.onDispose(controller.close);

  final watcher = ref
      .watch(directoryEventWatcherProvider(path, detectModifications: false));
  final subscription =
      watcher.listen((final event) => controller.add(getUnderSync<File>(path)));
  ref.onDispose(subscription.cancel);

  return controller.stream;
}

@riverpod
Stream<FileSystemEvent> fileEventSnapshot(
  final FileEventSnapshotRef ref,
  final String path, {
  required final bool detectModifications,
}) =>
    ref.watch(
      fileEventWatcherProvider(
        path,
        detectModifications: detectModifications,
      ),
    );


@riverpod
class FolderIconPath extends _$FolderIconPath {
  @override
  String? build(final String categoryName) {
    final currentGame = ref.watch(targetGameProvider);
    final iconDir = ref.watch(fsInterfaceProvider).iconDir(currentGame)
      ..createSync(recursive: true);
    final path = iconDir.path;

    final files = ref.watch(fileInFolderProvider(path));
    final subscription = files.listen((final event) {
      state = findPreviewFileInString(event, name: categoryName);
    });
    ref.onDispose(subscription.cancel);

    return findPreviewFileInString(
      getUnderSync<File>(path),
      name: categoryName,
    );
  }
}
