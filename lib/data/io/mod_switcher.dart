import 'dart:async';
import 'dart:io';

import 'package:genshin_mod_manager/data/extension/path_op_string.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';

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

  final List<File> shaderFilenames = await _getModShaders(modPath);
  final String renameTarget = modPath.pEnabledForm;
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
  required final String modPathW,
  final void Function(String)? onModRenameClash,
  final void Function(Object)? onShaderDeleteFailed,
  final void Function()? onModRenameFailed,
}) async {
  if (!Directory(modPathW).existsSync()) {
    return;
  }

  final List<File> shaderFilenames = await _getModShaders(modPathW);
  final String renameTarget = modPathW.pDisabledForm;
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
    Directory(modPathW).renameSync(renameTarget);
  } on PathAccessException {
    onModRenameFailed?.call();
    await _copyShaders(shaderFixesPath, shaderFilenames);
  }
}

Future<List<File>> _getModShaders(final String modPath) async {
  final List<File> shaderFilenames = [];
  final modShaderPath = modPath.pJoin(kShaderFixes);
  try {
    final fseUnder = await getUnder<File>(modShaderPath);
    shaderFilenames.addAll(fseUnder);
  } on PathNotFoundException {
    // _logger.i(e);
  }
  return shaderFilenames;
}

Future<void> _copyShaders(
  final String targetPath,
  final List<File> shaderFiles,
) async {
  // check for existence first
  await _shaderFinder(
    targetPath,
    shaderFiles,
    (final found) => throw FileSystemException(
      'Target directory is not empty',
      found.path.pBasename,
    ),
  );

  final futures = <Future<File>>[];
  for (final elem in shaderFiles) {
    final modFilename = elem.path.pBasename;
    final moveName = targetPath.pJoin(modFilename);
    futures.add(elem.copy(moveName));
  }
  await Future.wait(futures);
}

Future<void> _deleteShaders(
  final String targetPath,
  final List<File> shaderFiles,
) async {
  await _shaderFinder(
    targetPath,
    shaderFiles,
    (final found) => found.delete(),
  );
}

Future<void> _shaderFinder(
  final String targetPath,
  final List<File> shaderFiles,
  final Future<void> Function(File found) onFound,
) async {
  final programShadersMap = Map<String, File>.fromEntries(
    (await getUnder<File>(targetPath))
        .map((final e) => MapEntry(e.path.pBasename, e)),
  );
  final shaderSets = shaderFiles.map((final e) => e.path.pBasename).toSet();
  final inter = programShadersMap.keys.toSet().intersection(shaderSets);
  final futures = <Future<void>>[];
  for (final elem in inter) {
    final found = programShadersMap[elem]!;
    futures.add(onFound(found));
  }
  await Future.wait(futures);
}
