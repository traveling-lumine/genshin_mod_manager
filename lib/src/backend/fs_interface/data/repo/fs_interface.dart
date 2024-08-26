import 'dart:async';
import 'dart:io';

import '../../domain/repo/fs_interface.dart';
import '../helper/path_op_string.dart';

class FileSystemInterfaceImpl implements FileSystemInterface {
  @override
  List<String?>? iniEditorArgument;

  @override
  String get iconDirRoot =>
      Platform.resolvedExecutable.pDirname.pJoin('Resources');

  @override
  Directory iconDir(final String game) => Directory(iconDirRoot.pJoin(game));

  @override
  void copyFilenames(
    final Directory from,
    final Directory to,
    final List<String> filenames,
  ) {
    // iterate files in from directory,
    // find the ones in filenames,
    // copy to to directory
    final lowerFilenames = filenames.map((final e) => e.toLowerCase()).toSet();
    for (final file in from.listSync().whereType<File>()) {
      if (lowerFilenames.contains(file.path.pBNameWoExt.toLowerCase())) {
        // if file does not exist in to directory, copy
        final toFile = File(to.path.pJoin(file.path.pBasename));
        if (!toFile.existsSync()) {
          file.copySync(toFile.path);
        }
      }
    }
  }

  @override
  Future<void> openFolder(final String path) async {
    await Process.start('explorer', [path], runInShell: true);
  }

  @override
  Future<void> runProgram(final File program) async {
    final pwd = program.parent.path;
    final pName = program.path.pBasename;
    await Process.run('start', ['/b', '/d', pwd, '', pName], runInShell: true);
  }

  @override
  Future<void> runIniEdit(final File program) async {
    final pwd = program.parent.path;
    final pName = program.path.pBasename;
    final List<String> arg;
    final iniEditorArgument2 = iniEditorArgument;
    if (iniEditorArgument2 != null) {
      arg = iniEditorArgument2.map((final e) => e ?? pName).toList();
    } else {
      arg = [pName];
    }
    await Process.run(
      'start',
      ['/b', '/d', pwd, '', ...arg],
      runInShell: true,
    );
  }

  @override
  Future<void> openTerminal(final String path) async {
    await Process.run(
      'start',
      ['powershell'],
      workingDirectory: path,
      runInShell: true,
    );
  }

  @override
  String pJoin(
    final String part1,
    final String part2, [
    final String? part3,
    final String? part4,
    final String? part5,
    final String? part6,
    final String? part7,
    final String? part8,
    final String? part9,
    final String? part10,
    final String? part11,
    final String? part12,
    final String? part13,
    final String? part14,
    final String? part15,
    final String? part16,
  ]) =>
      part1.pJoin(
        part2,
        part3,
        part4,
        part5,
        part6,
        part7,
        part8,
        part9,
        part10,
        part11,
        part12,
        part13,
        part14,
        part15,
        part16,
      );
}
