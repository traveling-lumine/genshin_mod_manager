import 'dart:io';

import '../helper/path_op_string.dart';

class FileSystemInterface {
  List<String?>? iniEditorArgument;

  String get iconDirRoot =>
      Platform.resolvedExecutable.pDirname.pJoin('Resources');

  Directory iconDir(final String game) => Directory(iconDirRoot.pJoin(game));

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
