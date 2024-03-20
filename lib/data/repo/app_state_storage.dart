import 'package:genshin_mod_manager/domain/repo/app_state_storage.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';

class AppStateStorageImpl implements AppStateStorage {
  const AppStateStorageImpl({
    required this.persistentStorage,
  });

  @Deprecated('Backwards compatibility only')
  static const String _targetDirKey = 'targetDir';

  static const String _modRootKey = 'modRoot';
  static const String _modExecFileKey = 'modExecFile';
  static const String _launcherFileKey = 'launcherDir';
  static const String _runTogetherKey = 'runTogether';
  static const bool _runTogetherDefaultValue = false;
  static const String _moveOnDragKey = 'moveOnDrag';
  static const bool _moveOnDragDefaultValue = true;
  static const String _showFolderIconKey = 'showFolderIcon';
  static const bool _showFolderIconDefaultValue = true;
  static const String _showEnabledModsFirstKey = 'showEnabledModsFirst';
  static const bool _showEnabledModsFirstDefaultValue = false;
  static const String _presetDatakey = 'presetData';

  final PersistentStorage persistentStorage;

  @override
  String? getModRoot() => persistentStorage.getString(_modRootKey);

  @override
  void setModRoot(final String path) {
    persistentStorage.setString(_modRootKey, path);
  }

  @override
  String? getModExecFile() => persistentStorage.getString(_modExecFileKey);

  @override
  void setModExecFile(final String path) {
    persistentStorage.setString(_modExecFileKey, path);
  }

  @override
  String? getLauncherFile() => persistentStorage.getString(_launcherFileKey);

  @override
  void setLauncherFile(final String path) {
    persistentStorage.setString(_launcherFileKey, path);
  }

  @override
  bool getRunTogether() =>
      persistentStorage.getBool(_runTogetherKey) ?? _runTogetherDefaultValue;

  @override
  void setRunTogether(final bool value) {
    persistentStorage.setBool(_runTogetherKey, value);
  }

  @override
  bool getMoveOnDrag() =>
      persistentStorage.getBool(_moveOnDragKey) ?? _moveOnDragDefaultValue;

  @override
  void setMoveOnDrag(final bool value) {
    persistentStorage.setBool(_moveOnDragKey, value);
  }

  @override
  bool getShowFolderIcon() =>
      persistentStorage.getBool(_showFolderIconKey) ??
      _showFolderIconDefaultValue;

  @override
  void setShowFolderIcon(final bool value) {
    persistentStorage.setBool(_showFolderIconKey, value);
  }

  @override
  bool getShowEnabledModsFirst() =>
      persistentStorage.getBool(_showEnabledModsFirstKey) ??
      _showEnabledModsFirstDefaultValue;

  @override
  void setShowEnabledModsFirst(final bool value) {
    persistentStorage.setBool(_showEnabledModsFirstKey, value);
  }

  @override
  Map<String, Map<String, List<String>>>? getPresetData() {
    final data = persistentStorage.getMap(_presetDatakey);
    if (data == null) {
      return null;
    }
    return Map<String, Map<String, List<String>>>.from(data);
  }

  @override
  void setPresetData(final Map<String, Map<String, List<String>>> data) {
    persistentStorage.setMap(_presetDatakey, data);
  }

  @override
  @Deprecated('Backwards compatibility only')
  String? getTargetDir() => persistentStorage.getString(_targetDirKey);

  @override
  @Deprecated('Backwards compatibility only')
  void setTargetDir(final String path) {
    persistentStorage.setString(_targetDirKey, path);
  }
}
