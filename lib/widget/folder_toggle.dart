import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/provider/app_state.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class FolderToggle extends StatelessWidget {
  static const shaderFixes = PathString('ShaderFixes');
  static final Logger logger = Logger();

  final Widget child;
  final PathString dirPath;

  const FolderToggle({
    super.key,
    required this.child,
    required this.dirPath,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = dirPath.basename.isEnabled;
    return GestureDetector(
      onTap: () {
        if (isEnabled) {
          disable(context);
        } else {
          enable(context);
        }
      },
      child: child,
    );
  }

  void enable(BuildContext context) {
    final List<File> shaderFilenames = [];
    final dir = dirPath.toDirectory;
    final modShaderDir = dirPath.join(shaderFixes).toDirectory;
    try {
      shaderFilenames.addAll(getFilesUnder(modShaderDir));
    } on PathNotFoundException catch (e) {
      logger.i(e);
    }

    final PathString renameTarget =
        dir.parent.join(dirPath.basename.enabledForm);
    if (renameTarget.toDirectory.existsSync()) {
      showDirectoryExists(context, renameTarget);
      return;
    }
    final tgt =
        context.read<AppState>().targetDir.join(shaderFixes).toDirectory;
    try {
      copyShaders(tgt, shaderFilenames);
    } on FileSystemException catch (e) {
      logger.w(e);
      errorDialog(context, '${e.path} already exists!');
      return;
    }
    try {
      dir.renameSyncPath(renameTarget);
    } on PathAccessException {
      errorDialog(
          context,
          'Failed to rename folder.'
          ' Check if the ShaderFixes folder is open in explorer,'
          ' and close it if it is.');
      deleteShaders(tgt, shaderFilenames);
    }
  }

  void disable(BuildContext context) {
    final List<File> shaderFilenames = [];
    final dir = dirPath.toDirectory;
    final modShaderDir = dirPath.join(shaderFixes).toDirectory;
    try {
      shaderFilenames.addAll(getFilesUnder(modShaderDir));
    } on PathNotFoundException catch (e) {
      logger.i(e);
    }

    final PathString renameTarget =
        dir.parent.join(dirPath.basename.disabledForm);
    if (renameTarget.toDirectory.existsSync()) {
      showDirectoryExists(context, renameTarget);
      return;
    }
    final tgt =
        context.read<AppState>().targetDir.join(shaderFixes).toDirectory;
    try {
      deleteShaders(tgt, shaderFilenames);
    } catch (e) {
      logger.w(e);
      errorDialog(context, 'Failed to delete files in ShaderFixes');
      return;
    }
    try {
      dir.renameSyncPath(renameTarget);
    } on PathAccessException {
      errorDialog(
          context,
          'Failed to rename folder.'
          ' Check if the ShaderFixes folder is open in explorer,'
          ' and close it if it is.');
      copyShaders(tgt, shaderFilenames);
    }
  }

  void copyShaders(Directory targetDir, List<File> shaderFiles) {
    // check for existence first
    final targetDirFileList = getFilesUnder(targetDir);
    for (final em in shaderFiles) {
      final modFilename = em.basename;
      for (final et in targetDirFileList) {
        final tgtFilename = et.basename;
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

  void deleteShaders(Directory targetDir, List<File> shaderFilenames) {
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

  void showDirectoryExists(BuildContext context, PathString renameTarget) {
    renameTarget = renameTarget.basename;
    errorDialog(context, '$renameTarget directory already exists!');
  }

  void errorDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Error'),
        content: Text(text),
        actions: [
          FilledButton(
            child: const Text('Ok'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
