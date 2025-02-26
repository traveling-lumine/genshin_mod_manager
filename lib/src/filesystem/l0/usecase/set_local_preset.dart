import 'dart:async';
import '../../../app_config/l0/entity/game_config.dart';
import '../api/filesystem.dart';
import '../entity/mod_category.dart';

Future<void> setLocalPresetUseCase({
  required final GameConfig gameConfig,
  required final ModCategory category,
  required final String name,
  required final Filesystem fs,
}) async {
  final directives =
      gameConfig.presetData.local[category.name]?.bundledPresets[name]?.mods;
  if (directives == null) {
    return;
  }
  final currentEnabled = await fs.getSubDirNames(
    path: category.path,
    onlyEnabled: true,
  );
  final shouldBeOff =
      currentEnabled.where((final e) => !directives.contains(e));
  final futures = <Future<void>>[];
  for (final mod in shouldBeOff) {
    final future = fs.disableOf(
      gameConfig: gameConfig,
      modName: mod,
      category: category,
    );
    futures.add(future);
  }
  final shouldBeOn = directives.where((final e) => !currentEnabled.contains(e));
  for (final mod in shouldBeOn) {
    final future = fs.enableOf(
      gameConfig: gameConfig,
      category: category,
      modName: mod,
    );
    futures.add(future);
  }
  await Future.wait(futures);
}
