import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/entity/mod.dart';
import '../l1/di/filesystem.dart';
import '../l1/impl/ini_paths.dart';
import '../l1/impl/mod_preview.dart';

part 'mod_card.g.dart';

@riverpod
Stream<String?> modPreviewPath(final Ref ref, final Mod mod) {
  final modPreviewPathRepoImpl = ModPreviewPathRepoImpl(
    fs: ref.watch(filesystemProvider),
    mod: mod,
  );
  ref.onDispose(modPreviewPathRepoImpl.dispose);
  return modPreviewPathRepoImpl.stream;
}

@riverpod
Stream<List<String>> iniPaths(final Ref ref, final Mod mod) {
  final modPreviewPathRepoImpl = IniPathsRepoImpl(
    fs: ref.watch(filesystemProvider),
    mod: mod,
  );
  ref.onDispose(modPreviewPathRepoImpl.dispose);
  return modPreviewPathRepoImpl.stream;
}
