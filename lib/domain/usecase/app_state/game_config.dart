import 'package:genshin_mod_manager/domain/entity/game_config.dart';
import 'package:genshin_mod_manager/domain/entity/preset.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';
import 'package:genshin_mod_manager/domain/usecase/storage/shared_storage.dart';

/// Initializes the game configuration.
GameConfig initializeGameConfigUseCase(
  final PersistentStorage storage,
  final String prefix,
) =>
    GameConfig(
      modRoot: getModRootUseCase(storage, prefix),
      modExecFile: getModExecFileUseCase(storage, prefix),
      presetData: getPresetDataUseCase(storage, prefix),
      launcherFile: getLauncherFileUseCase(storage, prefix),
    );

void changeModRootUseCase(
  final PersistentStorage read,
  final String targetGame,
  final String path,
) {
  read.setString('$targetGame.modRoot', path);
}

void changeModExecFileUseCase(
  final PersistentStorage read,
  final String targetGame,
  final String path,
) {
  read.setString('$targetGame.modExecFile', path);
}

void changeLauncherFileUseCase(
  final PersistentStorage read,
  final String targetGame,
  final String path,
) {
  read.setString('$targetGame.launcherDir', path);
}

void changePresetDataUseCase(
  final PresetData data,
  final PersistentStorage read,
  final String targetGame,
) {
  final global = Map.fromEntries(
    data.global.entries.map(
      (final e) => MapEntry(
        e.key,
        Map.fromEntries(
          e.value.bundledPresets.entries
              .map((final f) => MapEntry(f.key, f.value.mods)),
        ),
      ),
    ),
  );
  final local = Map.fromEntries(
    data.local.entries.map(
      (final e) => MapEntry(
        e.key,
        Map.fromEntries(
          e.value.bundledPresets.entries
              .map((final f) => MapEntry(f.key, f.value.mods)),
        ),
      ),
    ),
  );
  read.setMap('$targetGame.presetData', {'global': global, 'local': local});
}
