import 'dart:async';

import 'package:genshin_mod_manager/data/repo/fs_watcher.dart';
import 'package:genshin_mod_manager/di/app_state.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category.g.dart';

@riverpod
Stream<List<Mod>> categoryWatcher(
  final CategoryWatcherRef ref,
  final ModCategory category,
) {
  final enabledModsFirst = ref.watch(enabledFirstProvider);
  final categoryModel =
      CategoryModel(enabledFirst: enabledModsFirst, category: category);
  ref.onDispose(categoryModel.dispose);
  return categoryModel.mods;
}
