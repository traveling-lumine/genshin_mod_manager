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

  Future<void> runIniEdit(final File program);

  List<String?>? iniEditorArgument;

  Future<void> openTerminal(final String path);

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
  ]);
}
