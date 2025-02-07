import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../storage/di/storage.dart' as s;
import '../../storage/l0/api/persistent_storage.dart';
import '../../storage/l0/constants.dart';
import '../../storage/l0/usecase/game_config.dart';
import '../helper/path_op_string.dart';
import '../repo/fs_interface.dart';

part 'fs_interface.g.dart';

final _iniEditorArgKey = StorageAccessKey.iniEditorArg.name;

@riverpod
class FsInterface extends _$FsInterface {
  @override
  FileSystemInterface build() {
    final storage = ref.watch(s.persistentStorageProvider).requireValue;
    final fileSystemInterface = FileSystemInterface();
    final arg = storage.getString(_iniEditorArgKey);
    if (arg == null) {
      fileSystemInterface.iniEditorArgument = null;
      _copyIcons(storage, fileSystemInterface);
    } else {
      final replaced =
          arg.split(' ').map((final e) => e == '%0' ? null : e).toList();
      fileSystemInterface.iniEditorArgument = replaced;
      _copyIcons(storage, fileSystemInterface);
    }
    return fileSystemInterface;
  }

  void setIniEditorArgument(final String? arg) {
    final storage = ref.read(s.persistentStorageProvider).requireValue;
    if (arg == null) {
      state.iniEditorArgument = null;
      storage.removeKey(_iniEditorArgKey);
    } else {
      storage.setString(_iniEditorArgKey, arg);
      final replaced =
          arg.split(' ').map((final e) => e == '%0' ? null : e).toList();
      state.iniEditorArgument = replaced;
    }
  }
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
