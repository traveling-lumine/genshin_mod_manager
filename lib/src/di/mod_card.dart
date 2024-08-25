import 'dart:io';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/akasha/data/repo/akasha.dart';
import '../backend/fs_interface/data/helper/fsops.dart';
import '../backend/fs_interface/data/helper/path_op_string.dart';
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
class ConfigPath extends _$ConfigPath {
  @override
  String? build(final Mod mod) {
    final files = ref.watch(fileInFolderProvider(mod.path));
    final subscription = files.listen((final event) {
      state = event.firstWhereOrNull(
        (final path) => path.pBasename.pEquals(kAkashaConfigFilename),
      );
    });
    ref.onDispose(subscription.cancel);

    return getUnderSync<File>(mod.path).firstWhereOrNull(
      (final path) => path.pBasename.pEquals(kAkashaConfigFilename),
    );
  }
}

@riverpod
class IniPaths extends _$IniPaths {
  @override
  List<String> build(final Mod mod) {
    final files = ref.watch(fileInFolderProvider(mod.path));
    final subscription = files.listen((final event) {
      state =
          event.where((final path) => path.pExtension.pEquals('.ini')).toList();
    });
    ref.onDispose(subscription.cancel);

    return getUnderSync<File>(mod.path)
        .where((final path) => path.pExtension.pEquals('.ini'))
        .toList();
  }
}
