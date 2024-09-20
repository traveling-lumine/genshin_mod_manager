import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../backend/structure/entity/mod_category.dart';
import '../../backend/structure/usecase/collect_categories.dart';
import '../app_state/game_config.dart';
import '../fs_watcher.dart';

part 'categories.g.dart';

@riverpod
List<ModCategory> categories(final CategoriesRef ref) {
  final modRoot = ref.watch(
    gameConfigNotifierProvider.select((final state) => state.modRoot),
  );
  if (modRoot == null) {
    return [];
  }

  final watcher = ref.watch(directoryInFolderProvider(modRoot));
  final subscription = watcher.listen((final event) => ref.invalidateSelf());
  ref.onDispose(subscription.cancel);

  return collectCategoriesUseCase(modRoot: modRoot);
}
