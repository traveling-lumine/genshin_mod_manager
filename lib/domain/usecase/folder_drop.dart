import 'dart:io';

import '../../data/helper/copy_directory.dart';
import '../../data/helper/path_op_string.dart';
import '../entity/folder_move_result.dart';
import '../entity/setting_data.dart';

FolderMoveResult dragToImportUseCase(
  final Iterable<String> dropPaths,
  final String categoryPath,
  final DragImportType type,
) {
  final result = FolderMoveResult();
  for (final path in dropPaths) {
    if (!FileSystemEntity.isDirectorySync(path)) {
      continue;
    }
    final newPath = categoryPath.pJoin(path.pBasename);
    if (FileSystemEntity.isDirectorySync(newPath)) {
      result.addExists(path.pBasename, newPath.pBasename);
      continue;
    }

    final sourceDir = Directory(path);
    switch (type) {
      case DragImportType.move:
        try {
          _moveDir(sourceDir, newPath, result);
        } on FileSystemException catch (e) {
          result.addError(e);
        }
      case DragImportType.copy:
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
      rethrow;
    }
  }
}
