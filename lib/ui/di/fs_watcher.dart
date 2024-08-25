import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_state.dart';
import '../../backend/structure/entity/mod.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../../backend/fs_interface/data/helper/fsops.dart';
import '../../backend/fs_interface/data/helper/path_op_string.dart';
import 'fs_interface.dart';

part 'fs_watcher.g.dart';

@riverpod
Raw<Stream<FileSystemEvent>> folderEventWatcher(
  final FolderEventWatcherRef ref,
  final String path,
  final bool detectModifications,
) {
  if (!detectModifications) {
    final folderWatchStream = ref.watch(folderEventWatcherProvider(path, true));
    return folderWatchStream
        .where((final event) => event is! FileSystemModifyEvent);
  }
  return Directory(path).watch().asBroadcastStream();
}

@riverpod
Raw<Stream<List<String>>> directoryInFolder(
  final DirectoryInFolderRef ref,
  final String path,
) {
  final controller = StreamController<List<String>>.broadcast();
  ref.onDispose(controller.close);

  final watcher = ref.watch(folderEventWatcherProvider(path, false));
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

  final watcher = ref.watch(folderEventWatcherProvider(path, false));
  final subscription =
      watcher.listen((final event) => controller.add(getUnderSync<File>(path)));
  ref.onDispose(subscription.cancel);

  return controller.stream;
}

@riverpod
Raw<Stream<FileSystemEvent>> fileEventWatcher(
  final FileEventWatcherRef ref,
  final String path,
  final bool detectModifications,
) {
  final dirWatcher =
      ref.watch(folderEventWatcherProvider(path.pDirname, detectModifications));
  return dirWatcher.where((final event) => event.path == path);
}

@riverpod
Stream<FileSystemEvent> fileEventSnapshot(
  final FileEventSnapshotRef ref,
  final String path,
  final bool detectModifications,
) =>
    ref.watch(fileEventWatcherProvider(path, detectModifications));

@riverpod
Stream<List<Mod>> modsInCategory(
  final ModsInCategoryRef ref,
  final ModCategory category,
) {
  final enabledModsFirst = ref.watch(enabledFirstProvider);

  final controller = StreamController<List<Mod>>();
  ref.onDispose(controller.close);

  void addData() {
    controller.add(
      getUnderSync<Directory>(category.path)
          .map(
            (final e) => Mod(
              path: e,
              displayName: e.pEnabledForm.pBasename,
              isEnabled: e.pIsEnabled,
              category: category,
            ),
          )
          .toList()
        ..sort((final a, final b) {
          if (enabledModsFirst) {
            final aEnabled = a.isEnabled;
            final bEnabled = b.isEnabled;
            if (aEnabled && !bEnabled) {
              return -1;
            } else if (!aEnabled && bEnabled) {
              return 1;
            }
          }
          final aLower = a.path.pEnabledForm.pBasename.toLowerCase();
          final bLower = b.path.pEnabledForm.pBasename.toLowerCase();
          return aLower.compareTo(bLower);
        }),
    );
  }

  addData();

  final watch = ref.watch(directoryInFolderProvider(category.path));
  final subscription = watch.listen((final event) => addData());
  ref.onDispose(subscription.cancel);

  return controller.stream;
}

@riverpod
class Categories extends _$Categories {
  @override
  List<ModCategory> build() {
    final modRoot = ref.watch(
      gameConfigNotifierProvider.select((final state) => state.modRoot),
    );
    if (modRoot == null) {
      return [];
    }

    List<ModCategory> addData() => getUnderSync<Directory>(modRoot)
        .map(
          (final e) => ModCategory(
            path: e,
            name: e.pBasename,
          ),
        )
        .toList();

    final watcher = ref.watch(directoryInFolderProvider(modRoot));
    final subscription = watcher.listen((final event) => state = addData());
    ref.onDispose(subscription.cancel);

    return addData();
  }
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
