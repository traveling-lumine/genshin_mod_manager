import 'dart:io';

import 'package:genshin_mod_manager/data/helper/copy_directory.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/folder_move_result.dart';

FolderMoveResult dragToMoveUseCase(
  final Iterable<String> dropPaths,
  final String categoryPath,
  final bool moveInsteadOfCopy,
) {
  final result = FolderMoveResult();
  for (final path in dropPaths) {
    if (!FileSystemEntity.isDirectorySync(path)) {
      continue;
    }
    final newPath = categoryPath.pJoin(path.pBasename);
    if (FileSystemEntity.isDirectorySync(newPath)) {
      result.addExists(path, newPath);
      continue;
    }

    final sourceDir = Directory(path);
    if (moveInsteadOfCopy) {
      _moveDir(sourceDir, newPath, result);
    } else {
      sourceDir.copyToPath(newPath);
    }
  }
  return result;
}

void _moveDir(
  final Directory sourceDir,
  final String newPath,
  final FolderMoveResult result,
) {
  try {
    sourceDir.renameSync(newPath);
  } on FileSystemException catch (e) {
    if (e.osError?.errorCode == 17) {
      // Moving across different drives
      sourceDir
        ..copyToPath(newPath)
        ..deleteSync(recursive: true);
    } else {
      result.addError(e);
    }
  }
}
