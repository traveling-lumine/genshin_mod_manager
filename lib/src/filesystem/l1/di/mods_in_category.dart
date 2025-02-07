import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../storage/di/display_enabled_mods_first.dart';
import '../../l0/api/mods_in_category.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/mods_in_category.dart';
import 'filesystem.dart';

part 'mods_in_category.g.dart';

@riverpod
ModsInCategory modsInCategory(
  final Ref ref,
  final ModCategory category,
) {
  final data = ModsInCategoryImpl(
    category: category,
    enabledModsFirst: ref.watch(displayEnabledModsFirstProvider),
    fs: ref.watch(filesystemProvider),
  );
  ref.onDispose(data.dispose);
  return data;
}
