import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app_config/l1/di/app_config_facade.dart';
import '../../../app_config/l1/entity/entries.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/folder_icon.dart';
import 'filesystem.dart';

part 'fs_watcher.g.dart';

@riverpod
Stream<String?> folderIconPathStream(
  final Ref ref,
  final ModCategory category,
) {
  final fs = ref.watch(filesystemProvider);
  final currentGame = ref.watch(
    appConfigFacadeProvider
        .select((final value) => value.obtainValue(games).current!),
  );
  final iconDir = Directory(p.join('Resources', currentGame));
  final folderIconRepoImpl =
      FolderIconRepoImpl(fs: fs, iconDir: iconDir, category: category);
  ref.onDispose(folderIconRepoImpl.dispose);
  return folderIconRepoImpl.stream;
}
