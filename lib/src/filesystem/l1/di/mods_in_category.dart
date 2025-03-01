import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/entity/mod.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/mods_in_category.dart';
import 'watcher.dart';

part 'mods_in_category.g.dart';

@riverpod
Stream<List<Mod>> modsInCategory(final Ref ref, final ModCategory category) {
  final dWatch = ref.watch(directoryWatchProvider(category.path));
  final watcher = ModsInCategoryImpl(category: category, watcher: dWatch);
  ref.onDispose(watcher.dispose);
  return watcher.modsInCategory;
}
