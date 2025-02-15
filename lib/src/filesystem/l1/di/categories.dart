import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app_config/l0/entity/entries.dart';
import '../../../app_config/l1/di/app_config_facade.dart';
import '../../l0/api/categories.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/categories.dart';
import 'filesystem.dart';

part 'categories.g.dart';

@riverpod
CategoriesRepo categoriesRepo(final Ref ref) {
  final modRoot = ref.watch(
    appConfigFacadeProvider.select(
      (final value) => value.obtainValue(games).currentGameConfig.modRoot,
    ),
  );
  final fs = ref.watch(filesystemProvider);
  final categoriesRepoImpl = CategoriesRepoImpl(modRoot: modRoot, fs: fs);
  ref.onDispose(categoriesRepoImpl.dispose);
  return categoriesRepoImpl;
}

@riverpod
Stream<List<ModCategory>> categories(final Ref ref) {
  final categoriesRepo = ref.watch(categoriesRepoProvider);
  return categoriesRepo.categories;
}
