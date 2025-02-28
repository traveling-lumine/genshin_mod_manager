import 'dart:async';

import '../../../app_config/l0/entity/game_config.dart';
import '../../../app_config/l0/entity/preset.dart';
import '../api/filesystem.dart';
import '../api/mod_toggler.dart';

Future<void> setGlobalPresetUseCase({
  required final GameConfig gameConfig,
  required final String name,
  required final Filesystem fs,
  required final ModToggler tg,
}) async {
  final data = gameConfig.presetData.global[name];
  if (data == null) {
    return;
  }
  final latest2 = gameConfig.modRoot;
  if (latest2 == null) {
    return;
  }
  for (final MapEntry(key: categoryName, value: PresetList(mods: modsToEnable))
      in data.bundledPresets.entries) {
    final currentEnabled = await fs.getSubDirNamesOf(
      path: latest2,
      pJoin: categoryName,
      onlyEnabled: true,
    );
    final shouldBeOff =
        currentEnabled.where((final e) => !modsToEnable.contains(e));
    final futures = <Future<void>>[];
    for (final mod in shouldBeOff) {
      final future = tg.disableDirect(
        gameConfig: gameConfig,
        categoryName: categoryName,
        modName: mod,
      );
      futures.add(future);
    }
    final shouldBeOn =
        modsToEnable.where((final e) => !currentEnabled.contains(e));
    for (final mod in shouldBeOn) {
      final future = tg.enableDirect(
        gameConfig: gameConfig,
        categoryName: categoryName,
        modName: mod,
      );
      futures.add(future);
    }
    await Future.wait(futures);
  }
}
