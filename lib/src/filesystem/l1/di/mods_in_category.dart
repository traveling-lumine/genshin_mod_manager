import 'dart:io';

import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import '../../../app_config/l0/entity/entries.dart';
import '../../../app_config/l1/di/app_config_facade.dart';
import '../../l0/entity/mod.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/fsops.dart';
import '../impl/path_op_string.dart';
import 'filesystem.dart';

part 'mods_in_category.g.dart';

@riverpod
Stream<List<Mod>> modsInCategory(final Ref ref, final ModCategory category) {
  final fs = ref.watch(filesystemProvider);
  final watcher = fs.watchDirectory(path: category.path);
  ref.onDispose(watcher.cancel);
  return watcher.stream
      .where((final event) => event is! FileSystemModifyEvent)
      .debounceTime(const Duration(milliseconds: 100))
      .asyncMap(
        (final _) async => (await getUnder<Directory>(category.path))
            .map(
              (final e) => Mod(
                path: e,
                displayName: e.pEnabledForm.pBasename,
                isEnabled: e.pIsEnabled,
                category: category,
              ),
            )
            .toList(),
      );
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
  return modsInCategory.whenData(
    (final value) => [
      ...(value
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
  );
}
