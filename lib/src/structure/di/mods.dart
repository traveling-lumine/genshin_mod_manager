import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../fs_interface/di/fs_watcher.dart';
import '../../storage/di/display_enabled_mods_first.dart';
import '../entity/mod.dart';
import '../entity/mod_category.dart';
import '../usecase/collect_mods.dart';

part 'mods.g.dart';

@riverpod
List<Mod> modsInCategory(
  final ModsInCategoryRef ref,
  final ModCategory category,
) {
  final enabledModsFirst = ref.watch(displayEnabledModsFirstProvider);

  final watch = ref.watch(directoryInFolderProvider(category.path));
  final subscription = watch.listen((final event) => ref.invalidateSelf());
  ref.onDispose(subscription.cancel);

  return collectModUseCase(
    category: category,
    enabledModsFirst: enabledModsFirst,
  );
}
