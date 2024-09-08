import 'dart:io';

import '../../../mod_writer/data/mod_writer.dart';
import '../../data/helper/copy_directory.dart';
import '../../data/helper/path_op_string.dart';
import '../entity/folder_move_result.dart';
import '../entity/setting_data.dart';

Future<FolderMoveResult> dragToImportUseCase(
  final Iterable<String> dropPaths,
  final String categoryPath,
  final DragImportType type,
) async {
  final result = FolderMoveResult();
  for (final path in dropPaths) {
    if (FileSystemEntity.isDirectorySync(path)) {
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
    } else if (FileSystemEntity.isFileSync(path) &&
        path.pExtension.pEquals('.zip')) {
      final content = File(path).readAsBytesSync();
      final writer = createModWriter(categoryPath: categoryPath);
      try {
        await writer(modName: path.pBNameWoExt, data: content);
      } on FileSystemException catch (e) {
        result.addError(e);
      }
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
