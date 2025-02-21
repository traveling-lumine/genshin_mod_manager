import 'dart:async';
import '../../../app_config/l0/entity/game_config.dart';
import '../../../app_config/l0/entity/preset.dart';
import '../../l1/impl/mod_switcher.dart';
import '../../l1/impl/path_op_string.dart';
import '../api/filesystem.dart';

Future<void> setGlobalPresetUseCase({
  required final GameConfig currentGameConfig2,
  required final String name,
  required final Filesystem fs,
}) async {
  final data = currentGameConfig2.presetData.global[name];
  if (data == null) {
    return;
  }
  final latest2 = currentGameConfig2.modRoot;
  if (latest2 == null) {
    return;
  }
  final shaderFixes =
      currentGameConfig2.modExecFile?.pDirname.pJoin(kShaderFixes);
  for (final MapEntry(key: categoryName, value: PresetList(mods: modsToEnable))
      in data.bundledPresets.entries) {
    final categoryDir = latest2.pJoin(categoryName);
    final currentEnabled = await fs.getSubDirNames(
      path: categoryDir,
      onlyEnabled: true,
    );
    final shouldBeOff =
        currentEnabled.where((final e) => !modsToEnable.contains(e));
    final futures = <Future<void>>[];
    for (final mod in shouldBeOff) {
      final modDir = categoryDir.pJoin(mod);
      final future = disable(shaderFixesPath: shaderFixes, modPath: modDir);
      futures.add(future);
    }
    final shouldBeOn =
        modsToEnable.where((final e) => !currentEnabled.contains(e));
    for (final mod in shouldBeOn) {
      final modDir = categoryDir.pJoin(mod.pDisabledForm);
      final future = enable(shaderFixesPath: shaderFixes, modPath: modDir);
      futures.add(future);
    }
    await Future.wait(futures);
  }
}
