import 'package:genshin_mod_manager/domain/repo/disposable.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';

abstract interface class AppStateService implements Disposable {
  Future<bool> get successfulLoad;

  LatestStream<String> get modRoot;

  LatestStream<String> get modExecFile;

  LatestStream<String> get launcherFile;

  LatestStream<bool> get runTogether;

  LatestStream<bool> get moveOnDrag;

  LatestStream<bool> get showFolderIcon;

  LatestStream<bool> get showEnabledModsFirst;

  LatestStream<String> get presetData;

  void reload();

  void setModRoot(String path);

  void setModExecFile(String path);

  void setLauncherFile(String path);

  void setRunTogether(bool value);

  void setMoveOnDrag(bool value);

  void setShowFolderIcon(bool value);

  void setShowEnabledModsFirst(bool value);

  void setPresetData(String data);
}
