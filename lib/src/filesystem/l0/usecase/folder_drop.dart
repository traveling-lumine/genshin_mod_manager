import 'dart:io';

import '../../../mod_writer/l1/mod_writer.dart';
import '../../l1/impl/copy_directory.dart';
import '../../l1/impl/path_op_string.dart';
import '../entity/folder_move_result.dart';
import 'move_dir.dart';

Future<FolderMoveResult> dragToImportUseCase(
  final Iterable<String> dropPaths,
  final String categoryPath,
  final bool type,
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
      if (type) {
        try {
          moveDirUseCase(sourceDir, newPath);
        } on FileSystemException catch (e) {
          result.addError(e);
        }
      } else {
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
