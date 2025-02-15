import 'dart:io';

import '../../l0/api/filesystem.dart';
import '../../l0/api/ini_paths.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/mod.dart';
import 'fsops.dart';
import 'path_op_string.dart';

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
    return IniPathsRepoImpl._(watcher: watcher, stream: stream);
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
