import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/entity/ini.dart';
import '../../l0/entity/mod.dart';
import '../impl/ini_paths.dart';
import 'filesystem.dart';

part 'ini_paths.g.dart';

@riverpod
Stream<List<IniFile>> iniPaths(final Ref ref, final Mod mod) {
  final watcher = IniPathsImpl(mod: mod, fs: ref.watch(filesystemProvider));
  ref.onDispose(watcher.dispose);
  return watcher.iniPaths;
}
