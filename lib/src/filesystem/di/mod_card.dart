import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../fs_interface/helper/fsops.dart';
import '../../fs_interface/helper/path_op_string.dart';
import '../l0/api/filesystem.dart';
import '../l0/api/mod_preview.dart';
import '../l0/api/watcher.dart';
import '../l0/entity/mod.dart';
import '../l1/di/filesystem.dart';
import '../l1/impl/mod_preview.dart';

part 'mod_card.g.dart';

@riverpod
ModPreviewPathRepo modPreviewPath(final Ref ref, final Mod mod) {
  final modPreviewPathRepoImpl = ModPreviewPathRepoImpl(
    fs: ref.watch(filesystemProvider),
    mod: mod,
  );
  ref.onDispose(modPreviewPathRepoImpl.dispose);
  return modPreviewPathRepoImpl;
}

@riverpod
IniPathsRepo iniPaths(final Ref ref, final Mod mod) {
  final modPreviewPathRepoImpl = IniPathsRepoImpl(
    fs: ref.watch(filesystemProvider),
    mod: mod,
  );
  ref.onDispose(modPreviewPathRepoImpl.dispose);
  return modPreviewPathRepoImpl;
}

abstract interface class IniPathsRepo {
  Stream<List<String>> get stream;
  Future<void> dispose();
}

class IniPathsRepoImpl implements IniPathsRepo {
  factory IniPathsRepoImpl({
    required final Filesystem fs,
    required final Mod mod,
  }) {
    final watcher = fs.watchDirectory(path: mod.path);
    final stream = watcher.stream.asyncMap(
      (final event) async => (await getUnder<File>(mod.path))
          .where((final e) => e.pExtension.pEquals('.ini') && e.pIsEnabled)
          .toList(),
    );
    return IniPathsRepoImpl._(
      watcher: watcher,
      stream: stream,
    );
  }
  IniPathsRepoImpl._({
    required this.watcher,
    required this.stream,
  });
  final Watcher watcher;
  @override
  final Stream<List<String>> stream;
  @override
  Future<void> dispose() async {
    await watcher.cancel();
  }
}
