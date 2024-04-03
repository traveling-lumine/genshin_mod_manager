import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/app_state_storage.dart';

/// A use case that initializes the app state.
AppState callAppStateInitializationUseCase(final AppStateStorage storage) {
  const dotString = '.';
  final tDirRaw = storage.getTargetDir();
  final targetDir = tDirRaw ?? dotString;

  var modRoot = storage.getModRoot();
  if (modRoot == null && targetDir != dotString) {
    modRoot = targetDir.pJoin('Mods');
  }

  var modExecFile = storage.getModExecFile();
  if (modExecFile == null && targetDir != dotString) {
    modExecFile = targetDir.pJoin('3DMigoto Loader.exe');
  }

  if (targetDir != dotString) {
    storage.setTargetDir(dotString);
  }

  return AppState(
    modRoot: modRoot,
    modExecFile: modExecFile,
    moveOnDrag: storage.getMoveOnDrag(),
    presetData: storage.getPresetData(),
    runTogether: storage.getRunTogether(),
    launcherFile: storage.getLauncherFile(),
    showFolderIcon: storage.getShowFolderIcon(),
    showEnabledModsFirst: storage.getShowEnabledModsFirst(),
    darkMode: storage.getDarkMode(),
  );
}
