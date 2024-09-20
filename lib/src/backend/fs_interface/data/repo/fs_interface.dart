import 'dart:async';
import 'dart:io';

import '../../domain/helper/path_op_string.dart';
import '../../domain/repo/fs_interface.dart';

class FileSystemInterfaceImpl implements FileSystemInterface {
  @override
  List<String?>? iniEditorArgument;

  @override
  String get iconDirRoot =>
      Platform.resolvedExecutable.pDirname.pJoin('Resources');

  @override
  Directory iconDir(final String game) => Directory(iconDirRoot.pJoin(game));

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
    await Process.run('start', ['/b', '/d', pwd, '', ...arg], runInShell: true);
  }
}
