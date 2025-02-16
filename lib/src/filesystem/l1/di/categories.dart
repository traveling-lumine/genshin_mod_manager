import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app_config/l0/entity/entries.dart';
import '../../../app_config/l1/di/app_config_facade.dart';
import '../../l0/entity/mod_category.dart';
import '../helper/sort_natural.dart';
import '../impl/fsops.dart';
import '../impl/path_op_string.dart';
import 'filesystem.dart';

part 'categories.g.dart';

@riverpod
Stream<List<ModCategory>> categories(final Ref ref) {
  final modRoot = ref.watch(
    appConfigFacadeProvider.select(
      (final value) => value.obtainValue(games).currentGameConfig.modRoot,
    ),
  );
  if (modRoot == null) {
    return Stream.value(<ModCategory>[]);
  }

  final fs = ref.watch(filesystemProvider);
  final watch = fs.watchDirectory(path: modRoot);
  ref.onDispose(watch.cancel);

  return watch.stream.asyncMap(
    (final event) async => (await getUnder<Directory>(modRoot))
        .map((final e) => ModCategory(path: e, name: e.pBasename))
        .toList()
        .sortNatural(by: (final e) => e.name),
  );
}
