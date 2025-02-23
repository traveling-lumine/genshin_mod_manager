import '../api/filesystem.dart';
import '../entity/folder_move_result.dart';

Future<List<ImportResult>> dragToImportUseCase({
  required final Iterable<String> dropPaths,
  required final String categoryPath,
  required final bool type,
  required final Filesystem fs,
}) =>
    Future.wait(
      dropPaths.map(
        (final e) => fs.importPath(
          dropPath: e,
          categoryPath: categoryPath,
          moveDir: type,
        ),
      ),
    );
