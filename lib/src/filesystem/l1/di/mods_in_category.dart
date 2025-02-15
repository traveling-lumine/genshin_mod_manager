import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app_config/l0/entity/entries.dart';
import '../../../app_config/l1/di/app_config_facade.dart';
import '../../l0/entity/mod.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/mods_in_category.dart';
import 'filesystem.dart';

part 'mods_in_category.g.dart';

@riverpod
Stream<List<Mod>> modsInCategory(final Ref ref, final ModCategory category) {
  final data = ModsInCategoryImpl(
    category: category,
    fs: ref.watch(filesystemProvider),
  );
  ref.onDispose(data.dispose);
  return data.modsUnsorted;
}

@riverpod
AsyncValue<List<Mod>> modsInCategorySorted(
  final Ref ref,
  final ModCategory category,
) {
  final modsInCategory = ref.watch(modsInCategoryProvider(category));
  final enabledModsFirst = ref.watch(
    appConfigFacadeProvider
        .select((final value) => value.obtainValue(showEnabledModsFirst)),
  );
  final map = modsInCategory.map(
    data: (final event) => AsyncData(
      [
        ...(event.value
          ..sort((final a, final b) {
            if (enabledModsFirst) {
              final aEnabled = a.isEnabled;
              final bEnabled = b.isEnabled;
              if (aEnabled && !bEnabled) {
                return -1;
              } else if (!aEnabled && bEnabled) {
                return 1;
              }
            }
            return compareNatural(a.displayName, b.displayName);
          })),
      ],
    ),
    error: (final error) => error,
    loading: (final loading) => loading,
  );
  return map;
}
