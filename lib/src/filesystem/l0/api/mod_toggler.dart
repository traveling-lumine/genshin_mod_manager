import '../../../app_config/l0/entity/game_config.dart';
import '../entity/mod.dart';
import '../entity/mod_category.dart';
import '../entity/mod_toggle_result.dart';

abstract interface class ModToggler {
  Future<ModToggleResult> disableDirect({
    required final GameConfig gameConfig,
    required final String categoryName,
    required final String modName,
  });
  Future<ModToggleResult> disableMod({
    required final GameConfig gameConfig,
    required final Mod mod,
  });
  Future<ModToggleResult> disableOf({
    required final GameConfig gameConfig,
    required final ModCategory category,
    required final String modName,
  });

  Future<ModToggleResult> enableDirect({
    required final GameConfig gameConfig,
    required final String categoryName,
    required final String modName,
  });

  Future<ModToggleResult> enableMod({
    required final GameConfig gameConfig,
    required final Mod mod,
  });

  Future<ModToggleResult> enableOf({
    required final GameConfig gameConfig,
    required final ModCategory category,
    required final String modName,
  });
}
