import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/fs_interface/helper/fsops.dart';
import '../backend/fs_interface/helper/path_op_string.dart';
import '../backend/structure/entity/mod.dart';
import 'fs_watcher.dart';

part 'mod_card.g.dart';

@riverpod
class ModIconPath extends _$ModIconPath {
  @override
  String? build(final Mod mod) {
    final files = ref.watch(fileInFolderProvider(mod.path));
    final subscription =
        files.listen((final event) => state = findPreviewFileInString(event));
    ref.onDispose(subscription.cancel);

    return findPreviewFileInString(getUnderSync<File>(mod.path));
  }
}

@riverpod
class IniPaths extends _$IniPaths {
  @override
  List<String> build(final Mod mod) {
    final files = ref.watch(fileInFolderProvider(mod.path));

    List<String> getIniPaths(final List<String> event) => event
        .where((final e) => e.pExtension.pEquals('.ini') && e.pIsEnabled)
        .toList();

    final subscription = files.listen((final event) {
      state = getIniPaths(event);
    });
    ref.onDispose(subscription.cancel);

    return getIniPaths(getUnderSync<File>(mod.path));
  }
}
