import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../app_config/l0/entity/game_config.dart';
import '../entity/folder_move_result.dart';
import '../entity/ini.dart';
import '../entity/mod.dart';
import '../entity/mod_category.dart';
import 'disposable.dart';
import 'watcher.dart';

abstract interface class Filesystem implements Disposable {
  Stream<List<Mod>> getModsInCategory(
    final Stream<FileSystemEvent?> stream,
    final ModCategory category,
  );

  Future<List<String>> getSubDirNames({
    required final String path,
    final bool onlyEnabled,
  });

  Future<List<String>> getSubDirNamesOf({
    required final String path,
    required final String pJoin,
    final bool onlyEnabled,
  });

  List<String> getUnavailableReasons(final GameConfig appState);

  Future<ImportResult> importPath({
    required final String targetPath,
    required final ModCategory category,
    required final bool moveDir,
  });

  Future<ImportResult> importZipFile(
    final ModCategory categoryPath,
    final String dropPath,
    final Uint8List content,
  );

  Stream<List<IniFile>> iniPathsStream(
    final Stream<FileSystemEvent?> stream,
    final Mod mod,
  );

  Stream<String?> modPreviewPathStream(
    final Stream<FileSystemEvent?> stream,
    final Mod mod,
  );

  Future<void> moveModInto({
    required final ModCategory category,
    required final Mod mod,
  });

  Future<void> pauseAllWatchers();

  void resumeAllWatchers();

  Future<ProcessResult> runProcess(
    final String iniPath,
    final String? obtainValue,
  );

  Watcher watchDirectory({
    required final String path,
  });

  Watcher watchFile({
    required final String path,
  });

  Future<void> writeImage(final Mod mod, final Uint8List bytes);
}
