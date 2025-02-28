import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app_config/l0/entity/entries.dart';
import '../../../app_config/l1/di/app_config_facade.dart';
import '../../l0/entity/mod_category.dart';
import '../impl/category_repo.dart';
import 'filesystem.dart';

part 'categories.g.dart';

@riverpod
Stream<List<ModCategory>> categories(final Ref ref) {
  final categoryRepoImpl = CategoryRepoImpl(
    modRoot: ref.watch(
      appConfigFacadeProvider.select(
        (final value) => value.obtainValue(games).currentGameConfig.modRoot,
      ),
    ),
    fs: ref.watch(filesystemProvider),
  );
  ref.onDispose(categoryRepoImpl.dispose);
  return categoryRepoImpl.categories;
}
