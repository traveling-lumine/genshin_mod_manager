import 'package:genshin_mod_manager/domain/entity/preset.dart';

abstract interface class AppStateStorage {
  String? getModRoot();

  void setModRoot(final String path);

  String? getModExecFile();

  void setModExecFile(final String path);

  String? getLauncherFile();

  void setLauncherFile(final String path);

  bool getRunTogether();

  void setRunTogether(final bool value);

  bool getMoveOnDrag();

  void setMoveOnDrag(final bool value);

  bool getShowFolderIcon();

  void setShowFolderIcon(final bool value);

  bool getShowEnabledModsFirst();

  void setShowEnabledModsFirst(final bool value);

  PresetData? getPresetData();

  void setPresetData(final PresetData data);

  bool getDarkMode();

  void setDarkMode(final bool value);

  @Deprecated('Backwards compatibility only')
  String? getTargetDir();

  @Deprecated('Backwards compatibility only')
  void setTargetDir(final String path);
}
