import 'dart:io';

abstract interface class FileSystemInterface {
  String get iconDirRoot;

  Directory iconDir(final String game);

  Future<void> runIniEdit(final File program);

  List<String?>? iniEditorArgument;
}
