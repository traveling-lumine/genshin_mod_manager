import 'dart:io';

abstract interface class FileSystemInterface {
  String get iconDirRoot;

  Directory iconDir(final String game);

  void copyFilenames(
    final Directory from,
    final Directory to,
    final List<String> filenames,
  );

  Future<void> openFolder(final String path);

  Future<void> runProgram(final File program);
}
