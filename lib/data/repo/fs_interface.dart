import 'dart:io';

import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/repo/fs_interface.dart';

class FileSystemInterfaceImpl implements FileSystemInterface {
  @override
  String get iconDirRoot =>
      Platform.resolvedExecutable.pDirname.pJoin('Resources');

  @override
  Directory iconDir(final String game) => Directory(iconDirRoot.pJoin(game));

  @override
  void moveFilenames(
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
    // delete files in from directory
    for (final file in from.listSync().whereType<File>()) {
      file.deleteSync();
    }
  }
}