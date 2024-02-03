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

  final List<File> shaderFilenames = [];
  try {
    shaderFilenames
        .addAll(getFilesUnder(modPathW.join(kShaderFixes).toDirectory));
  } on PathNotFoundException {
    // logger.i(e);
  }

  final modDir = modPathW.toDirectory;
  final PathW renameTarget = modDir.parent.join(modPathW.basename.enabledForm);
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
    modDir.renameSyncPath(renameTarget);
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

  final List<File> shaderFilenames = [];
  final modShaderDir = modPathW.join(kShaderFixes).toDirectory;
  try {
    shaderFilenames.addAll(getFilesUnder(modShaderDir));
  } on PathNotFoundException {
    // logger.i(e);
  }

  final modDir = modPathW.toDirectory;
  final PathW renameTarget = modDir.parent.join(modPathW.basename.disabledForm);
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
    modDir.renameSyncPath(renameTarget);
  } on PathAccessException {
    onModRenameFailed?.call();
    _copyShaders(shaderFixesDir, shaderFilenames);
  }
}

void _copyShaders(Directory targetDir, List<File> shaderFiles) {
  // check for existence first
  final targetDirFileList = getFilesUnder(targetDir);
  for (final src in shaderFiles) {
    final modFilename = src.basename;
    for (final dst in targetDirFileList) {
      final tgtFilename = dst.basename;
      if (tgtFilename == modFilename) {
        throw FileSystemException(
          'Target directory is not empty',
          tgtFilename.asString,
        );
      }
    }
  }
  for (final em in shaderFiles) {
    final modFilename = em.basename;
    final moveName = targetDir.join(modFilename);
    em.copySyncPath(moveName);
  }
}

void _deleteShaders(Directory targetDir, List<File> shaderFilenames) {
  final targetDirFileList = getFilesUnder(targetDir);
  for (final em in shaderFilenames) {
    final modFilename = em.basename;
    for (final et in targetDirFileList) {
      final tgtFilename = et.basename;
      if (tgtFilename == modFilename) {
        et.deleteSync();
      }
    }
  }
}
