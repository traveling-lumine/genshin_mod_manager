import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app_config/l0/entity/entries.dart';
import '../../../app_config/l1/di/app_config_facade.dart';
import '../../l0/api/mods_in_category.dart';
import '../../l0/entity/mod.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/mods_in_category.dart';
import 'filesystem.dart';

part 'mods_in_category.g.dart';

@riverpod
ModsInCategory modsInCategory(final Ref ref, final ModCategory category) {
  final data = ModsInCategoryImpl(
    category: category,
    enabledModsFirst: ref.watch(
      appConfigFacadeProvider
          .select((final value) => value.obtainValue(showEnabledModsFirst)),
    ),
    fs: ref.watch(filesystemProvider),
  );
  ref.onDispose(data.dispose);
  return data;
}

@riverpod
Stream<List<Mod>> modsUnsortedInCategoryStream(
  final Ref ref,
  final ModCategory category,
) {
  final modsInCategory = ref.watch(modsInCategoryProvider(category));
  return modsInCategory.modsUnsorted;
}

@riverpod
Stream<List<Mod>> modsInCategoryStream(
  final Ref ref,
  final ModCategory category,
) {
  final modsInCategory = ref.watch(modsInCategoryProvider(category));
  return modsInCategory.mods;
}
