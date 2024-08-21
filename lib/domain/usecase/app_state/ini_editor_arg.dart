import 'dart:io';

import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/repo/fs_interface.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';
import 'package:genshin_mod_manager/domain/usecase/app_state/game_config.dart';

const _iniEditorArgKey = 'iniEditorArg';

void initializeIniEditorArgumentUseCase(
  final PersistentStorage storage,
  final FileSystemInterface interface,
) {
  final arg = storage.getString(_iniEditorArgKey);
  if (arg == null) {
    interface.iniEditorArgument = null;
    return;
  }
  final replaced =
      arg.split(' ').map((final e) => e == '%0' ? null : e).toList();
  interface.iniEditorArgument = replaced;
  _copyIcons(storage, interface);
}

void setIniEditorArgumentUseCase(
  final PersistentStorage storage,
  final FileSystemInterface interface,
  final String? arg,
) {
  if (arg == null) {
    interface.iniEditorArgument = null;
    storage.removeKey(_iniEditorArgKey);
    return;
  }
  storage.setString(_iniEditorArgKey, arg);
  final replaced =
      arg.split(' ').map((final e) => e == '%0' ? null : e).toList();
  interface.iniEditorArgument = replaced;
}

void _copyIcons(
  final PersistentStorage storage,
  final FileSystemInterface fsInterface,
) {
  final games = storage.getList('games');
  if (games == null) {
    return;
  }
  final iconDirRoot = Directory(fsInterface.iconDirRoot);
  for (final game in games) {
    final iconDirGame = fsInterface.iconDir(game);
    try {
      if (!iconDirGame.existsSync()) {
        iconDirGame.createSync(recursive: true);
      }
    } on Exception catch (_) {
      continue;
    }
    final modRoot = getModRootUseCase(storage, game);
    if (modRoot == null) {
      continue;
    }
    final modRootDir = Directory(modRoot);
    if (!modRootDir.existsSync()) {
      continue;
    }
    final modRootSubDirs = modRootDir.listSync().whereType<Directory>();
    fsInterface.copyFilenames(
      iconDirRoot,
      iconDirGame,
      modRootSubDirs.map((final e) => e.path.pBasename).toList(),
    );
  }
}
