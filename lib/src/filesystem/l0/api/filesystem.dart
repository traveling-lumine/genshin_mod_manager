import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../app_config/l0/entity/game_config.dart';
import '../entity/folder_move_result.dart';
import '../entity/ini.dart';
import '../entity/mod.dart';
import '../entity/mod_category.dart';
import '../entity/mod_toggle_result.dart';
import 'watcher.dart';

abstract interface class Filesystem {
  Future<ModToggleResult> disable({
    required final GameConfig currentGameConfig2,
    required final String modPath,
  });
  Future<ModToggleResult> disableDirect({
    required final GameConfig currentGameConfig2,
    required final String modRootPath,
    required final String categoryName,
    required final String modName,
  });

  Future<ModToggleResult> disableOf({
    required final GameConfig currentGameConfig2,
    required final ModCategory category,
    required final String modName,
  });

  Future<void> dispose();

  Future<ModToggleResult> enable({
    required final GameConfig currentGameConfig2,
    required final String modPath,
  });

  Future<ModToggleResult> enableDirect({
    required final GameConfig currentGameConfig2,
    required final String modRootPath,
    required final String categoryName,
    required final String modName,
  });

  Future<ModToggleResult> enableOf({
    required final GameConfig currentGameConfig2,
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
    required final String dropPath,
    required final String categoryPath,
    required final bool moveDir,
  });

  Future<ImportResult> importZipFile(
    final String categoryPath,
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

  void moveDir(final Directory sourceDir, final String newPath);

  void moveDirOf({
    required final Directory sourceDir,
    required final ModCategory category,
    required final Mod mod,
  });

  Future<void> newMethod(final Mod mod, final Uint8List bytes);

  Future<ProcessResult> newMethod2(
    final String iniPath,
    final String? obtainValue,
  );

  Future<void> pauseAllWatchers();

  void resumeAllWatchers();

  Watcher watchDirectory({
    required final String path,
  });

  Watcher watchFile({
    required final String path,
  });
}
