import 'dart:io';

import 'package:collection/collection.dart';
import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/repo/akasha.dart';
import 'package:genshin_mod_manager/di/fs_watcher.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
