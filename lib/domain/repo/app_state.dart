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

  void setModRoot(final String path);

  void setModExecFile(final String path);

  void setLauncherFile(final String path);

  void setRunTogether(final bool value);

  void setMoveOnDrag(final bool value);

  void setShowFolderIcon(final bool value);

  void setShowEnabledModsFirst(final bool value);

  void setPresetData(final String data);
}
