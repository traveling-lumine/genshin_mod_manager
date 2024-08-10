import 'dart:async';
import 'dart:io';

import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/repo/fs_watcher.dart';
import 'package:genshin_mod_manager/di/app_state.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/fs_watcher.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_shell.g.dart';

@riverpod
class HomeShellList extends _$HomeShellList {
  RootWatcher? _watcher;

  @override
  Stream<List<ModCategory>> build() {
    final modRoot = ref.watch(
      gameConfigNotifierProvider.select((final state) => state.modRoot),
    );
    if (modRoot == null) {
      _watcher = null;
    } else {
      final rootWatcherImpl = RootWatcherImpl(modRoot);
      _watcher = rootWatcherImpl;
      ref.onDispose(() {
        _watcher = null;
        rootWatcherImpl.dispose();
      });
    }
    return _watcher?.categories ?? Stream.value([]);
  }

  void refresh() {
    _watcher?.refresh();
  }
}

@riverpod
Stream<List<(String, int)>> folderIcons(final FolderIconsRef ref) {
  final currentGame = ref.watch(targetGameProvider);
  final iconDir = Directory(
    Platform.resolvedExecutable.pDirname.pJoin('Resources', currentGame),
  )..createSync(recursive: true);
  final watcher =
      FolderWatcher<File>(path: iconDir.path, watchModifications: true);
  ref.onDispose(watcher.dispose);
  return watcher.entities.map(
    (final event) => event
        .map(
          (final e) => (e, File(e).lastModifiedSync().millisecondsSinceEpoch),
        )
        .toList(),
  );
}

@riverpod
(String, int)? folderIconPath(
  final FolderIconPathRef ref,
  final String categoryName,
) {
  final icons = ref.watch(folderIconsProvider);
  return icons.whenOrNull(
    skipLoadingOnRefresh: false,
    data: (final data) =>
        findPreviewFileInStringTuple(data, name: categoryName),
  );
}
