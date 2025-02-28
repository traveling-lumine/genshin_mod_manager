import 'dart:io';

import 'package:path/path.dart' as p;

import '../../l0/api/filesystem.dart';
import '../../l0/api/ini_paths.dart';
import '../../l0/entity/ini.dart';
import '../../l0/entity/mod.dart';
import '../helper.dart';

class IniPathsImpl implements IniPaths {
  factory IniPathsImpl({
    required final Mod mod,
    required final Filesystem fs,
  }) {
    final watcher = fs.watchDirectory(path: mod.path);

    return IniPathsImpl._(
      iniPaths: watcher.stream.asyncMap(
        (final event) async => (await pathsUnder<File>(mod.path))
            .where(
              (final e) => p.equals(p.extension(e), '.ini') && e.pIsEnabled,
            )
            .map(
              (final e) => IniFile(
                path: e,
                name: p.basename(e),
                mod: mod,
              ),
            )
            .toList(),
      ),
      onDispose: watcher.cancel,
    );
  }

  const IniPathsImpl._({
    required this.iniPaths,
    this.onDispose,
  });

  final Future<void> Function()? onDispose;

  @override
  final Stream<List<IniFile>> iniPaths;

  @override
  Future<void> dispose() async {
    await onDispose?.call();
  }
}
