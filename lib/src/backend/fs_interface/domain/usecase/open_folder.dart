import 'dart:io';

Future<void> openFolderUseCase(final String path) async {
  await Process.start('explorer', [path], runInShell: true);
}
