import 'dart:async';
import 'dart:io';

import '../../l0/entity/mod_toggle_result.dart';
import 'fsops.dart';
import 'path_op_string.dart';

const kShaderFixes = 'ShaderFixes';

Future<ModToggleResult> disable({
  required final String? shaderFixesPath,
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
    return ModToggleResult.modRenameClash(renameTarget.pBasename);
  }
  try {
    await Directory(modPath).rename(renameTarget);
  } on PathAccessException {
    return const ModToggleResult.modRenameFailed();
  }

  final modShaderPath = renameTarget.pJoin(kShaderFixes);
  final List<String> shaderFilenames;
  try {
    shaderFilenames = await getUnder<File>(modShaderPath);
  } on PathNotFoundException {
    return const ModToggleResult.modHasNoShaders();
  }
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

Future<ModToggleResult> enable({
  required final String? shaderFixesPath,
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
    return ModToggleResult.modRenameClash(renameTarget.pBasename);
  }
  try {
    await Directory(modPath).rename(renameTarget);
  } on PathAccessException {
    return const ModToggleResult.modRenameFailed();
  }

  final modShaderPath = renameTarget.pJoin(kShaderFixes);
  final List<String> shaderFilenames;
  try {
    shaderFilenames = await getUnder<File>(modShaderPath);
  } on PathNotFoundException {
    return const ModToggleResult.modHasNoShaders();
  }
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
      found.pBasename,
    ),
  );

  final futures = <Future<File>>[];
  for (final elem in shaderPaths) {
    final modFilename = elem.pBasename;
    final moveName = targetPath.pJoin(modFilename);
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

Future<void> _shaderFinder(
  final String targetPath,
  final List<String> shaderPaths,
  final Future<void> Function(String foundPath) onFound,
) async {
  final programShadersMap = Map<String, String>.fromEntries(
    getUnderSync<File>(targetPath).map((final e) => MapEntry(e.pBasename, e)),
  );
  final shaderSets = shaderPaths.map((final e) => e.pBasename).toSet();
  final inter = programShadersMap.keys.toSet().intersection(shaderSets);
  final futures = inter.map((final elem) => onFound(programShadersMap[elem]!));
  await Future.wait(futures);
}
