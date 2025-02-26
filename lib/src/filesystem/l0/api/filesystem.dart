import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../app_config/l0/entity/game_config.dart';
import '../entity/folder_move_result.dart';
import '../entity/ini.dart';
import '../entity/mod.dart';
import '../entity/mod_category.dart';
import '../entity/mod_toggle_result.dart';
import 'disposable.dart';
import 'watcher.dart';

abstract interface class Filesystem implements Disposable {
  Future<ModToggleResult> disableDirect({
    required final GameConfig gameConfig,
    required final String categoryName,
    required final String modName,
  });
  Future<ModToggleResult> disableMod({
    required final GameConfig gameConfig,
    required final Mod mod,
  });
  Future<ModToggleResult> disableOf({
    required final GameConfig gameConfig,
    required final ModCategory category,
    required final String modName,
  });

  Future<ModToggleResult> enableDirect({
    required final GameConfig gameConfig,
    required final String categoryName,
    required final String modName,
  });

  Future<ModToggleResult> enableMod({
    required final GameConfig gameConfig,
    required final Mod mod,
  });

  Future<ModToggleResult> enableOf({
    required final GameConfig gameConfig,
    required final ModCategory category,
    required final String modName,
  });

  Stream<List<ModCategory>> getCategories(
    final Stream<FileSystemEvent?> stream,
    final String modRoot,
  );

  Stream<String?> getFolderIconStream(
    final Stream<FileSystemEvent?> stream,
    final String path,
    final ModCategory category,
  );

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
