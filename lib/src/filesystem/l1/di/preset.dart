import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app_config/l0/entity/entries.dart';
import '../../../app_config/l1/di/app_config_facade.dart';
import '../../l0/entity/mod_category.dart';

part 'preset.g.dart';

@riverpod
List<String> globalPreset(final Ref ref) {
  final presetData = ref.watch(
    appConfigFacadeProvider.select(
      (final value) => value.obtainValue(games).currentGameConfig.presetData,
    ),
  );
  return presetData.global.keys.toList();
}

@riverpod
List<String> localPreset(final Ref ref, final ModCategory category) {
  final presetData = ref.watch(
    appConfigFacadeProvider.select(
      (final value) => value.obtainValue(games).currentGameConfig.presetData,
    ),
  );
  return presetData.local[category.name]?.bundledPresets.keys.toList() ?? [];
}
