import 'dart:async';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../storage/di/current_target_game.dart';
import '../helper/fsops.dart';
import '../helper/path_op_string.dart';
import 'fs_interface.dart';

part 'fs_watcher.g.dart';

@riverpod
class DirectoryEventWatcher extends _$DirectoryEventWatcher {
  StreamSubscription<FileSystemEvent>? _subscription;
  StreamController<FileSystemEvent>? _controller;

  @override
  Raw<Stream<FileSystemEvent>> build(
    final String path, {
    required final bool detectModifications,
  }) {
    if (!detectModifications) {
      final folderWatchStream = ref.watch(
        directoryEventWatcherProvider(path, detectModifications: true),
      );
      return folderWatchStream
          .where((final event) => event is! FileSystemModifyEvent);
    }

    final controller = StreamController<FileSystemEvent>.broadcast();
    ref.onDispose(controller.close);
    _controller = controller;

    final subscription = Directory(path).watch().listen(controller.add);
    ref.onDispose(subscription.cancel);
    _subscription = subscription;

    return controller.stream;
  }

  void pause() {
    if (!detectModifications) {
      return;
    }
    unawaited(_subscription?.cancel());
  }

  void resume() {
    if (!detectModifications) {
      return;
    }
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final subscription = Directory(path).watch().listen(controller.add);
    ref.onDispose(subscription.cancel);
    _subscription = subscription;
  }
}

@riverpod
Raw<Stream<FileSystemEvent>> fileEventWatcher(
  final Ref ref,
  final String path, {
  required final bool detectModifications,
}) {
  final controller = StreamController<FileSystemEvent>.broadcast();
  ref.onDispose(controller.close);

  final dirWatcher = ref.watch(
    directoryEventWatcherProvider(
      path.pDirname,
      detectModifications: detectModifications,
    ),
  );
  final subscription = dirWatcher.listen(controller.add);
  ref.onDispose(subscription.cancel);

  return controller.stream;
}

@riverpod
Raw<Stream<List<String>>> directoryInFolder(
  final Ref ref,
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
  final Ref ref,
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
