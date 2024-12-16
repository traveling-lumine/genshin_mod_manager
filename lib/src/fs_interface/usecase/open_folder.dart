import 'dart:io';

Future<Process> openFolderUseCase(final String path) =>
    Process.start('explorer', [path], runInShell: true);
