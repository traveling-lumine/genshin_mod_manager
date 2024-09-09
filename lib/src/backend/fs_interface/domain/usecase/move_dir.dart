import 'dart:io';

import '../helper/copy_directory.dart';

void moveDirUseCase(
  final Directory sourceDir,
  final String newPath,
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
