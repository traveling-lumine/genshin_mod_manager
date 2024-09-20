import 'dart:io';

import '../../../fs_interface/helper/path_op_string.dart';
import '../../../fs_interface/repo/fs_interface.dart';
import '../repo/persistent_storage.dart';
import 'game_config.dart';

const _iniEditorArgKey = 'iniEditorArg';

void initializeIniEditorArgumentUseCase(
  final PersistentStorage storage,
  final FileSystemInterface interface,
) {
  final arg = storage.getString(_iniEditorArgKey);
  if (arg == null) {
    interface.iniEditorArgument = null;
    _copyIcons(storage, interface);
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
    _copyFilenames(
      iconDirRoot,
      iconDirGame,
      modRootSubDirs.map((final e) => e.path.pBasename).toList(),
    );
  }
}

void _copyFilenames(
  final Directory from,
  final Directory to,
  final List<String> filenames,
) {
  // iterate files in from directory,
  // find the ones in filenames,
  // copy to to directory
  final lowerFilenames = filenames.map((final e) => e.toLowerCase()).toSet();
  for (final file in from.listSync().whereType<File>()) {
    if (lowerFilenames.contains(file.path.pBNameWoExt.toLowerCase())) {
      // if file does not exist in to directory, copy
      final toFile = File(to.path.pJoin(file.path.pBasename));
      if (!toFile.existsSync()) {
        file.copySync(toFile.path);
      }
    }
  }
}
