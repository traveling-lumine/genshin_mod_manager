import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../app_config/l0/entity/game_config.dart';
import '../../l0/api/mod_toggler.dart';
import '../../l0/entity/mod.dart';
import '../../l0/entity/mod_category.dart';
import '../../l0/entity/mod_toggle_result.dart';
import '../helper.dart';

const _disabledHeader = 'DISABLED';
const _kShaderFixes = 'ShaderFixes';

Future<void> _copyShaders(
  final String targetPath,
  final List<String> shaderPaths,
) async {
  // check for existence first
  await _shaderFinder(
    targetPath,
    shaderPaths,
    (final found) => throw FileSystemException(
      'Target directory is not empty',
      p.basename(found),
    ),
  );
  final futures = <Future<File>>[];
  for (final elem in shaderPaths) {
    final modFilename = p.basename(elem);
    final moveName = p.join(
      targetPath,
      modFilename,
    );
    futures.add(File(elem).copy(moveName));
  }
  await Future.wait(futures);
}

Future<void> _deleteShaders(
  final String targetPath,
  final List<String> shaderPaths,
) async {
  await _shaderFinder(
    targetPath,
    shaderPaths,
    (final found) => Future(() => File(found).deleteSync()),
  );
}

Future<ModToggleResult> _disable({
  required final GameConfig gameConfig,
  required final String modPath,
}) async {
  if (!Directory(modPath).existsSync()) {
    return const ModToggleResult.modNotFound();
  }
  if (!modPath.pIsEnabled) {
    return const ModToggleResult.alreadyDisabled();
  }
  final renameTarget = modPath.pDisabledForm;
  if (Directory(renameTarget).existsSync()) {
    return ModToggleResult.modRenameClash(p.basename(renameTarget));
  }
  try {
    await Directory(modPath).rename(renameTarget);
  } on PathAccessException {
    return const ModToggleResult.modRenameFailed();
  }
  final modShaderPath = p.join(
    renameTarget,
    _kShaderFixes,
  );
  final List<String> shaderFilenames;
  try {
    shaderFilenames = await pathsUnder<File>(modShaderPath);
  } on PathNotFoundException {
    return const ModToggleResult.modHasNoShaders();
  }
  final modExecFile = gameConfig.modExecFile;
  final shaderFixesPath = modExecFile != null
      ? p.join(
          p.dirname(modExecFile),
          _kShaderFixes,
        )
      : null;
  if (shaderFixesPath == null) {
    return const ModToggleResult.done();
  }
  try {
    await _deleteShaders(shaderFixesPath, shaderFilenames);
  } on FileSystemException {
    try {
      await _copyShaders(shaderFixesPath, shaderFilenames);
    } on FileSystemException {
      return const ModToggleResult.shaderCleanupFailed();
    }
    return const ModToggleResult.shaderDeleteFailed();
  }
  return const ModToggleResult.done();
}

Future<ModToggleResult> _enable({
  required final GameConfig gameConfig,
  required final String modPath,
}) async {
  if (!Directory(modPath).existsSync()) {
    return const ModToggleResult.modNotFound();
  }
  if (modPath.pIsEnabled) {
    return const ModToggleResult.alreadyEnabled();
  }
  final renameTarget = modPath.pEnabledForm;
  if (Directory(renameTarget).existsSync()) {
    return ModToggleResult.modRenameClash(p.basename(renameTarget));
  }
  try {
    await Directory(modPath).rename(renameTarget);
  } on PathAccessException {
    return const ModToggleResult.modRenameFailed();
  }
  final modShaderPath = p.join(
    renameTarget,
    _kShaderFixes,
  );
  final List<String> shaderFilenames;
  try {
    shaderFilenames = await pathsUnder<File>(modShaderPath);
  } on PathNotFoundException {
    return const ModToggleResult.modHasNoShaders();
  }
  final modExecFile = gameConfig.modExecFile;
  final shaderFixesPath = modExecFile != null
      ? p.join(
          p.dirname(modExecFile),
          _kShaderFixes,
        )
      : null;
  if (shaderFixesPath == null) {
    return const ModToggleResult.done();
  }
  try {
    await _copyShaders(shaderFixesPath, shaderFilenames);
  } on FileSystemException {
    try {
      await _deleteShaders(shaderFixesPath, shaderFilenames);
    } on FileSystemException {
      return const ModToggleResult.shaderCleanupFailed();
    }
    return const ModToggleResult.shaderCopyFailed();
  }
  return const ModToggleResult.done();
}

Future<void> _shaderFinder(
  final String targetPath,
  final List<String> shaderPaths,
  final Future<void> Function(String foundPath) onFound,
) async {
  final list = await pathsUnder<File>(targetPath);
  final programShadersMap = {for (final e in list) p.basename(e): e};
  final shaderSets = shaderPaths.map(p.basename).toSet();
  final inter = programShadersMap.keys.toSet().intersection(shaderSets);
  final futures = inter.map((final elem) => onFound(programShadersMap[elem]!));
  await Future.wait(futures);
}

class ModTogglerImpl implements ModToggler {
  @override
  Future<ModToggleResult> disableDirect({
    required final GameConfig gameConfig,
    required final String categoryName,
    required final String modName,
  }) =>
      _disable(
        gameConfig: gameConfig,
        modPath: p.join(
          gameConfig.modRoot!,
          categoryName,
          modName,
        ),
      );
  @override
  Future<ModToggleResult> disableMod({
    required final GameConfig gameConfig,
    required final Mod mod,
  }) =>
      _disable(gameConfig: gameConfig, modPath: mod.path);
  @override
  Future<ModToggleResult> disableOf({
    required final GameConfig gameConfig,
    required final ModCategory category,
    required final String modName,
  }) =>
      _disable(
        gameConfig: gameConfig,
        modPath: p.join(
          category.path,
          modName,
        ),
      );

  @override
  Future<ModToggleResult> enableDirect({
    required final GameConfig gameConfig,
    required final String categoryName,
    required final String modName,
  }) =>
      _enable(
        gameConfig: gameConfig,
        modPath: p.join(
          gameConfig.modRoot!,
          categoryName,
          modName.pDisabledForm,
        ),
      );
  @override
  Future<ModToggleResult> enableMod({
    required final GameConfig gameConfig,
    required final Mod mod,
  }) =>
      _enable(gameConfig: gameConfig, modPath: mod.path);
  @override
  Future<ModToggleResult> enableOf({
    required final GameConfig gameConfig,
    required final ModCategory category,
    required final String modName,
  }) =>
      _enable(
        gameConfig: gameConfig,
        modPath: p.join(
          category.path,
          modName.pDisabledForm,
        ),
      );
}

extension _PathOpString on String {
  String get pDisabledForm {
    var baseName = p.basename(this);
    if (baseName.pIsEnabled) {
      baseName = '$_disabledHeader ${baseName.trimLeft()}';
    }
    if (p.split(this).length == 1) {
      return baseName;
    } else {
      return p.join(
        p.dirname(this),
        baseName,
      );
    }
  }

  String get pEnabledForm {
    var baseName = p.basename(this);
    while (!baseName.pIsEnabled) {
      baseName = baseName.substring(_disabledHeader.length).trimLeft();
    }
    if (p.split(this).length == 1) {
      return baseName;
    } else {
      return p.join(
        p.dirname(this),
        baseName,
      );
    }
  }

  bool get pIsEnabled =>
      !p.basename(this).toLowerCase().startsWith(_disabledHeader.toLowerCase());
}
