import 'dart:io';

import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';

const kShaderFixes = 'ShaderFixes';

void enable({
  required String shaderFixesPath,
  required String modPath,
  void Function(String)? onModRenameClash,
  void Function(FileSystemException)? onShaderExists,
  void Function()? onModRenameFailed,
}) {
  if (!Directory(modPath).existsSync()) return;

  List<File> shaderFilenames = _getModShaders(modPath);
  final String renameTarget =
      modPath.pDirname.pJoin(modPath.pBasename.pEnabledForm);
  if (Directory(renameTarget).existsSync()) {
    onModRenameClash?.call(renameTarget);
    return;
  }
  try {
    _copyShaders(shaderFixesPath, shaderFilenames);
  } on FileSystemException catch (e) {
    onShaderExists?.call(e);
    return;
  }
  try {
    Directory(modPath).renameSync(renameTarget);
  } on PathAccessException {
    onModRenameFailed?.call();
    _deleteShaders(shaderFixesPath, shaderFilenames);
  }
}

void disable({
  required String shaderFixesPath,
  required String modPathW,
  void Function(String)? onModRenameClash,
  void Function(Object)? onShaderDeleteFailed,
  void Function()? onModRenameFailed,
}) {
  if (!Directory(modPathW).existsSync()) return;

  List<File> shaderFilenames = _getModShaders(modPathW);
  final String renameTarget =
      modPathW.pDirname.pJoin(modPathW.pBasename.pDisabledForm);
  if (Directory(renameTarget).existsSync()) {
    onModRenameClash?.call(renameTarget);
    return;
  }
  try {
    _deleteShaders(shaderFixesPath, shaderFilenames);
  } catch (e) {
    onShaderDeleteFailed?.call(e);
    return;
  }
  try {
    Directory(modPathW).renameSync(renameTarget);
  } on PathAccessException {
    onModRenameFailed?.call();
    _copyShaders(shaderFixesPath, shaderFilenames);
  }
}

List<File> _getModShaders(String modPath) {
  final List<File> shaderFilenames = [];
  final modShaderPath = modPath.pJoin(kShaderFixes);
  try {
    shaderFilenames.addAll(getFilesUnder(modShaderPath));
  } on PathNotFoundException {
    // _logger.i(e);
  }
  return shaderFilenames;
}

void _copyShaders(String targetPath, List<File> shaderFiles) {
  // check for existence first
  _shaderFinder(
    targetPath,
    shaderFiles,
    (found) => throw FileSystemException(
      'Target directory is not empty',
      found.path.pBasename,
    ),
  );

  for (final elem in shaderFiles) {
    final modFilename = elem.path.pBasename;
    final moveName = targetPath.pJoin(modFilename);
    elem.copySync(moveName);
  }
}

void _deleteShaders(String targetPath, List<File> shaderFiles) {
  _shaderFinder(targetPath, shaderFiles, (found) => found.deleteSync());
}

void _shaderFinder(
  String targetPath,
  List<File> shaderFiles,
  void Function(File found) onFound,
) {
  final programShadersMap = Map<String, File>.fromEntries(
    getFilesUnder(targetPath).map((e) => MapEntry(e.path.pBasename, e)),
  );
  final shaderSets = shaderFiles.map((e) => e.path.pBasename).toSet();
  final inter = programShadersMap.keys.toSet().intersection(shaderSets);
  for (final elem in inter) {
    final found = programShadersMap[elem]!;
    onFound(found);
  }
}
