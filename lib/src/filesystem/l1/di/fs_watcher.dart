import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/api/folder_icon.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/folder_icon.dart';
import 'filesystem.dart';

part 'fs_watcher.g.dart';

@riverpod
FolderIconRepo folderIconPath(final Ref ref, final String categoryName) {
  final fs = ref.watch(filesystemProvider);
  final category = ModCategory(path: '/f', name: categoryName);
  final folderIconRepoImpl =
      FolderIconRepoImpl(fs: fs, iconDir: Directory(''), category: category);
  ref.onDispose(folderIconRepoImpl.dispose);
  return folderIconRepoImpl;
}

@riverpod
Stream<String?> folderIconPathStream(
  final Ref ref,
  final String categoryName,
) =>
    ref.watch(folderIconPathProvider(categoryName)).stream;
