import 'dart:async';
import 'dart:io';

import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';

/// ShaderFixes directory name.
const kShaderFixes = 'ShaderFixes';

/// Enables a mod.
Future<void> enable({
  required final String shaderFixesPath,
  required final String modPath,
  final void Function(String)? onModRenameClash,
  final void Function(FileSystemException)? onShaderExists,
  final void Function()? onModRenameFailed,
}) async {
  if (!Directory(modPath).existsSync()) {
    return;
  }

  final shaderFilenames = await _getModShaders(modPath);
  final renameTarget = modPath.pEnabledForm;
  if (Directory(renameTarget).existsSync()) {
    onModRenameClash?.call(renameTarget);
    return;
  }
  try {
    await _copyShaders(shaderFixesPath, shaderFilenames);
  } on FileSystemException catch (e) {
    onShaderExists?.call(e);
    return;
  }
  try {
    Directory(modPath).renameSync(renameTarget);
  } on PathAccessException {
    onModRenameFailed?.call();
    await _deleteShaders(shaderFixesPath, shaderFilenames);
  }
}

/// Disables a mod.
Future<void> disable({
  required final String shaderFixesPath,
  required final String modPath,
  final void Function(String)? onModRenameClash,
  final void Function(Object)? onShaderDeleteFailed,
  final void Function()? onModRenameFailed,
}) async {
  if (!Directory(modPath).existsSync()) {
    return;
  }

  final shaderFilenames = await _getModShaders(modPath);
  final renameTarget = modPath.pDisabledForm;
  if (Directory(renameTarget).existsSync()) {
    onModRenameClash?.call(renameTarget);
    return;
  }
  try {
    await _deleteShaders(shaderFixesPath, shaderFilenames);
  } on FileSystemException catch (e) {
    onShaderDeleteFailed?.call(e);
    return;
  }
  try {
    Directory(modPath).renameSync(renameTarget);
  } on PathAccessException {
    onModRenameFailed?.call();
    await _copyShaders(shaderFixesPath, shaderFilenames);
  }
}

Future<List<String>> _getModShaders(final String modPath) async {
  final shaderPaths = <String>[];
  final modShaderPath = modPath.pJoin(kShaderFixes);
  try {
    final fseUnder = getUnder<File>(modShaderPath);
    shaderPaths.addAll(fseUnder);
  } on PathNotFoundException {
    // _logger.i(e);
  }
  return shaderPaths;
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
    getUnder<File>(targetPath).map((final e) => MapEntry(e.pBasename, e)),
  );
  final shaderSets = shaderPaths.map((final e) => e.pBasename).toSet();
  final inter = programShadersMap.keys.toSet().intersection(shaderSets);
  final futures = <Future<void>>[];
  for (final elem in inter) {
    final found = programShadersMap[elem]!;
    futures.add(onFound(found));
  }
  await Future.wait(futures);
}
