import 'dart:io';

abstract interface class FileSystemInterface {
  String get iconDirRoot;

  Directory iconDir(final String game);

  void moveFilenames(
    final Directory from,
    final Directory to,
    final List<String> filenames,
  );
}
