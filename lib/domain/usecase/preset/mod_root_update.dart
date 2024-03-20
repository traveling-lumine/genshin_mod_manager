import 'package:genshin_mod_manager/domain/entity/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';

class ModRootUpdateUseCase {
  static const String _modRootKey = 'modRoot';

  const ModRootUpdateUseCase({
    required this.persistentStorage,
  });

  final PersistentStorage persistentStorage;

  AppState call({
    required final String modRoot,
    required final AppState currentState,
  }) {
    persistentStorage.setString(_modRootKey, modRoot);
    return currentState.copyWith(modRoot: modRoot);
  }
}
