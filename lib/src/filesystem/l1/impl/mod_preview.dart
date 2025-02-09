import 'dart:io';

import '../../l0/api/filesystem.dart';
import '../../l0/api/mod_preview.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/mod.dart';
import 'fsops.dart';

class ModPreviewPathRepoImpl implements ModPreviewPathRepo {
  factory ModPreviewPathRepoImpl({
    required final Filesystem fs,
    required final Mod mod,
  }) {
    final watcher = fs.watchDirectory(path: mod.path);
    final stream = watcher.stream.asyncMap(
      (final event) async =>
          findPreviewFileInString(await getUnder<File>(mod.path)),
    );
    return ModPreviewPathRepoImpl._(
      watcher: watcher,
      stream: stream,
    );
  }

  ModPreviewPathRepoImpl._({
    required this.watcher,
    required this.stream,
  });

  @override
  Stream<String?> stream;
  final Watcher watcher;

  @override
  Future<void> dispose() => watcher.cancel();
}
