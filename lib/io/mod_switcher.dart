import 'dart:io';

import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';

const kShaderFixes = PathW('ShaderFixes');

void enable({
  required Directory shaderFixesDir,
  required PathW modPathW,
  void Function(PathW)? onModRenameClash,
  void Function(FileSystemException)? onShaderExists,
  void Function()? onModRenameFailed,
}) {
  if (!modPathW.toDirectory.existsSync()) return;

  List<File> shaderFilenames = _getModShaders(modPathW);
  final PathW renameTarget =
      modPathW.dirname.join(modPathW.basename.enabledForm);
  if (renameTarget.toDirectory.existsSync()) {
    onModRenameClash?.call(renameTarget);
    return;
  }
  try {
    _copyShaders(shaderFixesDir, shaderFilenames);
  } on FileSystemException catch (e) {
    onShaderExists?.call(e);
    return;
  }
  try {
    modPathW.toDirectory.renameSyncPath(renameTarget);
  } on PathAccessException {
    onModRenameFailed?.call();
    _deleteShaders(shaderFixesDir, shaderFilenames);
  }
}

void disable({
  required Directory shaderFixesDir,
  required PathW modPathW,
  void Function(PathW)? onModRenameClash,
  void Function(Object)? onShaderDeleteFailed,
  void Function()? onModRenameFailed,
}) {
  if (!modPathW.toDirectory.existsSync()) return;

  List<File> shaderFilenames = _getModShaders(modPathW);
  final PathW renameTarget =
      modPathW.dirname.join(modPathW.basename.disabledForm);
  if (renameTarget.toDirectory.existsSync()) {
    onModRenameClash?.call(renameTarget);
    return;
  }
  try {
    _deleteShaders(shaderFixesDir, shaderFilenames);
  } catch (e) {
    onShaderDeleteFailed?.call(e);
    return;
  }
  try {
    modPathW.toDirectory.renameSyncPath(renameTarget);
  } on PathAccessException {
    onModRenameFailed?.call();
    _copyShaders(shaderFixesDir, shaderFilenames);
  }
}

List<File> _getModShaders(PathW modPathW) {
  final List<File> shaderFilenames = [];
  final modShaderDir = modPathW.join(kShaderFixes).toDirectory;
  try {
    shaderFilenames.addAll(getFilesUnder(modShaderDir));
  } on PathNotFoundException {
    // _logger.i(e);
  }
  return shaderFilenames;
}

void _copyShaders(Directory targetDir, List<File> shaderFiles) {
  // check for existence first
  _shaderFinder(
    targetDir,
    shaderFiles,
    (found) => throw FileSystemException(
      'Target directory is not empty',
      found.pathW.basename.asString,
    ),
  );

  for (final elem in shaderFiles) {
    final modFilename = elem.pathW.basename;
    final moveName = targetDir.pathW.join(modFilename);
    elem.copySyncPath(moveName);
  }
}

void _deleteShaders(Directory targetDir, List<File> shaderFiles) {
  _shaderFinder(targetDir, shaderFiles, (found) => found.deleteSync());
}

void _shaderFinder(
  Directory targetDir,
  List<File> shaderFiles,
  void Function(File found) onFound,
) {
  final programShadersMap = Map<PathW, File>.fromEntries(
    getFilesUnder(targetDir).map((e) => MapEntry(e.pathW.basename, e)),
  );
  final shaderSets = shaderFiles.map((e) => e.pathW.basename).toSet();
  final inter = programShadersMap.keys.toSet().intersection(shaderSets);
  for (final elem in inter) {
    final found = programShadersMap[elem]!;
    onFound(found);
  }
}
