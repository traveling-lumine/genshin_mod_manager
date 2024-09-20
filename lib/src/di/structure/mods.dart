import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../backend/structure/entity/mod.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../../backend/structure/usecase/collect_mods.dart';
import '../app_state/display_enabled_mods_first.dart';
import '../fs_watcher.dart';

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
