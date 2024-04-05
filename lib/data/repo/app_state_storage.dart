import 'package:genshin_mod_manager/domain/entity/preset.dart';
import 'package:genshin_mod_manager/domain/repo/app_state_storage.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';
import 'package:logger/logger.dart';

class AppStateStorageImpl implements AppStateStorage {
  const AppStateStorageImpl({
    required this.persistentStorage,
  });

  @Deprecated('Backwards compatibility only')
  static const String _targetDirKey = 'targetDir';

  String get _modRootKey => 'modRoot';

  String get _modExecFileKey => 'modExecFile';

  String get _launcherFileKey => 'launcherDir';

  String get _runTogetherKey => 'runTogether';
  static const bool _runTogetherDefaultValue = false;

  String get _moveOnDragKey => 'moveOnDrag';
  static const bool _moveOnDragDefaultValue = true;

  String get _showFolderIconKey => 'showFolderIcon';
  static const bool _showFolderIconDefaultValue = true;

  String get _showEnabledModsFirstKey => 'showEnabledModsFirst';
  static const bool _showEnabledModsFirstDefaultValue = false;

  String get _presetDatakey => 'presetData';

  String get _darkModeKey => 'darkMode';
  static const bool _darkModeDefaultValue = true;

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
  PresetData? getPresetData() {
    final data = persistentStorage.getMap(_presetDatakey);
    if (data == null) {
      return null;
    }
    try {
      final global = data['global'];
      final local = data['local'];
      return PresetData(
        global: {
          for (final e in global.entries)
            e.key: PresetListMap(
              bundledPresets: {
                for (final f in e.value.entries)
                  f.key: PresetList(
                    mods: List<String>.from(f.value),
                  ),
              },
            )
        },
        local: {
          for (final e in local.entries)
            e.key: PresetListMap(
              bundledPresets: {
                for (final f in e.value.entries)
                  f.key: PresetList(
                    mods: List<String>.from(f.value),
                  ),
              },
            )
        },
      );
    } on Exception catch (e) {
      Logger().e('Failed to parse preset data: $e');
      return null;
    }
  }

  @override
  void setPresetData(final PresetData data) {
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
    persistentStorage
        .setMap(_presetDatakey, {'global': global, 'local': local});
  }

  @override
  bool getDarkMode() =>
      persistentStorage.getBool(_darkModeKey) ?? _darkModeDefaultValue;

  @override
  void setDarkMode(final bool value) =>
      persistentStorage.setBool(_darkModeKey, value);

  @override
  @Deprecated('Backwards compatibility only')
  String? getTargetDir() => persistentStorage.getString(_targetDirKey);

  @override
  @Deprecated('Backwards compatibility only')
  void setTargetDir(final String path) {
    persistentStorage.setString(_targetDirKey, path);
  }
}
