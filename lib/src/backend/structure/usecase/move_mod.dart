import 'dart:io';

import '../../fs_interface/data/helper/path_op_string.dart';
import '../../fs_interface/domain/usecase/move_dir.dart';
import '../entity/mod.dart';
import '../entity/mod_category.dart';

void moveModUseCase({
  required final Mod mod,
  required final ModCategory category,
}) {
  moveDirUseCase(
    Directory(mod.path),
    category.path.pJoin(mod.displayName),
  );
}
