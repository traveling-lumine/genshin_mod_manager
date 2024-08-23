import '../../entity/game_config.dart';
import '../../entity/preset.dart';
import '../../repo/persistent_storage.dart';

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

String? getModRootUseCase(
  final PersistentStorage storage,
  final String prefix,
) =>
    storage.getString('$prefix.modRoot');

void setModRootUseCase(
  final PersistentStorage read,
  final String targetGame,
  final String path,
) {
  read.setString('$targetGame.modRoot', path);
}

String? getModExecFileUseCase(
  final PersistentStorage storage,
  final String prefix,
) =>
    storage.getString('$prefix.modExecFile');

void setModExecFileUseCase(
  final PersistentStorage read,
  final String targetGame,
  final String path,
) {
  read.setString('$targetGame.modExecFile', path);
}

String? getLauncherFileUseCase(
  final PersistentStorage storage,
  final String prefix,
) =>
    storage.getString('$prefix.launcherDir');

void setLauncherFileUseCase(
  final PersistentStorage read,
  final String targetGame,
  final String path,
) {
  read.setString('$targetGame.launcherDir', path);
}

PresetData? getPresetDataUseCase(
  final PersistentStorage storage,
  final String prefix,
) {
  final data = storage.getMap('$prefix.presetData');
  if (data == null) {
    return null;
  }
  final Map<String, PresetListMap> global2;
  final globalData = data['global'];
  if (globalData == null) {
    global2 = {};
  } else {
    final global = (globalData as Map).cast<String, Map<String, dynamic>>();
    global2 = {
      for (final e in global.entries)
        e.key: PresetListMap(
          bundledPresets: {
            for (final f in e.value.entries)
              f.key: PresetList(mods: (f.value as List).cast<String>()),
          },
        ),
    };
  }
  final Map<String, PresetListMap> local2;
  final localData = data['local'];
  if (localData == null) {
    local2 = {};
  } else {
    final local = (localData as Map).cast<String, Map<String, dynamic>>();
    local2 = {
      for (final e in local.entries)
        e.key: PresetListMap(
          bundledPresets: {
            for (final f in e.value.entries)
              f.key: PresetList(mods: (f.value as List).cast<String>()),
          },
        ),
    };
  }
  return PresetData(
    global: global2,
    local: local2,
  );
}

void setPresetDataUseCase(
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
