import 'dart:io';

import '../../domain/repo/folder_opener.dart';

FolderOpener folderOpener = (final path) async {
  await Process.start('explorer', [path], runInShell: true);
};
