import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/entity/mod.dart';
import '../impl/mod_preview_path.dart';
import 'filesystem.dart';

part 'mod_preview_path.g.dart';

@riverpod
Stream<String?> modPreviewPath(final Ref ref, final Mod mod) {
  final watch = ModPreviewPathImpl(mod: mod, fs: ref.watch(filesystemProvider));
  ref.onDispose(watch.dispose);
  return watch.previewPath;
}
