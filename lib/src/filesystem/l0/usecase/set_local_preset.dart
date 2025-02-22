import 'dart:async';
import '../../../app_config/l0/entity/game_config.dart';
import '../../l1/impl/mod_switcher.dart';
import '../../l1/impl/path_op_string.dart';
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
  final shaderFixes = gameConfig.modExecFile?.pDirname.pJoin(kShaderFixes);
  final currentEnabled = await fs.getSubDirNames(
    path: category.path,
    onlyEnabled: true,
  );
  final shouldBeOff =
      currentEnabled.where((final e) => !directives.contains(e));
  final futures = <Future<void>>[];
  for (final mod in shouldBeOff) {
    final modDir = category.path.pJoin(mod);
    final future = disable(shaderFixesPath: shaderFixes, modPath: modDir);
    futures.add(future);
  }
  final shouldBeOn = directives.where((final e) => !currentEnabled.contains(e));
  for (final mod in shouldBeOn) {
    final modDir = category.path.pJoin(mod.pDisabledForm);
    final future = enable(shaderFixesPath: shaderFixes, modPath: modDir);
    futures.add(future);
  }
  await Future.wait(futures);
}
