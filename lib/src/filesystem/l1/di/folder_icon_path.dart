import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app_config/l0/entity/entries.dart';
import '../../../app_config/l1/di/app_config_facade.dart';
import '../../../app_config/l1/di/basic_path.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/folder_icon_path.dart';
import 'filesystem.dart';

part 'folder_icon_path.g.dart';

@riverpod
Stream<String?> folderIconPathStream(
  final Ref ref,
  final ModCategory category,
) {
  final repo = FolderIconPathImpl(
    basicPathProvider: ref.watch(basicPathProvider),
    currentGame: ref.watch(
      appConfigFacadeProvider
          .select((final value) => value.obtainValue(games).current!),
    ),
    fs: ref.watch(filesystemProvider),
    category: category,
  );
  ref.onDispose(repo.dispose);
  return repo.path;
}
