import '../../../fs_interface/helper/path_op_string.dart';
import '../constants.dart';
import '../api/persistent_storage.dart';
import 'game_config.dart';

final configVersionKey = StorageAccessKey.configVersion.name;

void afterInitializationUseCase(final PersistentStorage storage) {
  var version = storage.getInt(configVersionKey);
  if (version == null) {
    if (storage.getEntries().isEmpty) {
      storage.setInt(configVersionKey, 2);
    } else {
      _convertToVersion1(storage);
    }
  }
  version = storage.getInt(configVersionKey);
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
    ..setInt(configVersionKey, 1);
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
    ..setInt(configVersionKey, 2);
}
