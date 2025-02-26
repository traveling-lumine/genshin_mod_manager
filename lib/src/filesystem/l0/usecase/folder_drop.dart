import '../api/filesystem.dart';
import '../entity/folder_move_result.dart';
import '../entity/mod_category.dart';

Future<List<ImportResult>> dragToImportUseCase({
  required final Iterable<String> dropPaths,
  required final ModCategory category,
  required final bool type,
  required final Filesystem fs,
}) =>
    Future.wait(
      dropPaths.map(
        (final e) => fs.importPath(
          targetPath: e,
          category: category,
          moveDir: type,
        ),
      ),
    );
