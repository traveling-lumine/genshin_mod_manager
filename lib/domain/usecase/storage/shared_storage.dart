import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/preset.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';

void afterInitializationUseCase(final PersistentStorage storage) {
  var version = storage.getInt('configVersion');
  if (version == null) {
    if (storage.getEntries().isEmpty) {
      storage.setInt('configVersion', 2);
    } else {
      _convertToVersion1(storage);
    }
  }
  version = storage.getInt('configVersion');
  if (version == 1) {
    _convertToVersion2(storage);
  }
}

void _convertToVersion1(final PersistentStorage storage2) {
  const dotString = '.';
  final tDirRaw = storage2.getString('targetDir') ?? dotString;
  final targetDir = tDirRaw;

  var modRoot = getModRootUseCase(storage2, targetDir);
  if (modRoot == null && targetDir != dotString) {
    modRoot = targetDir.pJoin('Mods');
  }

  var modExecFile = getModExecFileUseCase(storage2, targetDir);
  if (modExecFile == null && targetDir != dotString) {
    modExecFile = targetDir.pJoin('3DMigoto Loader.exe');
  }

  storage2
    ..removeKey('targetDir')
    ..setInt('configVersion', 1);
}

void _convertToVersion2(final PersistentStorage storage2) {
  final genshinModRoot = storage2.getString('modRoot') ?? '';
  final genshinModExecFile = storage2.getString('modExecFile') ?? '';
  final genshinLauncherDir = storage2.getString('launcherDir') ?? '';
  final genshinPresetData = storage2.getMap('presetData') ?? {};
  final starrailModRoot = storage2.getString('s_modRoot') ?? '';
  final starrailModExecFile = storage2.getString('s_modExecFile') ?? '';
  final starrailLauncherDir = storage2.getString('s_launcherDir') ?? '';
  final starrailPresetData = storage2.getMap('s_presetData') ?? {};
  storage2
    ..setList('games', ['Genshin', 'Starrail'])
    ..setString('lastGame', 'Genshin')
    ..setString('Genshin.modRoot', genshinModRoot)
    ..setString('Genshin.modExecFile', genshinModExecFile)
    ..setString('Genshin.launcherDir', genshinLauncherDir)
    ..setMap('Genshin.presetData', genshinPresetData)
    ..setString('Starrail.modRoot', starrailModRoot)
    ..setString('Starrail.modExecFile', starrailModExecFile)
    ..setString('Starrail.launcherDir', starrailLauncherDir)
    ..setMap('Starrail.presetData', starrailPresetData)
    ..setInt('configVersion', 2);
}

String? getModRootUseCase(
  final PersistentStorage storage,
  final String prefix,
) =>
    storage.getString('$prefix.modRoot');

String? getModExecFileUseCase(
  final PersistentStorage storage,
  final String prefix,
) =>
    storage.getString('$prefix.modExecFile');

String? getLauncherFileUseCase(
  final PersistentStorage storage,
  final String prefix,
) =>
    storage.getString('$prefix.launcherDir');

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
