import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../fs_interface/di/fs_interface.dart';
import '../../l0/api/folder_icon.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/folder_icon.dart';
import 'filesystem.dart';

part 'fs_watcher.g.dart';

@riverpod
FolderIconRepo folderIconPath(final Ref ref, final String categoryName) {
  final fs = ref.watch(filesystemProvider);
  final fsi = ref.watch(fsInterfaceProvider);
  final category = ModCategory(path: fsi.iconDirRoot, name: categoryName);
  return FolderIconRepoImpl(
    fs: fs,
    fsi: fsi,
    category: category,
  );
}
