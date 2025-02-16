import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import '../../../app_config/l0/entity/entries.dart';
import '../../../app_config/l1/di/app_config_facade.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/fsops.dart';
import 'filesystem.dart';

part 'fs_watcher.g.dart';

@riverpod
Stream<String?> folderIconPathStream(
  final Ref ref,
  final ModCategory category,
) {
  final currentGame = ref.watch(
    appConfigFacadeProvider
        .select((final value) => value.obtainValue(games).current!),
  );
  final iconDir = Directory(p.join(
      File(Platform.resolvedExecutable).parent.path, 'Resources', currentGame,),);
  final path = (iconDir..createSync(recursive: true)).path;

  final fs = ref.watch(filesystemProvider);
  final watcher = fs.watchFile(path: path);
  ref.onDispose(watcher.cancel);

  return watcher.stream
      .debounceTime(const Duration(milliseconds: 100))
      .asyncMap(
        (final event) async => findPreviewFileInString(
          await getUnder<File>(path),
          name: category.name,
        ),
      );
}
