abstract interface class AppStateService {
  Future<bool> get successfulLoad;

  Stream<String> get modRoot;

  Stream<String> get modExecFile;

  Stream<String> get launcherFile;

  Stream<bool> get runTogether;

  Stream<bool> get moveOnDrag;

  Stream<bool> get showFolderIcon;

  Stream<bool> get showEnabledModsFirst;

  Stream<String> get presetData;

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
